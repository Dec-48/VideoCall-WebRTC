package com.dec48.videocall.model

data class User (
    val email: String,
    val hashedPassword: String,
    val id: Int
)