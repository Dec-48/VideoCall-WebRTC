package com.dec48.videocall.model

data class User (
    val username: String,
    val hashedPassword: String,
    val id: Int
)