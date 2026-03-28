from http import HTTPStatus

from starlette.responses import JSONResponse

from .errors import ResourceNotFoundError, ResourceAlreadyExistsError, InvalidCredentialsError


def not_found_handler(_, ex: ResourceNotFoundError):
    return JSONResponse(status_code=HTTPStatus.NOT_FOUND, content={"errorMsg": str(ex)})

def already_exist_handler(_, ex: ResourceAlreadyExistsError):
    return JSONResponse(status_code=HTTPStatus.BAD_REQUEST,content={"errorMsg": str(ex)})

def invalid_credentials_handler(_, ex: InvalidCredentialsError):
    return JSONResponse(status_code=HTTPStatus.BAD_REQUEST,content={"errorMsg": str(ex)})
