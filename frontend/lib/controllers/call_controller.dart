import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frontend/models/signal_message.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CallController extends GetxController {
  RxBool isMuted = false.obs;
  RxBool isConnected = false.obs;

  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();
  MediaStream? localStream;
  RTCPeerConnection? peerConnection;
  WebSocketChannel? channel;

  final String webSocketUrl = "ws://localhost:8080/socket";
  bool isSocketReady = false;

  @override
  void onClose() {
    localRenderer.srcObject?.getTracks().forEach((track) => track.stop());
    remoteRenderer.srcObject?.getTracks().forEach((track) => track.stop());
    localRenderer.dispose();
    remoteRenderer.dispose();
    localStream?.dispose();
    peerConnection?.close();
    channel?.sink.close();
    super.onClose();
  }

  void sendMessage(SignalMessage message) {
    channel?.sink.add(jsonEncode(message.toJson()));
  }

  Future<void> joinRoom(String roomId) async {
    try {
      await setupPeerConnection();

      channel = WebSocketChannel.connect(Uri.parse(webSocketUrl));
      await channel!.ready;
      isSocketReady = true;

      sendMessage(SignalMessage(type: "join", roomId: roomId)); // join to room

      channel!.stream.listen(
        (event) {
          final message = SignalMessage.fromJson(jsonDecode(event));
          onMessage(message);
        },
        onError: (error) {
          if (kDebugMode) {
            print("Socket Error (onError): $error");
          }
        },
        onDone: () {
          if (kDebugMode) {
            print("Socket Closed");
          }
          isConnected.value = false;
        },
      );
    } catch (error) {
      if (kDebugMode) {
        print("Socket Error (catch): $error");
      }
    }
  }

  Future<void> onMessage(SignalMessage message) async {
    switch (message.type) {
      case "offer": //* recieving offer
        if (message.sdp != null) {
          final Map<String, dynamic> desc = message.sdp!;
          await peerConnection!.setRemoteDescription(
            RTCSessionDescription(desc["sdp"], desc["type"]),
          );
          RTCSessionDescription answerSdp = await peerConnection!
              .createAnswer();
          await peerConnection!.setLocalDescription(answerSdp);

          //* sending our sdp back
          sendMessage(SignalMessage(type: "answer", sdp: answerSdp.toMap()));
        }
        break;
      case "answer": //* recieving answer
        if (message.sdp != null) {
          final Map<String, dynamic> desc = message.sdp!;
          await peerConnection!.setRemoteDescription(
            RTCSessionDescription(desc["sdp"], desc["type"]),
          );
        }
        break;
      case "candidate": // this will be run when other recieved our offer and found thier iceCandidate(path way)
        if (message.candidate != null && peerConnection != null) {
          final candidate = message.candidate!;
          await peerConnection!.addCandidate(
            RTCIceCandidate(
              candidate["candidate"],
              candidate["spdMid"],
              candidate["spdMLineIndex"],
            ),
          );
        }
        break;
    }
  }

  Future<void> setupPeerConnection() async {
    if (peerConnection != null) return; // already setup
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    localStream = await mediaDevices.getUserMedia({
      "audio": true,
      "video": {"facingMode": "user", "width": 640, "height": 480},
    });
    localRenderer.srcObject = localStream;

    final Map<String, dynamic> configuration = {
      'iceServers': [
        {
          'urls': [
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302',
          ],
        },
      ],
    };
    peerConnection = await createPeerConnection(configuration);

    //* adding our track to connection
    localStream!.getTracks().forEach((track) {
      peerConnection!.addTrack(track, localStream!);
    });

    //* recieving track from other
    peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
        Future.delayed(
          // add a little bit delay
          const Duration(milliseconds: 100),
          () => isConnected.value = true,
        );
      }
    };

    //* sending our candidate(path way) to other
    peerConnection!.onIceCandidate = (candidate) {
      sendMessage(
        SignalMessage(type: "candidate", candidate: candidate.toMap()),
      );
    };
  }

  Future<void> startCall() async {
    if (peerConnection == null) {
      if (kDebugMode) {
        print("Peer Connection not ready, wait for initialization");
      }
      await setupPeerConnection();
    }

    if (!isSocketReady || channel == null) {
      if (kDebugMode) {
        print("Socket not ready yet. Please wait.");
        return;
      }
    }

    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);

    //* sending offer to other
    sendMessage(SignalMessage(type: "offer", sdp: offer.toMap()));
  }

  void toggleMic() {
    isMuted.value = !(isMuted.value);
    if (localStream != null) {
      localStream!.getAudioTracks()[0].enabled = !isMuted.value;
    }
  }
}
