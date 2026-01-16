package com.dec48.videocall.model

data class RoomStats(
    val roomId: String,
    val userCount: Int,
    val isFull: Boolean
)
