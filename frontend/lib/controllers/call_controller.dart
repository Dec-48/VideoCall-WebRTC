import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frontend/models/signal_message.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CallController extends GetxController {
  RxBool isMuted = false.obs;
  RxBool isConnected = false.obs;
  RxBool isSocketReady = false.obs;
  RxBool isPeerConnectionReady = false.obs;

  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();
  MediaStream? localStream;
  RTCPeerConnection? peerConnection;
  WebSocketChannel? channel;

  final Queue<SignalMessage> messageQueue =
      Queue<SignalMessage>(); // buffer for all incoming message
  final Queue<RTCIceCandidate> candidateBuffer =
      Queue<RTCIceCandidate>(); // buffer for incoming ice candidate
  bool isProcessQueue = false;

  final String webSocketUrl = "ws://localhost:8080/socket";

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

    //* receiving track from other
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
    //* this fires immediately after we successfully set local desc
    peerConnection!.onIceCandidate = (candidate) {
      sendMessage(
        SignalMessage(type: "candidate", candidate: candidate.toMap()),
      );
    };

    isPeerConnectionReady.value = true;
  }

  void sendMessage(SignalMessage message) {
    channel?.sink.add(jsonEncode(message.toJson()));
  }

  void enqueueMessage(SignalMessage message) {
    messageQueue.add(message);
    if (!isProcessQueue) {
      processQueue();
    }
  }

  Future<void> processQueue() async {
    isProcessQueue = true;
    while (messageQueue.isNotEmpty) {
      final message = messageQueue.removeFirst();
      try {
        await computeMessage(message);
      } catch (e) {
        if (kDebugMode) print("Error processing ${message.type}: $e");
      }
    }
    isProcessQueue = false;
  }

  Future<void> flushCandidateBuffer() async {
    while (candidateBuffer.isNotEmpty) {
      try {
        final candidate = candidateBuffer.removeFirst();
        await peerConnection?.addCandidate(candidate);
      } catch (e) {
        if (kDebugMode) {
          print("Error on adding candidate");
        }
      }
    }
  }

  Future<void> computeMessage(SignalMessage message) async {
    switch (message.type) {
      case "offer": //* receiving offer
        if (message.sdp != null) {
          final Map<String, dynamic> desc = message.sdp!;
          await peerConnection!.setRemoteDescription(
            RTCSessionDescription(desc["sdp"], desc["type"]),
          );

          //* strictly add candidate to our peer connection after set remote desc
          await flushCandidateBuffer();

          RTCSessionDescription answerSdp = await peerConnection!
              .createAnswer();
          await peerConnection!.setLocalDescription(answerSdp);
          //* sending our sdp back
          sendMessage(SignalMessage(type: "answer", sdp: answerSdp.toMap()));
        }
        break;
      case "answer": //* receiving answer
        if (message.sdp != null) {
          final Map<String, dynamic> desc = message.sdp!;
          await peerConnection!.setRemoteDescription(
            RTCSessionDescription(desc["sdp"], desc["type"]),
          );

          //* strictly add candidate to our peer connection after set remote desc
          await flushCandidateBuffer();
        }
        break;
      case "candidate": // this will be run when other received our offer and found thier iceCandidate(path way)
        if (message.candidate != null && peerConnection != null) {
          final data = message.candidate!;
          final candidate = RTCIceCandidate(
            data["candidate"],
            data["sdpMid"],
            data["sdpMLineIndex"] ?? 0,
          );
          final currentRemoteDesc = await peerConnection
              ?.getRemoteDescription();
          if (currentRemoteDesc != null) {
            //* strictly add candidate to our peer connection after set remote desc
            await peerConnection!.addCandidate(candidate);
          } else {
            candidateBuffer.add(candidate);
          }
        }
        break;
    }
  }

  Future<void> joinRoom(String roomId) async {
    try {
      await setupPeerConnection();

      channel = WebSocketChannel.connect(Uri.parse(webSocketUrl));
      await channel!.ready;
      isSocketReady.value = true;

      sendMessage(SignalMessage(type: "join", roomId: roomId)); // join to room

      channel!.stream.listen(
        (event) {
          final message = SignalMessage.fromJson(jsonDecode(event));
          enqueueMessage(message);
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

  Future<void> startCall() async {
    if (peerConnection == null) {
      if (kDebugMode) {
        print("Peer Connection not ready, wait for initialization");
      }
      await setupPeerConnection();
    }

    if (!isSocketReady.value || channel == null) {
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
