(() => {
  const TOKEN_KEYS = {
    access: "tivoo_access_token",
    refresh: "tivoo_refresh_token",
  };

  const state = {
    user: null,
    feedType: "for_you",
    page: 1,
    hasMore: false,
    category: "",
    query: "",
    activeCommentVideoId: null,
    hlsInstances: [],
    transcodeTimers: new Map(),
  };

  const el = (id) => document.getElementById(id);

  function showToast(message, durationMs = 3600) {
    const toast = el("toast");
    toast.textContent = message;
    toast.classList.remove("hidden");
    window.clearTimeout(toast._timer);
    toast._timer = window.setTimeout(() => toast.classList.add("hidden"), durationMs);
  }

  function setTokens(accessToken, refreshToken) {
    if (accessToken) localStorage.setItem(TOKEN_KEYS.access, accessToken);
    if (refreshToken) localStorage.setItem(TOKEN_KEYS.refresh, refreshToken);
  }

  function clearTokens() {
    localStorage.removeItem(TOKEN_KEYS.access);
    localStorage.removeItem(TOKEN_KEYS.refresh);
  }

  function getAccessToken() {
    return localStorage.getItem(TOKEN_KEYS.access) || "";
  }

  function escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text ?? "";
    return div.innerHTML;
  }

  async function apiFetch(path, options = {}, retryRefresh = true) {
    const headers = new Headers(options.headers || {});
    const token = getAccessToken();
    if (token && !headers.has("Authorization")) {
      headers.set("Authorization", `Bearer ${token}`);
    }
    if (options.body && !(options.body instanceof FormData) && !headers.has("Content-Type")) {
      headers.set("Content-Type", "application/json");
    }

    const res = await fetch(path, { ...options, headers });

    if (res.status === 401 && retryRefresh && localStorage.getItem(TOKEN_KEYS.refresh)) {
      const refreshed = await tryRefreshToken();
      if (refreshed) {
        return apiFetch(path, options, false);
      }
      clearTokens();
      state.user = null;
      renderAuthUI();
    }

    const contentType = res.headers.get("content-type") || "";
    const data = contentType.includes("application/json") ? await res.json() : null;
    if (!res.ok) {
      const msg = data?.error || data?.detail || `Request failed (${res.status})`;
      throw new Error(msg);
    }
    return data;
  }

  async function tryRefreshToken() {
    const refreshToken = localStorage.getItem(TOKEN_KEYS.refresh);
    if (!refreshToken) return false;
    try {
      const res = await fetch("/api/auth/refresh", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ refreshToken }),
      });
      if (!res.ok) return false;
      const data = await res.json();
      setTokens(data.accessToken, data.refreshToken);
      state.user = data.user;
      return true;
    } catch {
      return false;
    }
  }

  async function loadHealth() {
    const wrap = el("healthBadges");
    try {
      const health = await apiFetch("/api/health", {}, false);
      const dbOk = health.database?.connected;
      const ffOk = health.transcoding?.ffmpegAvailable;
      const mailOk = health.emailOtp?.configured;
      wrap.innerHTML = [
        badgeHtml(`MySQL: ${health.database?.name}`, dbOk ? "badge-ok" : "badge-bad"),
        badgeHtml(`FFmpeg: ${ffOk ? "Ready" : "Missing"}`, ffOk ? "badge-ok" : "badge-warn"),
        badgeHtml(`Storage: ${health.storage?.backend}`, "badge-ok"),
        badgeHtml(
          `SMTP OTP: ${mailOk ? "Active" : "Needs App Password"}`,
          mailOk ? "badge-ok" : "badge-warn"
        ),
      ].join("");
    } catch (err) {
      wrap.innerHTML = badgeHtml(`Health error: ${escapeHtml(err.message)}`, "badge-bad");
    }
  }

  function badgeHtml(label, cls) {
    return `<span class="badge ${cls}">${escapeHtml(label)}</span>`;
  }

  async function bootstrapSession() {
    if (!getAccessToken()) {
      renderAuthUI();
      return;
    }
    try {
      state.user = await apiFetch("/api/auth/me");
    } catch {
      clearTokens();
      state.user = null;
    }
    renderAuthUI();
  }

  function renderAuthUI() {
    const signedIn = Boolean(state.user);
    el("guestCard").classList.toggle("hidden", signedIn);
    el("profileCard").classList.toggle("hidden", !signedIn);
    el("openAuthBtn").classList.toggle("hidden", signedIn);
    el("logoutBtn").classList.toggle("hidden", !signedIn);
    el("uploadAuthHint").textContent = signedIn
      ? `Publishing as @${state.user.username}`
      : "Sign in required to publish";

    if (signedIn) {
      const u = state.user;
      el("profileName").textContent = u.name;
      el("profileHandle").textContent = `@${u.username}`;
      el("profileBio").textContent = u.bio || "No bio yet. Click Edit Profile to add one.";
      el("statFollowers").textContent = u.followersCount;
      el("statFollowing").textContent = u.followingCount;
      el("statLikes").textContent = u.likesCount;
      el("profileVerifiedBadge").classList.toggle("hidden", !u.isEmailVerified);

      const avatarImg = el("profileAvatarImg");
      const fallback = el("profileAvatarFallback");
      if (u.avatarUrl) {
        avatarImg.src = u.avatarUrl;
        avatarImg.classList.remove("hidden");
        fallback.classList.add("hidden");
      } else {
        avatarImg.classList.add("hidden");
        fallback.classList.remove("hidden");
        fallback.textContent = (u.name || "U").slice(0, 1).toUpperCase();
      }

      const cover = el("profileCover");
      cover.style.backgroundImage = u.coverBackgroundUrl
        ? `url(${u.coverBackgroundUrl})`
        : "";

      el("editName").value = u.name || "";
      el("editUsername").value = u.username || "";
      el("editBio").value = u.bio || "";
      el("editPrivate").checked = Boolean(u.isPrivate);
    }
  }

  /* -------- Auth Modal -------- */
  function openAuthModal(tab = "password") {
    el("authModal").classList.remove("hidden");
    switchAuthTab(tab);
    setAuthMessage("");
  }

  function closeAuthModal() {
    el("authModal").classList.add("hidden");
  }

  function switchAuthTab(tab) {
    document.querySelectorAll("[data-auth-tab]").forEach((btn) => {
      btn.classList.toggle("active", btn.dataset.authTab === tab);
    });
    el("passwordLoginForm").classList.toggle("hidden", tab !== "password");
    el("otpLoginPanel").classList.toggle("hidden", tab !== "otp");
    el("registerForm").classList.toggle("hidden", tab !== "register");
  }

  function setAuthMessage(msg, isError = false) {
    const box = el("authMessage");
    if (!msg) {
      box.classList.add("hidden");
      box.textContent = "";
      return;
    }
    box.textContent = msg;
    box.className = `feedback ${isError ? "err" : "ok"}`;
  }

  async function handleAuthenticatedResponse(tokenPayload, message) {
    setTokens(tokenPayload.accessToken, tokenPayload.refreshToken);
    state.user = tokenPayload.user;
    renderAuthUI();
    closeAuthModal();
    showToast(message);
    await Promise.all([loadFeed(true), searchCreators()]);
  }

  /* -------- Profile & Creators -------- */
  async function searchCreators() {
    const q = el("creatorSearchInput").value.trim();
    const list = el("creatorSearchResults");
    try {
      const data = await apiFetch(`/api/profiles/search?q=${encodeURIComponent(q)}&limit=12`);
      if (!data.profiles.length) {
        list.innerHTML = `<div class="muted small">No creators found in MySQL yet.</div>`;
        return;
      }
      list.innerHTML = data.profiles
        .map((p) => {
          const isSelf = state.user && state.user.id === p.id;
          const btnLabel = p.followStatus === "following" || p.followStatus === "mutual"
            ? "Following"
            : p.followStatus === "requested"
            ? "Requested"
            : "Follow";
          return `
            <div class="creator-item">
              <div class="creator-meta">
                <strong>${escapeHtml(p.name)}</strong>
                <span class="muted small">@${escapeHtml(p.username)} &middot; ${escapeHtml(p.followersCount)} followers</span>
              </div>
              ${
                isSelf
                  ? `<span class="pill">You</span>`
                  : `<button class="btn btn-secondary btn-sm follow-toggle-btn" data-user-id="${escapeHtml(p.id)}" data-status="${escapeHtml(p.followStatus)}" type="button">${btnLabel}</button>`
              }
            </div>
          `;
        })
        .join("");

      list.querySelectorAll(".follow-toggle-btn").forEach((btn) => {
        btn.addEventListener("click", () => toggleFollow(btn.dataset.userId, btn.dataset.status));
      });
    } catch (err) {
      list.innerHTML = `<div class="muted small">${escapeHtml(err.message)}</div>`;
    }
  }

  async function toggleFollow(userId, currentStatus) {
    if (!state.user) {
      openAuthModal("password");
      return;
    }
    try {
      const unfollow = currentStatus === "following" || currentStatus === "mutual" || currentStatus === "requested";
      await apiFetch(`/api/follows/${encodeURIComponent(userId)}`, {
        method: unfollow ? "DELETE" : "POST",
      });
      await bootstrapSession();
      await Promise.all([searchCreators(), loadFeed(true)]);
    } catch (err) {
      showToast(err.message);
    }
  }

  async function uploadProfileMedia(kind, file) {
    if (!file) return;
    const form = new FormData();
    form.append("file", file);
    try {
      state.user = await apiFetch(`/api/profiles/me/${kind}`, {
        method: "POST",
        body: form,
      });
      renderAuthUI();
      showToast(`${kind === "avatar" ? "Avatar" : "Cover"} updated`);
    } catch (err) {
      showToast(err.message);
    }
  }

  /* -------- Video Upload & Transcode Polling -------- */
  function uploadVideoWithProgress(formData) {
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      xhr.open("POST", "/api/videos");
      const token = getAccessToken();
      if (token) {
        xhr.setRequestHeader("Authorization", `Bearer ${token}`);
      }
      xhr.upload.onprogress = (evt) => {
        if (!evt.lengthComputable) return;
        const pct = Math.round((evt.loaded / evt.total) * 100);
        el("uploadProgressFill").style.width = `${pct}%`;
        el("uploadStatusText").textContent = `Uploading video to storage: ${pct}%`;
      };
      xhr.onload = () => {
        try {
          const data = JSON.parse(xhr.responseText || "{}");
          if (xhr.status >= 200 && xhr.status < 300) {
            resolve(data);
          } else {
            reject(new Error(data.error || data.detail || `Upload failed (${xhr.status})`));
          }
        } catch {
          reject(new Error(`Upload failed (${xhr.status})`));
        }
      };
      xhr.onerror = () => reject(new Error("Network error during upload"));
      xhr.send(formData);
    });
  }

  function pollTranscodeStatus(videoId) {
    if (state.transcodeTimers.has(videoId)) return;
    const timer = window.setInterval(async () => {
      try {
        const video = await apiFetch(`/api/videos/${encodeURIComponent(videoId)}`);
        if (video.transcodingStatus === "ready" || video.transcodingStatus === "failed") {
          window.clearInterval(timer);
          state.transcodeTimers.delete(videoId);
          el("uploadStatusText").textContent =
            video.transcodingStatus === "ready"
              ? "H.264 + HLS transcoding complete!"
              : `Transcoding issue: ${video.transcodingError || "Check FFmpeg"}`;
          await loadFeed(true);
        } else {
          el("uploadStatusText").textContent = `FFmpeg transcoding (${video.transcodingStatus})...`;
        }
      } catch {
        window.clearInterval(timer);
        state.transcodeTimers.delete(videoId);
      }
    }, 2000);
    state.transcodeTimers.set(videoId, timer);
  }

  /* -------- Algorithmic Feed & Playback -------- */
  function destroyHlsInstances() {
    state.hlsInstances.forEach((h) => h.destroy());
    state.hlsInstances = [];
  }

  async function loadFeed(reset = false) {
    if (reset) state.page = 1;
    const container = el("feedContainer");

    if (state.feedType === "following" && !state.user) {
      destroyHlsInstances();
      container.innerHTML = `
        <div class="card empty-state">
          <h3>Sign in to see your Following feed</h3>
          <p class="muted">Reels from creators you follow in MySQL appear here.</p>
          <button id="feedSignInCta" class="btn btn-primary" type="button">Sign In</button>
        </div>
      `;
      el("feedSignInCta")?.addEventListener("click", () => openAuthModal("password"));
      el("feedPagination").classList.add("hidden");
      return;
    }

    const endpoint = state.feedType === "following" ? "/api/feed/following" : "/api/feed/for-you";
    const params = new URLSearchParams({
      page: String(state.page),
      page_size: "12",
    });
    if (state.category) params.set("category", state.category);
    if (state.query) params.set("q", state.query);

    try {
      const data = await apiFetch(`${endpoint}?${params.toString()}`);
      if (reset) {
        destroyHlsInstances();
        container.innerHTML = "";
      }

      if (!data.videos.length && state.page === 1) {
        container.innerHTML = `
          <div class="card empty-state">
            <h3>No reels in MySQL yet</h3>
            <p class="muted">Sign in above and upload your first real video to start streaming HLS &amp; H.264 reels.</p>
          </div>
        `;
      } else {
        data.videos.forEach((video) => appendReelCard(container, video));
      }

      state.hasMore = Boolean(data.hasMore);
      el("feedPagination").classList.toggle("hidden", !state.hasMore);
    } catch (err) {
      showToast(err.message);
    }
  }

  function appendReelCard(container, video) {
    const card = document.createElement("article");
    card.className = "reel-card";
    const isMine = state.user && state.user.id === video.authorId;
    const streamBadge = video.hlsUrl ? "HLS Adaptive" : `MP4 (${video.transcodingStatus})`;
    const initial = (video.authorName || "T").slice(0, 1).toUpperCase();

    card.innerHTML = `
      <div class="reel-player-wrap">
        <video class="reel-video" controls playsinline preload="metadata" poster="${escapeHtml(video.thumbnailUrl || "")}"></video>
        <span class="reel-status-pill">${escapeHtml(streamBadge)}</span>
      </div>
      <div class="reel-body">
        <div class="reel-author-row">
          <div class="reel-author-info">
            ${
              video.authorAvatar
                ? `<img src="${escapeHtml(video.authorAvatar)}" alt="" class="mini-avatar">`
                : `<div class="mini-avatar">${escapeHtml(initial)}</div>`
            }
            <div>
              <strong>${escapeHtml(video.authorName)}</strong>
              <div class="muted small">@${escapeHtml(video.authorUsername)}</div>
            </div>
          </div>
          ${
            isMine
              ? `<button class="btn btn-danger btn-sm delete-reel-btn" type="button">Delete</button>`
              : `<button class="btn btn-secondary btn-sm follow-author-btn" type="button">${video.isFollowingAuthor ? "Following" : "Follow"}</button>`
          }
        </div>

        <p class="reel-caption">${escapeHtml(video.caption || "Untitled Reel")}</p>

        <div class="reel-meta">
          <span class="pill">${escapeHtml(video.category)}</span>
          ${video.snapLensName ? `<span class="pill">Lens: ${escapeHtml(video.snapLensName)}</span>` : ""}
          ${video.musicTitle ? `<span class="pill">&#9835; ${escapeHtml(video.musicTitle)}</span>` : ""}
          <span class="pill" data-views-for="${escapeHtml(video.id)}">${video.views} views</span>
        </div>

        <div class="reel-actions">
          <div class="action-group">
            <button class="btn btn-ghost btn-sm like-btn ${video.isLiked ? "liked" : ""}" type="button">
              &#9829; <span class="like-count">${video.likes}</span>
            </button>
            <button class="btn btn-ghost btn-sm comments-btn" type="button">
              Comments (<span class="comment-count">${video.commentsCount}</span>)
            </button>
          </div>
          ${
            video.allowDownloads
              ? `<a href="${escapeHtml(video.videoUrl)}" download class="btn btn-ghost btn-sm">Download</a>`
              : ""
          }
        </div>
      </div>
    `;

    const videoEl = card.querySelector("video");
    attachVideoSource(videoEl, video);

    let viewRecorded = false;
    videoEl.addEventListener("play", async () => {
      if (viewRecorded) return;
      viewRecorded = true;
      try {
        const res = await apiFetch(`/api/videos/${encodeURIComponent(video.id)}/view`, {
          method: "POST",
        });
        const span = card.querySelector(`[data-views-for="${CSS.escape(video.id)}"]`);
        if (span) span.textContent = `${res.viewsCount} views`;
      } catch {
        // Non-blocking telemetry
      }
    });

    card.querySelector(".like-btn").addEventListener("click", async (e) => {
      if (!state.user) {
        openAuthModal("password");
        return;
      }
      const btn = e.currentTarget;
      try {
        const res = await apiFetch(`/api/videos/${encodeURIComponent(video.id)}/like`, {
          method: "POST",
        });
        btn.classList.toggle("liked", res.isLiked);
        btn.querySelector(".like-count").textContent = String(res.likesCount);
      } catch (err) {
        showToast(err.message);
      }
    });

    card.querySelector(".comments-btn").addEventListener("click", () => openCommentsDrawer(video));

    const followBtn = card.querySelector(".follow-author-btn");
    if (followBtn) {
      followBtn.addEventListener("click", () =>
        toggleFollow(video.authorId, video.isFollowingAuthor ? "following" : "notFollowing")
      );
    }

    const deleteBtn = card.querySelector(".delete-reel-btn");
    if (deleteBtn) {
      deleteBtn.addEventListener("click", async () => {
        if (!window.confirm("Delete this reel from MySQL and storage?")) return;
        try {
          await apiFetch(`/api/videos/${encodeURIComponent(video.id)}`, { method: "DELETE" });
          showToast("Reel deleted");
          await loadFeed(true);
        } catch (err) {
          showToast(err.message);
        }
      });
    }

    if (video.transcodingStatus === "pending" || video.transcodingStatus === "processing") {
      pollTranscodeStatus(video.id);
    }

    container.appendChild(card);
  }

  function attachVideoSource(videoEl, video) {
    if (video.hlsUrl && window.Hls && window.Hls.isSupported()) {
      const hls = new window.Hls();
      hls.loadSource(video.hlsUrl);
      hls.attachMedia(videoEl);
      state.hlsInstances.push(hls);
      return;
    }
    if (video.hlsUrl && videoEl.canPlayType("application/vnd.apple.mpegurl")) {
      videoEl.src = video.hlsUrl;
      return;
    }
    videoEl.src = video.videoUrl;
  }

  /* -------- Drawer: Comments & Follow Lists -------- */
  async function openCommentsDrawer(video) {
    state.activeCommentVideoId = video.id;
    el("drawerTitle").textContent = `Comments — ${video.authorName}`;
    el("commentForm").classList.toggle("hidden", !video.allowComments);
    el("drawerModal").classList.remove("hidden");
    await refreshComments(video.id);
  }

  async function refreshComments(videoId) {
    const body = el("drawerBody");
    try {
      const data = await apiFetch(`/api/videos/${encodeURIComponent(videoId)}/comments`);
      if (!data.comments.length) {
        body.innerHTML = `<div class="muted small">No comments yet. Be the first!</div>`;
        return;
      }
      body.innerHTML = data.comments
        .map(
          (c) => `
          <div class="comment-row">
            <div>
              <strong>@${escapeHtml(c.authorName)}</strong>
              <div>${escapeHtml(c.text)}</div>
            </div>
            <div class="action-group">
              <button class="btn btn-ghost btn-sm comment-like-btn ${c.isLiked ? "liked" : ""}" data-cid="${escapeHtml(c.id)}" type="button">&#9829; ${c.likes}</button>
              ${
                c.isMine
                  ? `<button class="btn btn-danger btn-sm comment-del-btn" data-cid="${escapeHtml(c.id)}" type="button">Del</button>`
                  : ""
              }
            </div>
          </div>
        `
        )
        .join("");

      body.querySelectorAll(".comment-like-btn").forEach((btn) => {
        btn.addEventListener("click", async () => {
          if (!state.user) return openAuthModal("password");
          await apiFetch(`/api/comments/${encodeURIComponent(btn.dataset.cid)}/like`, {
            method: "POST",
          });
          await refreshComments(videoId);
        });
      });

      body.querySelectorAll(".comment-del-btn").forEach((btn) => {
        btn.addEventListener("click", async () => {
          await apiFetch(`/api/comments/${encodeURIComponent(btn.dataset.cid)}`, {
            method: "DELETE",
          });
          await refreshComments(videoId);
          await loadFeed(true);
        });
      });
    } catch (err) {
      body.innerHTML = `<div class="muted small">${escapeHtml(err.message)}</div>`;
    }
  }

  async function openFollowDrawer(kind) {
    if (!state.user) return;
    state.activeCommentVideoId = null;
    el("commentForm").classList.add("hidden");
    el("drawerTitle").textContent = kind === "followers" ? "Followers" : "Following";
    el("drawerModal").classList.remove("hidden");

    const body = el("drawerBody");
    try {
      const data = await apiFetch(
        `/api/follows/${encodeURIComponent(state.user.id)}/${kind}`
      );
      if (!data.items.length) {
        body.innerHTML = `<div class="muted small">No ${kind} yet.</div>`;
        return;
      }
      body.innerHTML = data.items
        .map(
          (item) => `
          <div class="creator-item">
            <div class="creator-meta">
              <strong>${escapeHtml(item.userFullName || item.userName)}</strong>
              <span class="muted small">@${escapeHtml(item.userName)} &middot; ${escapeHtml(item.status)}</span>
            </div>
          </div>
        `
        )
        .join("");
    } catch (err) {
      body.innerHTML = `<div class="muted small">${escapeHtml(err.message)}</div>`;
    }
  }

  /* -------- Event Wiring -------- */
  function wireEvents() {
    el("openAuthBtn").addEventListener("click", () => openAuthModal("password"));
    el("sidebarSignInBtn").addEventListener("click", () => openAuthModal("password"));
    el("sidebarRegisterBtn").addEventListener("click", () => openAuthModal("register"));
    el("closeAuthModalBtn").addEventListener("click", closeAuthModal);
    el("closeDrawerBtn").addEventListener("click", () => el("drawerModal").classList.add("hidden"));

    document.querySelectorAll("[data-auth-tab]").forEach((btn) => {
      btn.addEventListener("click", () => switchAuthTab(btn.dataset.authTab));
    });

    el("logoutBtn").addEventListener("click", async () => {
      const refreshToken = localStorage.getItem(TOKEN_KEYS.refresh);
      try {
        await apiFetch("/api/auth/logout", {
          method: "POST",
          body: JSON.stringify({ refreshToken }),
        });
      } catch {
        // Always clear local session
      }
      clearTokens();
      state.user = null;
      renderAuthUI();
      showToast("Signed out");
      await loadFeed(true);
    });

    el("passwordLoginForm").addEventListener("submit", async (e) => {
      e.preventDefault();
      setAuthMessage("");
      try {
        const res = await apiFetch("/api/auth/login", {
          method: "POST",
          body: JSON.stringify({
            identifier: el("loginIdentifier").value.trim(),
            password: el("loginPassword").value,
            deviceInfo: navigator.userAgent.slice(0, 120),
          }),
        });
        await handleAuthenticatedResponse(res, `Welcome back, ${res.user.name}`);
      } catch (err) {
        setAuthMessage(err.message, true);
      }
    });

    el("sendEmailOtpForm").addEventListener("submit", async (e) => {
      e.preventDefault();
      setAuthMessage("");
      try {
        const res = await apiFetch("/api/auth/email/send-otp", {
          method: "POST",
          body: JSON.stringify({
            email: el("otpEmailInput").value.trim(),
            purpose: "login",
          }),
        });
        setAuthMessage(res.message, false);
      } catch (err) {
        setAuthMessage(err.message, true);
      }
    });

    el("verifyEmailOtpForm").addEventListener("submit", async (e) => {
      e.preventDefault();
      setAuthMessage("");
      try {
        const name = el("otpDisplayName").value.trim();
        const res = await apiFetch("/api/auth/email/verify-otp", {
          method: "POST",
          body: JSON.stringify({
            email: el("otpEmailInput").value.trim(),
            otp: el("otpCodeInput").value.trim(),
            purpose: "login",
            name: name || null,
            deviceInfo: navigator.userAgent.slice(0, 120),
          }),
        });
        await handleAuthenticatedResponse(res, "Email verified and signed in!");
      } catch (err) {
        setAuthMessage(err.message, true);
      }
    });

    el("registerForm").addEventListener("submit", async (e) => {
      e.preventDefault();
      setAuthMessage("");
      try {
        const res = await apiFetch("/api/auth/register", {
          method: "POST",
          body: JSON.stringify({
            name: el("regName").value.trim(),
            username: el("regUsername").value.trim(),
            email: el("regEmail").value.trim(),
            phoneNumber: el("regPhone").value.trim() || null,
            password: el("regPassword").value,
            sendVerificationOtp: el("regSendOtp").checked,
            deviceInfo: navigator.userAgent.slice(0, 120),
          }),
        });
        await handleAuthenticatedResponse(res, "Account created in MySQL!");
      } catch (err) {
        setAuthMessage(err.message, true);
      }
    });

    el("toggleEditProfileBtn").addEventListener("click", () => {
      el("editProfileForm").classList.toggle("hidden");
    });

    el("editProfileForm").addEventListener("submit", async (e) => {
      e.preventDefault();
      try {
        state.user = await apiFetch("/api/profiles/me", {
          method: "PATCH",
          body: JSON.stringify({
            name: el("editName").value.trim(),
            username: el("editUsername").value.trim(),
            bio: el("editBio").value.trim(),
            isPrivate: el("editPrivate").checked,
          }),
        });
        el("editProfileForm").classList.add("hidden");
        renderAuthUI();
        showToast("Profile saved to MySQL");
      } catch (err) {
        showToast(err.message);
      }
    });

    el("avatarFileInput").addEventListener("change", (e) =>
      uploadProfileMedia("avatar", e.target.files[0])
    );
    el("coverFileInput").addEventListener("change", (e) =>
      uploadProfileMedia("cover", e.target.files[0])
    );

    el("creatorSearchForm").addEventListener("submit", (e) => {
      e.preventDefault();
      searchCreators();
    });

    el("showFollowersBtn").addEventListener("click", () => openFollowDrawer("followers"));
    el("showFollowingBtn").addEventListener("click", () => openFollowDrawer("following"));

    el("videoFileInput").addEventListener("change", (e) => {
      const f = e.target.files[0];
      el("videoFileLabel").textContent = f
        ? `${f.name} (${(f.size / (1024 * 1024)).toFixed(1)} MB)`
        : "Select or drop video file (.mp4, .mov, .webm)";
    });

    el("thumbFileInput").addEventListener("change", (e) => {
      const f = e.target.files[0];
      el("thumbFileLabel").textContent = f ? f.name : "Optional Thumbnail";
    });

    const dz = el("videoDropzone");
    dz.addEventListener("dragover", (e) => {
      e.preventDefault();
      dz.classList.add("dragover");
    });
    dz.addEventListener("dragleave", () => dz.classList.remove("dragover"));
    dz.addEventListener("drop", (e) => {
      e.preventDefault();
      dz.classList.remove("dragover");
      if (e.dataTransfer.files.length) {
        el("videoFileInput").files = e.dataTransfer.files;
        el("videoFileInput").dispatchEvent(new Event("change"));
      }
    });

    el("videoUploadForm").addEventListener("submit", async (e) => {
      e.preventDefault();
      if (!state.user) {
        openAuthModal("password");
        return;
      }
      const videoFile = el("videoFileInput").files[0];
      if (!videoFile) {
        showToast("Please choose a video file first");
        return;
      }

      const formData = new FormData();
      formData.append("video", videoFile);
      const thumbFile = el("thumbFileInput").files[0];
      if (thumbFile) formData.append("thumbnail", thumbFile);
      formData.append("caption", el("uploadCaption").value.trim());
      formData.append("category", el("uploadCategory").value);
      formData.append("audience", el("uploadAudience").value);
      formData.append("snap_lens_name", el("uploadSnapLens").value.trim());
      formData.append("music_title", el("uploadMusic").value.trim());
      formData.append("allow_comments", String(el("uploadAllowComments").checked));
      formData.append("allow_downloads", String(el("uploadAllowDownloads").checked));

      el("uploadSubmitBtn").disabled = true;
      el("uploadProgressWrap").classList.remove("hidden");
      el("uploadProgressFill").style.width = "0%";
      el("uploadStatusText").textContent = "Starting upload...";

      try {
        const created = await uploadVideoWithProgress(formData);
        el("uploadProgressFill").style.width = "100%";
        el("uploadStatusText").textContent = `Uploaded! Transcoding status: ${created.transcodingStatus}`;
        el("videoUploadForm").reset();
        el("videoFileLabel").textContent = "Select or drop video file (.mp4, .mov, .webm)";
        el("thumbFileLabel").textContent = "Optional Thumbnail";
        showToast("Reel saved to MySQL — FFmpeg transcoding started");
        await loadFeed(true);
        if (created.transcodingStatus === "pending" || created.transcodingStatus === "processing") {
          pollTranscodeStatus(created.id);
        }
      } catch (err) {
        el("uploadStatusText").textContent = err.message;
        showToast(err.message);
      } finally {
        el("uploadSubmitBtn").disabled = false;
      }
    });

    document.querySelectorAll("[data-feed]").forEach((btn) => {
      btn.addEventListener("click", () => {
        state.feedType = btn.dataset.feed;
        document.querySelectorAll("[data-feed]").forEach((b) =>
          b.classList.toggle("active", b === btn)
        );
        loadFeed(true);
      });
    });

    el("feedFilterForm").addEventListener("submit", (e) => {
      e.preventDefault();
      state.category = el("feedCategoryFilter").value;
      state.query = el("feedQueryInput").value.trim();
      loadFeed(true);
    });

    el("loadMoreBtn").addEventListener("click", () => {
      if (!state.hasMore) return;
      state.page += 1;
      loadFeed(false);
    });

    el("commentForm").addEventListener("submit", async (e) => {
      e.preventDefault();
      if (!state.user) return openAuthModal("password");
      const text = el("commentInput").value.trim();
      if (!text || !state.activeCommentVideoId) return;
      try {
        await apiFetch(`/api/videos/${encodeURIComponent(state.activeCommentVideoId)}/comments`, {
          method: "POST",
          body: JSON.stringify({ text }),
        });
        el("commentInput").value = "";
        await refreshComments(state.activeCommentVideoId);
        await loadFeed(true);
      } catch (err) {
        showToast(err.message);
      }
    });
  }

  document.addEventListener("DOMContentLoaded", async () => {
    wireEvents();
    await loadHealth();
    await bootstrapSession();
    await Promise.all([loadFeed(true), searchCreators()]);
  });
})();
