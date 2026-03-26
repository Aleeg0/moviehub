from fastapi import FastAPI

from .errors import ResourceNotFoundError, ResourceAlreadyExistsError, InvalidCredentialsError
from .handlers import not_found_handler, already_exist_handler, invalid_credentials_handler


def register_error_handlers(app: FastAPI) -> None:
    app.add_exception_handler(ResourceNotFoundError, not_found_handler)
    app.add_exception_handler(ResourceAlreadyExistsError, already_exist_handler)
    app.add_exception_handler(InvalidCredentialsError, invalid_credentials_handler)