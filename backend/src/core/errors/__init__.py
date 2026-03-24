from fastapi import FastAPI

from .errors import ResourceNotFoundError, ResourceAlreadyExistsError
from .handlers import not_found_handler, already_exist_handler


def register_error_handlers(app: FastAPI) -> None:
    app.add_exception_handler(ResourceNotFoundError, not_found_handler)
    app.add_exception_handler(ResourceAlreadyExistsError, already_exist_handler)