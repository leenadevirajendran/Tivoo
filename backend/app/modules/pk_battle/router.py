from __future__ import annotations
from typing import Literal

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.core.security import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.modules.pk_battle.schemas import (
    PkAcceptRequest,
    PkBattleListResponse,
    PkBattleResponse,
    PkChallengeRequest,
    PkQueueJoinRequest,
    PkQueueMatchResponse,
    PkScoreRequest,
)
from app.modules.pk_battle.service import pk_battle_service

router = APIRouter(prefix="/api/pk", tags=["Real-Time PK Battle Engine"])


@router.post("/queue/join", response_model=PkQueueMatchResponse)
def join_pk_queue(
    payload: PkQueueJoinRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PkQueueMatchResponse:
    """Enter the atomic PK matchmaking queue or pair immediately with a waiting opponent."""
    return pk_battle_service.join_matchmaking_queue(db, current_user, payload)


@router.delete("/queue/leave", response_model=PkQueueMatchResponse)
def leave_pk_queue(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PkQueueMatchResponse:
    """Cancel waiting status in the PK matchmaking queue."""
    return pk_battle_service.leave_matchmaking_queue(db, current_user)


@router.post("/challenges", response_model=PkBattleResponse, status_code=status.HTTP_201_CREATED)
def create_pk_challenge(
    payload: PkChallengeRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PkBattleResponse:
    """Send a direct PK challenge to another creator."""
    return pk_battle_service.create_challenge(db, current_user, payload)


@router.post("/battles/{battle_id}/accept", response_model=PkBattleResponse)
def accept_pk_challenge(
    battle_id: str,
    payload: PkAcceptRequest | None = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PkBattleResponse:
    """Accept a PK challenge, start the round timer, and notify hosts/followers."""
    return pk_battle_service.accept_challenge(db, current_user, battle_id, payload)


@router.post("/battles/{battle_id}/decline", response_model=PkBattleResponse)
def decline_pk_challenge(
    battle_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PkBattleResponse:
    """Decline or withdraw a pending PK challenge."""
    return pk_battle_service.decline_challenge(db, current_user, battle_id)


@router.post("/battles/{battle_id}/score", response_model=PkBattleResponse)
def add_pk_battle_score(
    battle_id: str,
    payload: PkScoreRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PkBattleResponse:
    """Send gifts or points to a host during an active PK battle."""
    return pk_battle_service.add_score(db, current_user, battle_id, payload)


@router.post("/battles/{battle_id}/end", response_model=PkBattleResponse)
def end_pk_battle(
    battle_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PkBattleResponse:
    """Settle a battle and calculate final victory/defeat/draw from MySQL scores."""
    return pk_battle_service.end_battle(db, current_user, battle_id)


@router.get("/battles", response_model=PkBattleListResponse)
def list_pk_battles(
    status_filter: Literal["active", "pending", "ended", "all"] = Query(default="active"),
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=50),
    db: Session = Depends(get_db),
) -> PkBattleListResponse:
    """List PK battles from MySQL and auto-settle any whose round timer has expired."""
    return pk_battle_service.list_battles(
        db=db,
        status_filter=status_filter,
        page=page,
        page_size=page_size,
    )


@router.get("/battles/{battle_id}", response_model=PkBattleResponse)
def get_pk_battle(battle_id: str, db: Session = Depends(get_db)) -> PkBattleResponse:
    """Fetch live PK battle scores, countdown seconds remaining, and outcome."""
    return pk_battle_service.get_battle(db, battle_id)
