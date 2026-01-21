package com.dec48.videocall.controller

import com.dec48.videocall.service.RoomService
import org.junit.jupiter.api.Test
import org.mockito.Mockito.`when`
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest
import org.springframework.test.context.bean.override.mockito.MockitoBean
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.*

// check the api
@WebMvcTest(RoomController::class)
class RoomControllerTest{
    @Autowired
    lateinit var mockMvc: MockMvc

    @MockitoBean
    lateinit var roomService: RoomService

    @Test
    fun `should create a new room and return roomId`() {
        `when`(roomService.createRoom()).thenReturn("ABCDE")
        mockMvc.perform(post("/api/rooms"))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.roomId").value("ABCDE"))
    }

    @Test
    fun `should return 404 when room does not exist`() {
        `when`(roomService.getRoomStats("EMPTY")).thenReturn(null)
        mockMvc.perform(get("/api/rooms/EMPTY"))
            .andExpect(status().isNotFound)
            .andExpect(jsonPath("$.error").value("Room not found"))
    }
}