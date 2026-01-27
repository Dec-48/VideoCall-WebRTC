package com.dec48.videocall.repository

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface CallLogRepository : JpaRepository<CallLog, Long> {
    fun findByRoomId(roomId: String): List<CallLog> // handled by the JPA's query derivation
}