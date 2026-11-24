from __future__ import annotations
from sqlalchemy import and_, func, or_, select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session, joinedload

from app.core.exceptions import BadRequestError, ForbiddenError, NotFoundError
from app.core.security import utc_now
from app.models.user import User
from app.modules.chat_realtime.models import DmConversation, DmMessage, LiveChatMessage
from app.modules.chat_realtime.schemas import (
    DmConversationResponse,
    DmInboxResponse,
    DmMessageResponse,
    DmSendRequest,
    DmThreadListResponse,
    LiveChatCreateRequest,
    LiveChatListResponse,
    LiveChatMessageResponse,
)
from app.modules.live_gateway.models import LiveRoom
from app.modules.notifications_fcm.service import notification_service
from app.realtime.connection_manager import realtime_hub


class ChatRealtimeService:
    """Persists and broadcasts live stream chat/barrage comments and 1-on-1 DMs."""

    @staticmethod
    def _serialize_live_msg(row: LiveChatMessage) -> LiveChatMessageResponse:
        sender = row.sender
        return LiveChatMessageResponse(
            id=row.id,
            roomId=row.room_id,
            senderId=row.sender_id,
            senderName=sender.name if sender else "Viewer",
            senderUsername=sender.username if sender else "viewer",
            senderAvatar=sender.avatar_url if sender else "",
            messageType=row.message_type,
            content=row.content,
            colorHex=row.color_hex,
            isPinned=row.is_pinned,
            createdAt=row.created_at,
        )

    @staticmethod
    def _serialize_dm_msg(row: DmMessage) -> DmMessageResponse:
        sender = row.sender
        return DmMessageResponse(
            id=row.id,
            conversationId=row.conversation_id,
            senderId=row.sender_id,
            recipientId=row.recipient_id,
            senderName=sender.name if sender else "Creator",
            senderUsername=sender.username if sender else "creator",
            senderAvatar=sender.avatar_url if sender else "",
            messageType=row.message_type,
            content=row.content,
            mediaUrl=row.media_url,
            isRead=row.is_read,
            readAt=row.read_at,
            createdAt=row.created_at,
        )

    def send_live_message(
        self,
        db: Session,
        room_id: str,
        sender: User,
        payload: LiveChatCreateRequest,
    ) -> LiveChatMessageResponse:
        room = db.get(LiveRoom, room_id)
        if not room or room.status == "ended":
            raise NotFoundError("Active live room not found")
        if not room.allow_chat:
            raise ForbiddenError("Chat is disabled in this live room")

        msg = LiveChatMessage(
            room_id=room.id,
            sender_id=sender.id,
            message_type=payload.messageType,
            content=payload.content.strip(),
            color_hex=payload.colorHex,
        )
        db.add(msg)
        db.commit()
        loaded = db.scalar(
            select(LiveChatMessage)
            .options(joinedload(LiveChatMessage.sender))
            .where(LiveChatMessage.id == msg.id)
        )
        serialized = self._serialize_live_msg(loaded)
        event_name = "live_barrage" if payload.messageType == "barrage" else "live_chat"
        realtime_hub.broadcast_room_sync(
            room.id,
            event_name,
            serialized.model_dump(mode="json"),
        )
        return serialized

    def list_live_messages(
        self,
        db: Session,
        room_id: str,
        limit: int = 50,
    ) -> LiveChatListResponse:
        room = db.get(LiveRoom, room_id)
        if not room:
            raise NotFoundError("Live room not found")
        rows = list(
            db.scalars(
                select(LiveChatMessage)
                .options(joinedload(LiveChatMessage.sender))
                .where(LiveChatMessage.room_id == room.id)
                .order_by(LiveChatMessage.created_at.desc())
                .limit(limit)
            ).all()
        )
        rows.reverse()
        return LiveChatListResponse(
            messages=[self._serialize_live_msg(r) for r in rows],
            total=len(rows),
        )

    @staticmethod
    def _get_or_create_conversation(db: Session, user_one_id: str, user_two_id: str) -> DmConversation:
        a, b = sorted((user_one_id, user_two_id))
        conv = db.scalar(
            select(DmConversation).where(
                and_(DmConversation.participant_a_id == a, DmConversation.participant_b_id == b)
            )
        )
        if conv:
            return conv
        try:
            with db.begin_nested():
                conv = DmConversation(participant_a_id=a, participant_b_id=b)
                db.add(conv)
                db.flush()
            return conv
        except IntegrityError:
            conv = db.scalar(
                select(DmConversation).where(
                    and_(DmConversation.participant_a_id == a, DmConversation.participant_b_id == b)
                )
            )
            if not conv:
                raise
            return conv

    def send_dm(
        self,
        db: Session,
        sender: User,
        recipient_id: str,
        payload: DmSendRequest,
    ) -> DmMessageResponse:
        if recipient_id == sender.id:
            raise BadRequestError("You cannot send a direct message to yourself")
        recipient = db.get(User, recipient_id)
        if not recipient or not recipient.is_active:
            raise NotFoundError("Recipient user not found")

        conv = self._get_or_create_conversation(db, sender.id, recipient.id)
        now = utc_now()
        clean_text = payload.content.strip()

        msg = DmMessage(
            conversation_id=conv.id,
            sender_id=sender.id,
            recipient_id=recipient.id,
            message_type=payload.messageType,
            content=clean_text,
            media_url=payload.mediaUrl.strip() if payload.mediaUrl else None,
            created_at=now,
        )
        db.add(msg)
        conv.last_message_text = clean_text[:300]
        conv.last_message_at = now
        db.commit()

        loaded = db.scalar(
            select(DmMessage)
            .options(joinedload(DmMessage.sender))
            .where(DmMessage.id == msg.id)
        )
        serialized = self._serialize_dm_msg(loaded)
        event_data = serialized.model_dump(mode="json")

        realtime_hub.send_to_user_sync(recipient.id, "dm_message", event_data)
        realtime_hub.send_to_user_sync(sender.id, "dm_message", event_data)
        notification_service.notify_dm_received(
            db=db,
            sender=sender,
            recipient_id=recipient.id,
            conversation_id=conv.id,
            preview_text=clean_text,
        )
        return serialized

    def list_conversations(self, db: Session, user: User) -> DmInboxResponse:
        rows = list(
            db.scalars(
                select(DmConversation)
                .options(
                    joinedload(DmConversation.participant_a),
                    joinedload(DmConversation.participant_b),
                )
                .where(
                    or_(
                        DmConversation.participant_a_id == user.id,
                        DmConversation.participant_b_id == user.id,
                    )
                )
                .order_by(DmConversation.last_message_at.desc())
            ).all()
        )
        if not rows:
            return DmInboxResponse(conversations=[], total=0)

        conv_ids = [r.id for r in rows]
        unread_rows = db.execute(
            select(DmMessage.conversation_id, func.count())
            .where(
                and_(
                    DmMessage.conversation_id.in_(conv_ids),
                    DmMessage.recipient_id == user.id,
                    DmMessage.is_read.is_(False),
                )
            )
            .group_by(DmMessage.conversation_id)
        ).all()
        unread_map = {cid: int(cnt) for cid, cnt in unread_rows}

        items: list[DmConversationResponse] = []
        for conv in rows:
            peer = conv.participant_b if conv.participant_a_id == user.id else conv.participant_a
            if not peer:
                continue
            items.append(
                DmConversationResponse(
                    id=conv.id,
                    peerId=peer.id,
                    peerName=peer.name,
                    peerUsername=peer.username,
                    peerAvatar=peer.avatar_url,
                    peerVerified=peer.is_verified,
                    peerOnline=peer.is_online,
                    lastMessage=conv.last_message_text,
                    lastMessageTime=conv.last_message_at,
                    unreadCount=unread_map.get(conv.id, 0),
                )
            )
        return DmInboxResponse(conversations=items, total=len(items))

    def list_dm_messages(
        self,
        db: Session,
        user: User,
        peer_id: str,
        page: int = 1,
        page_size: int = 30,
    ) -> DmThreadListResponse:
        peer = db.get(User, peer_id)
        if not peer or not peer.is_active:
            raise NotFoundError("Peer user not found")

        a, b = sorted((user.id, peer.id))
        conv = db.scalar(
            select(DmConversation).where(
                and_(DmConversation.participant_a_id == a, DmConversation.participant_b_id == b)
            )
        )
        if not conv:
            return DmThreadListResponse(
                conversationId="",
                messages=[],
                total=0,
                page=page,
                pageSize=page_size,
                hasMore=False,
            )

        now = utc_now()
        marked = db.execute(
            update(DmMessage)
            .where(
                and_(
                    DmMessage.conversation_id == conv.id,
                    DmMessage.recipient_id == user.id,
                    DmMessage.is_read.is_(False),
                )
            )
            .values(is_read=True, read_at=now)
        )
        if marked.rowcount:
            db.commit()
            realtime_hub.send_to_user_sync(
                peer.id,
                "dm_read",
                {"conversationId": conv.id, "readerId": user.id, "readAt": now.isoformat()},
            )

        total = int(
            db.scalar(
                select(func.count())
                .select_from(DmMessage)
                .where(DmMessage.conversation_id == conv.id)
            )
            or 0
        )
        rows = list(
            db.scalars(
                select(DmMessage)
                .options(joinedload(DmMessage.sender))
                .where(DmMessage.conversation_id == conv.id)
                .order_by(DmMessage.created_at.desc())
                .offset((page - 1) * page_size)
                .limit(page_size)
            ).all()
        )
        rows.reverse()
        return DmThreadListResponse(
            conversationId=conv.id,
            messages=[self._serialize_dm_msg(r) for r in rows],
            total=total,
            page=page,
            pageSize=page_size,
            hasMore=(page * page_size) < total,
        )

    def mark_conversation_read(
        self,
        db: Session,
        user: User,
        conversation_id: str,
    ) -> dict[str, int | str]:
        conv = db.get(DmConversation, conversation_id)
        if not conv or user.id not in (conv.participant_a_id, conv.participant_b_id):
            raise NotFoundError("Conversation not found")

        now = utc_now()
        res = db.execute(
            update(DmMessage)
            .where(
                and_(
                    DmMessage.conversation_id == conv.id,
                    DmMessage.recipient_id == user.id,
                    DmMessage.is_read.is_(False),
                )
            )
            .values(is_read=True, read_at=now)
        )
        db.commit()
        peer_id = conv.participant_b_id if conv.participant_a_id == user.id else conv.participant_a_id
        if res.rowcount:
            realtime_hub.send_to_user_sync(
                peer_id,
                "dm_read",
                {"conversationId": conv.id, "readerId": user.id, "readAt": now.isoformat()},
            )
        return {"conversationId": conv.id, "markedRead": int(res.rowcount or 0)}


chat_realtime_service = ChatRealtimeService()
