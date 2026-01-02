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
      body: Stack(
        children: [
          Obx(() {
            bool isConnectionReady =
                callController.isSocketReady.value &&
                callController.isPeerConnectionReady.value;
            if (isConnectionReady) {
              return buildRemoteFrame();
            } else {
              return const Center(
                child: Text(
                  "Setting up the connection...",
                  style: TextStyle(fontSize: 18),
                ),
              );
            }
          }),
          buildLocalFrame(),
        ],
      ),
    );
  }

  Stack buildRemoteFrame() {
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
                  SizedBox(height: 10,),
                  Text(
                    "Waiting for partner...",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }
        }),

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

  Positioned buildLocalFrame() {
    return Positioned(
      right: 20,
      top: 20,
      child: SizedBox(
        height: 90,
        width: 120,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepPurple, width: 2),
          ),
          child: RTCVideoView(
            callController.localRenderer,
            mirror: true,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
          ),
        ),
      ),
    );
  }
}
