from __future__ import annotations
from collections.abc import Generator

from sqlalchemy import create_engine, text
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

from app.core.config import get_settings

settings = get_settings()

engine = create_engine(
    settings.database_url,
    pool_pre_ping=True,
    pool_recycle=1800,
    pool_size=settings.db_pool_size,
    max_overflow=settings.db_max_overflow,
    echo=settings.app_debug,
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


class Base(DeclarativeBase):
    """Base class for all SQLAlchemy MySQL models."""


def get_db() -> Generator[Session, None, None]:
    """Provide a scoped MySQL database session per HTTP request."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db() -> None:
    """Import all ORM models and create missing MySQL tables in `tivoo`."""
    import app.models.user  # noqa: F401
    import app.models.video  # noqa: F401
    import app.modules.chat_realtime.models  # noqa: F401
    import app.modules.leaderboards_vip.models  # noqa: F401
    import app.modules.live_gateway.models  # noqa: F401
    import app.modules.notifications_fcm.models  # noqa: F401
    import app.modules.pk_battle.models  # noqa: F401
    import app.modules.wallet_gifts.models  # noqa: F401

    Base.metadata.create_all(bind=engine)


def check_db_health() -> bool:
    """Verify live MySQL database connectivity."""
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        return True
    except Exception:
        return False

