package com.dec48.videocall.websocket

import com.dec48.videocall.models.SignalMessage
import org.springframework.context.annotation.Configuration
import org.springframework.web.socket.CloseStatus
import org.springframework.web.socket.TextMessage
import org.springframework.web.socket.WebSocketSession
import org.springframework.web.socket.config.annotation.EnableWebSocket
import org.springframework.web.socket.config.annotation.WebSocketConfigurer
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry
import org.springframework.web.socket.handler.TextWebSocketHandler
import tools.jackson.databind.ObjectMapper
import java.util.concurrent.ConcurrentHashMap

class SignalingHandler : TextWebSocketHandler() {

    //* session id -> room id
    private val roomIdMap = ConcurrentHashMap<String, String>()

    //* room id -> list<session>
    private val sessionsMap = ConcurrentHashMap<String, MutableList<WebSocketSession>>()
    private val objMapper = ObjectMapper()
    private val validTypes = setOf("join", "offer", "candidate", "answer")

    override fun handleTextMessage(session: WebSocketSession, message: TextMessage) {
        try {
            val signalMessage = objMapper.readValue(message.payload, SignalMessage::class.java) ?: return
            if (!validTypes.contains(signalMessage.type)) return

            if (signalMessage.type == "join") { // join to specific room
                val roomId = signalMessage.roomId
                if (roomId != null) {
                    roomIdMap[session.id] = roomId
                    sessionsMap.computeIfAbsent(roomId) { ArrayList() }.add(session)
                }
            } else { // broadcast to everyone in the same room except myself
                val roomId = roomIdMap[session.id] // roomId shouldn't be null right here
                if (roomId != null) {
                    val clients = sessionsMap[roomId] // clients shouldn't null right here too
                    if (clients != null) {
                        for (client in clients) {
                            if (client.isOpen && client.id != session.id) {
                                println("${client.id} -> ${message.payload} ")
                                client.sendMessage(message) // forward the message
                            }
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
        println("New Connection: ${session.id}")
    }

    override fun afterConnectionClosed(session: WebSocketSession, status: CloseStatus) {
        val roomId = roomIdMap.remove(session.id)
        if (roomId != null) { // delete it!!!
            sessionsMap[roomId]?.remove(session)
            if (sessionsMap[roomId]?.isEmpty() == true) {
                sessionsMap.remove(roomId) // clear out the empty room
            }
        }
        println("Disconnected: ${session.id}")
    }
}

@Configuration
@EnableWebSocket
class WSConfig : WebSocketConfigurer {
    override fun registerWebSocketHandlers(registry: WebSocketHandlerRegistry) {
        registry.addHandler(SignalingHandler(), "/socket").setAllowedOrigins("*")
    }
}