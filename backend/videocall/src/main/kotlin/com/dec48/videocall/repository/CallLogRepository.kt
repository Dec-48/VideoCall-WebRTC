package com.dec48.videocall.repository

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository

@Repository
interface CallLogRepository : JpaRepository<CallLog, Long> {
    @Query("select c from CallLog c where c.roomId = :roomId")
    fun findByRoomId(roomId: String): List<CallLog> //Handled by JPA's query derivation, even without the @Query annotation
}