package com.dec48.videocall.service

import com.dec48.videocall.model.RoomStats
import org.springframework.stereotype.Service
import org.springframework.web.socket.WebSocketSession
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

@Service
class RoomService {
    //* session id -> room id
    private val roomIdMap = ConcurrentHashMap<String, String>()

    //* room id -> list<session>
    private val roomMap = ConcurrentHashMap<String, MutableList<WebSocketSession>>()

    fun createRoom(): String {
        var roomId: String
        do {
            roomId = UUID.randomUUID().toString().substring(0, 5).uppercase()
        } while (roomMap.containsKey(roomId)) // generating new roomId
        roomMap[roomId] = ArrayList()
        return roomId
    }

    fun joinRoom(roomId: String, client: WebSocketSession): Boolean {
        val room = roomMap[roomId] ?: return false // Room doesn't exist
        synchronized(room) {
            if (room.size >= 2) return false // full
            room.add(client)
        }
        roomIdMap[client.id] = roomId
        return true // success
    }

    fun removeClient(client: WebSocketSession): String ? {
        val roomId: String = roomIdMap.remove(client.id) ?: return null
        val room : MutableList<WebSocketSession>? = roomMap[roomId]

        if (room != null) {
            synchronized(room) {
                room.remove(client)
                if (room.isEmpty()) {
                    roomMap.remove(roomId)
                }
            }
        }
        return roomId
    }

    fun getRoom(roomId: String) : List<WebSocketSession> {
        return roomMap[roomId] ?: emptyList()
    }

    fun getRoomId(clientId: String) : String? {
        return roomIdMap[clientId]
    }

    fun getAllRoomStats() : List<RoomStats> {
        // .entries return a set of (k, v)
        return roomMap.entries.map { entry ->
            val roomId = entry.key
            val room = entry.value
            RoomStats(
                roomId,
                room.size,
                room.size >= 2
            )
        }
    }

    fun getRoomStats(roomId: String) : RoomStats? {
        val room = roomMap[roomId] ?: return null
        return RoomStats(
            roomId,
            room.size,
            room.size >= 2
        )
    }
}