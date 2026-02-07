package com.dec48.videocall.model

import java.time.Instant

data class RefreshToken(
    val userId: Int,
    val expiresAt: Instant,
    val hashedToken: String,
    val createdAt: Instant = Instant.now()
)