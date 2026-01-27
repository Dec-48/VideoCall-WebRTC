package com.dec48.videocall.repository

import jakarta.persistence.*
import org.hibernate.annotations.CreationTimestamp
import java.time.LocalDateTime

@Entity
@Table(name = "call_log")
class CallLog(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long? = null,

    @Column(nullable = false)
    val clientId: String = "",

    @Column(nullable = false)
    val roomId: String = "",

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    val startTime: LocalDateTime? = null
)