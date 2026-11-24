from __future__ import annotations
from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse


class AppError(Exception):
    """Base domain exception with structured HTTP response fields."""

    def __init__(self, message: str, status_code: int = 400, code: str = "bad_request") -> None:
        super().__init__(message)
        self.message = message
        self.status_code = status_code
        self.code = code


class BadRequestError(AppError):
    def __init__(self, message: str) -> None:
        super().__init__(message, status_code=400, code="bad_request")


class UnauthorizedError(AppError):
    def __init__(self, message: str = "Invalid credentials") -> None:
        super().__init__(message, status_code=401, code="unauthorized")


class ForbiddenError(AppError):
    def __init__(self, message: str = "You do not have permission to perform this action") -> None:
        super().__init__(message, status_code=403, code="forbidden")


class NotFoundError(AppError):
    def __init__(self, message: str = "Resource not found") -> None:
        super().__init__(message, status_code=404, code="not_found")


class ConflictError(AppError):
    def __init__(self, message: str) -> None:
        super().__init__(message, status_code=409, code="conflict")


class RateLimitError(AppError):
    def __init__(self, message: str) -> None:
        super().__init__(message, status_code=429, code="rate_limited")


class ServiceUnavailableError(AppError):
    def __init__(self, message: str) -> None:
        super().__init__(message, status_code=503, code="service_unavailable")


def register_exception_handlers(app: FastAPI) -> None:
    """Register unified JSON error responses compatible with both Flutter and web clients."""

    @app.exception_handler(AppError)
    async def handle_app_error(_: Request, exc: AppError) -> JSONResponse:
        return JSONResponse(
            status_code=exc.status_code,
            content={"error": exc.message, "detail": exc.message, "code": exc.code},
        )

    @app.exception_handler(HTTPException)
    async def handle_http_exception(_: Request, exc: HTTPException) -> JSONResponse:
        message = exc.detail if isinstance(exc.detail, str) else "Request failed"
        return JSONResponse(
            status_code=exc.status_code,
            content={"error": message, "detail": exc.detail, "code": f"http_{exc.status_code}"},
        )

    @app.exception_handler(RequestValidationError)
    async def handle_validation_error(_: Request, exc: RequestValidationError) -> JSONResponse:
        errors = exc.errors()
        first_msg = "Validation error"
        if errors:
            first = errors[0]
            loc = ".".join(str(part) for part in first.get("loc", []) if part != "body")
            msg = first.get("msg", "Invalid input")
            first_msg = f"{loc}: {msg}" if loc else msg
        return JSONResponse(
            status_code=422,
            content={"error": first_msg, "detail": errors, "code": "validation_error"},
        )

