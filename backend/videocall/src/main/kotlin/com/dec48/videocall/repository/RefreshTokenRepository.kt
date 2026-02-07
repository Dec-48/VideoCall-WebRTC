package com.dec48.videocall.repository

import com.dec48.videocall.model.RefreshToken
import org.springframework.stereotype.Repository

@Repository
class RefreshTokenRepository {
    private val refreshTokens = ArrayList<RefreshToken>()
    fun findByUserIdAndHashedToken(userId: Int, hashedToken: String): RefreshToken? {
        val refreshToken = refreshTokens.find { it.userId == userId && it.hashedToken == hashedToken }
        return refreshToken
    }
    fun deleteByUserIdAndHashedToken(userId: Int, hashedToken: String) : Boolean {
        return refreshTokens.removeIf { it.userId == userId && it.hashedToken == hashedToken }
    }
}