package com.dec48.videocall.websocket

import com.dec48.videocall.model.SignalMessage
import com.dec48.videocall.service.RoomService
import org.springframework.context.annotation.Configuration
import org.springframework.stereotype.Component
import org.springframework.web.socket.CloseStatus
import org.springframework.web.socket.TextMessage
import org.springframework.web.socket.WebSocketSession
import org.springframework.web.socket.config.annotation.EnableWebSocket
import org.springframework.web.socket.config.annotation.WebSocketConfigurer
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry
import org.springframework.web.socket.handler.TextWebSocketHandler
import tools.jackson.databind.ObjectMapper

@Component                          //autowire right here
class SignalingHandler(private val roomService: RoomService) : TextWebSocketHandler() {

    private val objMapper = ObjectMapper()
    private val validTypes = setOf("join", "offer", "candidate", "answer")

    override fun handleTextMessage(session: WebSocketSession, message: TextMessage) {
        try {
            val signalMessage = objMapper.readValue(message.payload, SignalMessage::class.java) ?: return
            if (!validTypes.contains(signalMessage.type)) return

            if (signalMessage.type == "join") { // join to specific room
                val roomId = signalMessage.roomId
                if (roomId != null) {
                    val success = roomService.joinRoom(roomId, session)
                    if (success) println("WS: User ${session.id} joined room $roomId")
                    else println("WS: Join failed for ${session.id} (Room full or not found)")
                }
            } else { // broadcast to everyone in the same room except myself
                val roomId = roomService.getRoomId(session.id)
                if (roomId != null) {
                    val room = roomService.getRoom(roomId)
                    for (client in room) {
                        if (client.isOpen && client.id != session.id) { // except your self
                            client.sendMessage(message)
                        }
                    }
                }
            }
        } catch (e: Exception) {
            println("Error handling message: ${e.message}")
            e.printStackTrace()
        }
    }

    override fun afterConnectionEstablished(session: WebSocketSession) {
        println("WS: New Connection: ${session.id}")
    }

    override fun afterConnectionClosed(session: WebSocketSession, status: CloseStatus) {
        val roomId = roomService.removeClient(session)
        println("WS: Disconnected: ${session.id} (Room: $roomId)")
    }
}

@Configuration
@EnableWebSocket            // autowire right here
class WSConfig(private val signalingHandler: SignalingHandler) : WebSocketConfigurer {
    override fun registerWebSocketHandlers(registry: WebSocketHandlerRegistry) {
        registry.addHandler(signalingHandler, "/socket").setAllowedOrigins("*")
    }
}