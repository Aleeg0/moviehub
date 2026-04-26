from fastapi import Depends
from fastapi_mail import FastMail
from redis.asyncio import Redis

from src.core import get_redis, get_mail
from src.domain.repositories import UnitOfWork, TokenRepository, UserRepository, MovieRepository, UserMovieRepository
from src.domain.repositories.deps import get_unit_of_work, get_token_repository, get_user_repository, \
    get_movie_repository, get_user_movie_repository
from . import AuthService, MailService, MovieService, UserService, PdfService, WSService


def get_mail_service(
    fastmail: FastMail = Depends(get_mail)
) -> MailService:
    return MailService(
        fastmail=fastmail
    )

def get_auth_service(
    uow: UnitOfWork = Depends(get_unit_of_work),
    token_repo: TokenRepository = Depends(get_token_repository),
    user_repo: UserRepository = Depends(get_user_repository),
    redis: Redis = Depends(get_redis),
    mail_service: MailService = Depends(get_mail_service)
) -> AuthService:
    return AuthService(
        uow=uow,
        toke_repo=token_repo,
        user_repo=user_repo,
        redis=redis,
        mail_service=mail_service
    )

def get_movie_service(
    uow: UnitOfWork = Depends(get_unit_of_work),
    movie_repo: MovieRepository = Depends(get_movie_repository)
) -> MovieService:
    return MovieService(
        uof=uow,
        movie_repo=movie_repo
    )

def get_user_service(
    uow: UnitOfWork = Depends(get_unit_of_work),
    user_movie_repo: UserMovieRepository = Depends(get_user_movie_repository)
) -> UserService:
    return UserService(
        uow=uow,
        user_movie_repo=user_movie_repo
    )

def get_pdf_service() -> PdfService:
    return PdfService()

def get_ws_service(
    user_service: UserService = Depends(get_user_service),
    movie_service: MovieService = Depends(get_movie_service),
) -> WSService:
    return WSService(
        user_service=user_service,
        movie_service=movie_service,
    )