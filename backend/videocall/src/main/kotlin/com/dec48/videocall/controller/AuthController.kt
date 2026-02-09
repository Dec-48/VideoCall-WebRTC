package com.dec48.videocall.controller

import com.dec48.videocall.model.User
import com.dec48.videocall.security.AuthService
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.CrossOrigin
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping

@Controller
@RequestMapping("/api/auth")
@CrossOrigin(origins = ["*"])
class AuthController(
    private val authService: AuthService
) {
    data class AuthRequest(val email: String, val password: String)
    data class RefreshRequest(val refreshToken: String)

    @PostMapping("/register")
    fun register(@RequestBody request: AuthRequest): ResponseEntity<User> {
        val user = authService.register(request.email, request.password)
        return ResponseEntity.ok(user)
    }

    @PostMapping("/login")
    fun login(@RequestBody request: AuthRequest): ResponseEntity<AuthService.TokenPair> {
        val tokens = authService.login(request.email, request.password)
        return ResponseEntity.ok(tokens)
    }

    @PostMapping("/refresh")
    fun refresh(@RequestBody request: RefreshRequest): ResponseEntity<AuthService.TokenPair> {
        val newTokens = authService.refresh(request.refreshToken)
        return ResponseEntity.ok(newTokens)
    }
}