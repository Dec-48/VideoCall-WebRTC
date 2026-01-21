package com.dec48.videocall

import com.dec48.videocall.service.RoomService
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.web.server.LocalServerPort
import org.springframework.web.socket.TextMessage
import org.springframework.web.socket.WebSocketSession
import org.springframework.web.socket.client.standard.StandardWebSocketClient
import org.springframework.web.socket.handler.TextWebSocketHandler
import java.util.concurrent.CompletableFuture
import java.util.concurrent.TimeUnit

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class SignalingIntegrationTest {

    @LocalServerPort
    var port: Int = 0 // this will be changed after LocalServerPort initialization

    @Autowired
    lateinit var roomService: RoomService

    @Test
    fun `should broadcast message to other user in same room`() {
        val actualRoomId = roomService.createRoom()

        val client = StandardWebSocketClient()
        val future = CompletableFuture<String>() // wrapper class to make string work with asynchronous thing

        val handlerB = object : TextWebSocketHandler() {
            override fun handleTextMessage(session: WebSocketSession, message: TextMessage) {
                future.complete(message.payload)
            }
        }

        val sessionB = client.execute(handlerB, "ws://localhost:$port/socket").get()
        val sessionA = client.execute(object : TextWebSocketHandler() {}, "ws://localhost:$port/socket").get()

        val joinMsg = """{"type":"join", "roomId":"$actualRoomId"}"""
        sessionA.sendMessage(TextMessage(joinMsg))
        sessionB.sendMessage(TextMessage(joinMsg))

        Thread.sleep(500)

        val offerMsg = """{"type":"offer", "roomId":"$actualRoomId", "data":"hello other guy...."}"""
        sessionA.sendMessage(TextMessage(offerMsg))

        val received = future.get(2, TimeUnit.SECONDS)
        assert(received.contains(offerMsg))
        println(received)
    }
}