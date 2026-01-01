package com.dec48.videocall.models

data class SignalMessage(
    val type: String,
    val roomId: String? = null,
    val sdp: Map<String, Any>? = null,
    val candidate: Map<String, Any>? = null
)
