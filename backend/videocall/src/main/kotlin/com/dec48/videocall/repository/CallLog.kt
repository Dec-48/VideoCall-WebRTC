package com.dec48.videocall.repository

import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "call_log")
class CallLog(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long? = null,
    val clientId: String = "",
    val roomId: String = "",
    val startTime: LocalDateTime = LocalDateTime.now()
)