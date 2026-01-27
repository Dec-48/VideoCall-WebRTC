package com.dec48.videocall.controller

import com.dec48.videocall.model.RoomStats
import com.dec48.videocall.repository.CallLog
import com.dec48.videocall.repository.CallLogRepository
import com.dec48.videocall.service.RoomService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/rooms")
@CrossOrigin(origins = ["*"])
class RoomController(
    private val roomService: RoomService,
    private val callLogRepository: CallLogRepository
) { //Constructor Syntax :)
    @GetMapping
    fun getActiveRooms(): ResponseEntity<List<RoomStats>> {
        return ResponseEntity.ok(roomService.getAllRoomStats())
    }

    @GetMapping("/{roomId}")
    fun getRoomStats(@PathVariable roomId: String): ResponseEntity<Any> {
        val roomStats = roomService.getRoomStats(roomId) ?: return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(mapOf("error" to "Room not found"))
        return ResponseEntity.ok(roomStats)
    }

    @GetMapping("log/{roomId}")
    fun getRoomLog(@PathVariable roomId: String) : ResponseEntity<List<CallLog>> {
        val logs = callLogRepository.findByRoomId(roomId)
        return ResponseEntity.ok(logs);
    }

    @PostMapping //to ensure that the room has been created
    fun createRoom(): ResponseEntity<Map<String, String>> {
        // this one should include sessionId or whatever that can classify this client from other
        // for instance, Authentication(login logout)
        val newRoomId = roomService.createRoom()
        return ResponseEntity.ok(mapOf("roomId" to newRoomId))
    }
}