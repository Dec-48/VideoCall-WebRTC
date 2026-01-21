package com.dec48.videocall.service

import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.mockito.Mockito.`when`
import org.mockito.Mockito.mock
import org.springframework.web.socket.WebSocketSession

class RoomServiceTest {

    private val roomService = RoomService()

    @Test
    fun `should not allow more than 2 people in a room`() {
        val roomId = roomService.createRoom()
        val session1 = mock(WebSocketSession::class.java)
        `when`(session1.id).thenReturn("mock-id-1") // mock the session.id
        val session2 = mock(WebSocketSession::class.java)
        `when`(session2.id).thenReturn("mock-id-2")
        val session3 = mock(WebSocketSession::class.java)
        `when`(session3.id).thenReturn("mock-id-3")

        assertTrue(roomService.joinRoom(roomId, session1))
        assertTrue(roomService.joinRoom(roomId, session2))
        assertFalse(roomService.joinRoom(roomId, session3)) // Should return false because room is full
    }
}