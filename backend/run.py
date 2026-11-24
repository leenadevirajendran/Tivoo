import uvicorn

from app.core.config import get_settings


def main() -> None:
    """Start the Tivoo FastAPI server using .env host, port, and debug reload settings."""
    settings = get_settings()
    uvicorn.run(
        "app.main:app",
        host=settings.api_host,
        port=settings.api_port,
        reload=settings.app_debug,
    )


if __name__ == "__main__":
    main()

