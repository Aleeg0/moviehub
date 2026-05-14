from fastapi import APIRouter
from fastapi.params import Depends
from pydantic import TypeAdapter
from starlette.websockets import WebSocket, WebSocketDisconnect

from src.schemas import HandleSeenMovieRequest, WSMsg, SeenMovieMsg, PingMsg, WSStatus, WSRes
from src.services import WSService
from src.services.deps import get_ws_service
from ..deps import get_user_id_ws

router = APIRouter()

ws_msg_adapter = TypeAdapter(WSMsg)

@router.websocket("/movie-tracking")
async def movie_tracking(
    websocket: WebSocket,
    user_id: int = Depends(get_user_id_ws),
    ws_service: WSService = Depends(get_ws_service)
):
    await websocket.accept()

    try:
        while True:
            data = await websocket.receive_json()

            try:
                msg = ws_msg_adapter.validate_python(data)

                match msg:
                    case PingMsg():
                        response = await ws_service.handle_ping_msg()
                    case SeenMovieMsg():
                        response = await ws_service.handle_seen_movie_msg(
                            HandleSeenMovieRequest(
                                user_id=user_id,
                                movie=msg.movie,
                                status=msg.status,
                                rating=msg.rating,
                                comment=msg.comment,
                            )
                        )
                    case _:
                        response = WSRes(status=WSStatus.UNKNOWN_ACTION)
            except Exception as e:
                print(e, flush=True)
                response = WSRes(status=WSStatus.BAD_MSG, message=str(e))

            await websocket.send_json(response.model_dump())
    except WebSocketDisconnect:
        print(f"User {user_id} disconnected", flush=True)