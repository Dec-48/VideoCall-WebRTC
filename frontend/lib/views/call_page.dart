import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:frontend/controllers/call_controller.dart';
import 'package:get/get.dart';

class CallPage extends StatefulWidget {
  final String roomId;
  const CallPage({super.key, required this.roomId});

  @override
  State<CallPage> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallPage> {
  late final String roomId = widget.roomId;
  final callController = Get.put(CallController());

  @override
  void initState() {
    super.initState();
    callController.joinRoom(roomId);
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<CallController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Room : $roomId")),
      body: Obx(() {
        if (callController.isSocketReady.value &&
            callController.isPeerConnectionReady.value) {
          return buildCallPage();
        } else {
          return const Center(
            child: Text(
              "Connection not ready...",
              style: TextStyle(fontSize: 18),
            ),
          );
        }
      }),
    );
  }

  Stack buildCallPage() {
    return Stack(
      children: [
        Obx(() {
          if (callController.isConnected.value) {
            return RTCVideoView(
              callController.remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Waiting for partner...",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            );
          }
        }),

        Positioned(
          right: 20,
          top: 20,
          child: SizedBox(
            height: 125,
            width: 140,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple),
              ),
              child: RTCVideoView(
                callController.localRenderer,
                mirror: true,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: () => callController.startCall(),
                child: const Icon(Icons.videocam),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
