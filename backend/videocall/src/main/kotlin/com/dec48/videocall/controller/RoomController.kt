package com.dec48.videocall.controller

import com.dec48.videocall.model.RoomStats
import com.dec48.videocall.service.RoomService
import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/rooms")
@CrossOrigin(origins = ["*"])
class RoomController(private val roomService: RoomService) { //Constructor Syntax :)
    @GetMapping
    fun getActiveRooms(): ResponseEntity<List<RoomStats>> {
        return ResponseEntity.ok(roomService.getAllRoomStats())
    }

    @GetMapping("/{roomId}")
    fun getRoomStats(@PathVariable roomId: String): ResponseEntity<RoomStats> {
        val roomStats = roomService.getRoomStats(roomId)
            ?: throw NoSuchElementException("Room $roomId not found")
        return ResponseEntity.ok(roomStats)
    }

    @PostMapping //to ensure that the room has been created
    fun createRoom(authentication: Authentication): ResponseEntity<Map<String, String>> {
        // this should be used with authentication somehow
        val userId = authentication.name // thx to the spring security wow
        val newRoomId = roomService.createRoom()
        println("User $userId is creating room $newRoomId")
        return ResponseEntity.ok(mapOf("roomId" to newRoomId))
    }
}