package com.dec48.videocall.exception

import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice
import org.springframework.web.server.ResponseStatusException
import java.time.Instant

@RestControllerAdvice
class GlobalExceptionHandler {

    data class ErrorResponse(
        val timestamp: Instant = Instant.now(),
        val status: Int,
        val error: String,
        val message: String?
    )

    @ExceptionHandler(NoSuchElementException::class) // reflection....magic
    fun handleNotFound(ex: NoSuchElementException): ResponseEntity<ErrorResponse> {
        return buildResponse(HttpStatus.NOT_FOUND, ex.message)
    }

    @ExceptionHandler(BadCredentialsException::class)
    fun handleAuthError(ex: BadCredentialsException): ResponseEntity<ErrorResponse> {
        return buildResponse(HttpStatus.UNAUTHORIZED, "Authentication failed: ${ex.message}")
    }

    @ExceptionHandler(ResponseStatusException::class)
    fun handleResponseStatus(ex: ResponseStatusException): ResponseEntity<ErrorResponse> {
        return buildResponse(HttpStatus.valueOf(ex.statusCode.value()), ex.reason)
    }

    @ExceptionHandler(Exception::class)
    fun handleGeneralError(ex: Exception): ResponseEntity<ErrorResponse> {
        return buildResponse(HttpStatus.INTERNAL_SERVER_ERROR, "An unexpected error occurred")
    }

    private fun buildResponse(status: HttpStatus, message: String?): ResponseEntity<ErrorResponse> {
        return ResponseEntity(
            ErrorResponse(status = status.value(), error = status.reasonPhrase, message = message), // body
            status // status
        )
    }
}