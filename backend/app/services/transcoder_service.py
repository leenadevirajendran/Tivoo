from __future__ import annotations
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

from app.core.config import get_settings
from app.db.session import SessionLocal
from app.models.video import Video
from app.services.storage_service import storage_service


@dataclass
class VideoProbeResult:
    duration_seconds: float
    width: int
    height: int
    has_audio: bool


class TranscoderService:
    """FFmpeg H.264 MP4 + Adaptive HLS transcoding pipeline executed asynchronously."""

    def __init__(self) -> None:
        self._executor: ThreadPoolExecutor | None = None

    def _get_executor(self) -> ThreadPoolExecutor:
        if self._executor is None:
            settings = get_settings()
            self._executor = ThreadPoolExecutor(
                max_workers=settings.transcode_max_workers,
                thread_name_prefix="tivoo-ffmpeg",
            )
        return self._executor

    def shutdown(self) -> None:
        if self._executor is not None:
            self._executor.shutdown(wait=False)
            self._executor = None

    def probe_video(self, input_path: Path) -> VideoProbeResult:
        """Inspect video streams using ffprobe."""
        settings = get_settings()
        cmd = [
            settings.ffprobe_bin,
            "-v",
            "quiet",
            "-print_format",
            "json",
            "-show_format",
            "-show_streams",
            str(input_path),
        ]
        try:
            proc = subprocess.run(cmd, capture_output=True, text=True, check=True, timeout=20)
            info = json.loads(proc.stdout or "{}")
        except (subprocess.SubprocessError, json.JSONDecodeError, OSError):
            return VideoProbeResult(duration_seconds=0.0, width=0, height=0, has_audio=False)

        duration = float(info.get("format", {}).get("duration") or 0.0)
        width = 0
        height = 0
        has_audio = False

        for stream in info.get("streams", []):
            codec_type = stream.get("codec_type")
            if codec_type == "video" and width == 0:
                width = int(stream.get("width") or 0)
                height = int(stream.get("height") or 0)
                if duration == 0.0:
                    duration = float(stream.get("duration") or 0.0)
            elif codec_type == "audio":
                has_audio = True

        return VideoProbeResult(
            duration_seconds=round(duration, 2),
            width=width,
            height=height,
            has_audio=has_audio,
        )

    def extract_thumbnail(self, input_path: Path, output_jpg: Path) -> bool:
        """Extract a poster frame JPEG cleanly at 0.5s (or frame 0)."""
        settings = get_settings()
        for seek_ts in ("00:00:00.500", "00:00:00.000"):
            cmd = [
                settings.ffmpeg_bin,
                "-y",
                "-ss",
                seek_ts,
                "-i",
                str(input_path),
                "-frames:v",
                "1",
                "-vf",
                "scale='min(720,iw)':-2",
                "-q:v",
                "3",
                str(output_jpg),
            ]
            try:
                subprocess.run(cmd, capture_output=True, check=True, timeout=20)
                if output_jpg.exists() and output_jpg.stat().st_size > 0:
                    return True
            except (subprocess.SubprocessError, OSError):
                continue
        return False

    def enqueue_transcode(self, video_id: str, raw_local_path: Path) -> None:
        """Dispatch H.264 + HLS transcoding in background thread pool."""
        settings = get_settings()
        if not settings.enable_auto_transcode:
            return
        self._get_executor().submit(self._run_transcode_job, video_id, raw_local_path)

    def _run_transcode_job(self, video_id: str, raw_local_path: Path) -> None:
        settings = get_settings()
        work_dir = Path(tempfile.mkdtemp(prefix=f"tivoo_tr_{video_id}_"))

        db = SessionLocal()
        try:
            video = db.get(Video, video_id)
            if not video:
                return
            video.transcoding_status = "processing"
            video.transcoding_error = None
            db.commit()

            probe = self.probe_video(raw_local_path)
            mp4_out = work_dir / "optimized.mp4"

            # 1. Universal H.264 + faststart MP4 transcode (max 1080px width, even height)
            mp4_cmd = [
                settings.ffmpeg_bin,
                "-y",
                "-i",
                str(raw_local_path),
                "-vf",
                "scale='min(1080,iw)':-2",
                "-c:v",
                "libx264",
                "-preset",
                "veryfast",
                "-crf",
                "22",
                "-profile:v",
                "high",
                "-level",
                "4.1",
                "-pix_fmt",
                "yuv420p",
                "-movflags",
                "+faststart",
            ]
            if probe.has_audio:
                mp4_cmd.extend(["-c:a", "aac", "-b:a", "128k", "-ar", "44100"])
            else:
                mp4_cmd.append("-an")
            mp4_cmd.append(str(mp4_out))

            mp4_proc = subprocess.run(mp4_cmd, capture_output=True, text=True, timeout=300)
            if mp4_proc.returncode != 0 or not mp4_out.exists():
                raise RuntimeError(mp4_proc.stderr[-600:] if mp4_proc.stderr else "H.264 encode failed")

            # 2. Adaptive HLS packaging (720p + 480p variants or single native-fit variant)
            hls_dir = work_dir / "hls"
            hls_dir.mkdir(parents=True, exist_ok=True)
            variant_720 = hls_dir / "720p"
            variant_480 = hls_dir / "480p"
            variant_720.mkdir(exist_ok=True)
            variant_480.mkdir(exist_ok=True)

            seg_time = str(settings.hls_segment_seconds)
            variants_info: list[tuple[str, int, str]] = []

            for label, max_w, crf, bandwidth, dir_path in [
                ("720p", 720, "23", 2200000, variant_720),
                ("480p", 480, "26", 1100000, variant_480),
            ]:
                playlist_path = dir_path / "index.m3u8"
                seg_pattern = dir_path / "seg_%03d.ts"
                hls_cmd = [
                    settings.ffmpeg_bin,
                    "-y",
                    "-i",
                    str(mp4_out),
                    "-vf",
                    f"scale='min({max_w},iw)':-2",
                    "-c:v",
                    "libx264",
                    "-preset",
                    "veryfast",
                    "-crf",
                    crf,
                    "-pix_fmt",
                    "yuv420p",
                    "-g",
                    "60",
                    "-keyint_min",
                    "60",
                    "-sc_threshold",
                    "0",
                ]
                if probe.has_audio:
                    hls_cmd.extend(["-c:a", "aac", "-b:a", "96k"])
                else:
                    hls_cmd.append("-an")
                hls_cmd.extend(
                    [
                        "-f",
                        "hls",
                        "-hls_time",
                        seg_time,
                        "-hls_playlist_type",
                        "vod",
                        "-hls_segment_filename",
                        str(seg_pattern),
                        str(playlist_path),
                    ]
                )
                hls_proc = subprocess.run(hls_cmd, capture_output=True, text=True, timeout=300)
                if hls_proc.returncode == 0 and playlist_path.exists():
                    variants_info.append((label, bandwidth, f"{label}/index.m3u8"))

            master_lines = ["#EXTM3U", "#EXT-X-VERSION:3"]
            for _, bw, rel_path in variants_info:
                master_lines.append(f"#EXT-X-STREAM-INF:BANDWIDTH={bw}")
                master_lines.append(rel_path)
            if variants_info:
                (hls_dir / "master.m3u8").write_text("\n".join(master_lines) + "\n", encoding="utf-8")

            # 3. Ensure thumbnail exists
            thumb_out = work_dir / "thumb.jpg"
            thumb_key = video.thumbnail_storage_key
            thumb_url = video.thumbnail_url
            if (not thumb_url) and self.extract_thumbnail(mp4_out, thumb_out):
                thumb_key = f"videos/{video_id}/thumb.jpg"
                thumb_url = storage_service.save_local_file(thumb_out, thumb_key)

            # 4. Upload transcoded MP4 + HLS directory to active storage driver
            video_key = f"videos/{video_id}/video.mp4"
            hls_prefix = f"videos/{video_id}/hls"
            new_video_url = storage_service.save_local_file(mp4_out, video_key)

            new_hls_url = None
            if (hls_dir / "master.m3u8").exists():
                storage_service.save_directory(hls_dir, hls_prefix)
                new_hls_url = storage_service.build_public_url(f"{hls_prefix}/master.m3u8")

            final_probe = self.probe_video(mp4_out)
            video.video_storage_key = video_key
            video.video_url = new_video_url
            video.hls_storage_prefix = hls_prefix if new_hls_url else ""
            video.hls_url = new_hls_url
            video.thumbnail_storage_key = thumb_key or ""
            video.thumbnail_url = thumb_url
            video.duration_seconds = final_probe.duration_seconds or probe.duration_seconds
            video.width = final_probe.width or probe.width
            video.height = final_probe.height or probe.height
            video.file_size_bytes = mp4_out.stat().st_size
            video.transcoding_status = "ready"
            video.transcoding_error = None
            db.commit()
        except Exception as exc:
            db.rollback()
            video = db.get(Video, video_id)
            if video:
                video.transcoding_status = "failed"
                video.transcoding_error = str(exc)[:1000]
                db.commit()
        finally:
            db.close()
            shutil.rmtree(work_dir, ignore_errors=True)
            # If uploaded to cloud (S3/R2), remove temporary staging file from temp folder
            if settings.storage_backend != "local" and raw_local_path.exists():
                raw_local_path.unlink(missing_ok=True)


transcoder_service = TranscoderService()

