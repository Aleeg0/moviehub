class ApplicationError(Exception):
    pass

class ResourceNotFoundError(ApplicationError):
    pass

class ResourceAlreadyExistsError(ApplicationError):
    pass

class InvalidCredentialsError(ApplicationError):
    pass