package com.dec48.videocall.controller

import com.dec48.videocall.model.RoomStats
import com.dec48.videocall.service.RoomService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.CrossOrigin
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.server.ResponseStatusException

@RestController
@RequestMapping("/api/rooms")
@CrossOrigin(origins = ["*"])
class RoomController(private val roomService: RoomService) { //Constructor Syntax :)
    @GetMapping
    fun getActiveRooms(): ResponseEntity<List<RoomStats>> {
        return ResponseEntity.ok(roomService.getAllRoomStats())
    }

    @GetMapping("/{roomId}")
    fun getRoomStats(@PathVariable roomId: String) : ResponseEntity<RoomStats> {
        val roomStats = roomService.getRoomStats(roomId) ?: throw ResponseStatusException(
            HttpStatus.NOT_FOUND,
            mapOf("error" to "Room not found").toString()
        )
        return ResponseEntity.ok(roomStats)
    }

    @PostMapping //to ensure that the room has been created
    fun createRoom(): ResponseEntity<Map<String, String>> {
        // this one should include sessionId or whatever that can classify this client from other
        // for instance, Authentication(login logout)
        val newRoomId = roomService.createRoom()
        return ResponseEntity.ok(mapOf("roomId" to newRoomId))
    }
}