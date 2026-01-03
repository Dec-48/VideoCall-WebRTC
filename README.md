# Video Call

A real-time video calling application using **WebRTC**.

### Try it out
1. **Host:** Creates a room and shares the **Room ID**.
2. **Partner:** Enters the Room ID to join.
3. **Start:** presses the **video camera button** to begin the video stream.

> **Note:** This project supports **1-on-1** calls only.\
> **Caution:** To resolve ICE candidate race conditions problem (i guess) The implementation forced renegotiation (sending the offer twice) this prevent initial black screen issue by ensuring that video tracks are properly attached to peerConnection

## Frameworks
* **Frontend:** Flutter (FlutterWebRTC + GetX)
* **Backend:** Spring Boot Kotlin (WebSocket for Signaling)

## Screenshots

| Create / Join   | Video Call |
|:---:|:---:|
| <img src="pictures/join_page.jpg" width="100%" /> | <img src="pictures/call_page.jpg" width="100%" /> |