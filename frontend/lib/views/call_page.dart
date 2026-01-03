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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          //* 1. Remote Video
          Positioned.fill(
            child: Obx(() {
              if (callController.isConnected.value) {
                return RTCVideoView(
                  callController.remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                );
              } else {
                return buildWaitingScreen(context);
              }
            }),
          ),

          //* 2. Local Video
          Positioned(
            right: 35,
            top: 35,
            child: Container( // shadow
              width: 140,
              height: 105,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect( // clip the corner
                borderRadius: BorderRadius.circular(15),
                child: RTCVideoView(
                  callController.localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
          ),

          //* 3. Control Bar
          Positioned(
            bottom: 30,
            left: 0, right: 0 ,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[900]!.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, // 
                  children: [
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white24,
                        foregroundColor: Colors.white
                      ),
                      icon: Icon(Icons.mic),
                      onPressed: callController.toggleMic,
                    ),
                    SizedBox(width: 20,),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white
                      ),
                      icon: Icon(Icons.video_call),
                      onPressed: callController.startCall,
                      // color: Colors.green,
                    ),
                    SizedBox(width: 20,),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white
                      ),
                      icon: Icon(Icons.call_end),
                      onPressed: Get.back,
                    )
                  ],
                ),
              ),
            ),
          ),

          //* 4. Room Id
          Positioned(
            top: 35,
            left: 35,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "ID: $roomId",
                style: const TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWaitingScreen(BuildContext context) {
    return Container(
      color: Colors.blueGrey[900],
      child: Center(
        child: Obx(() {
          bool isPcAndSocketReady =
              callController.isSocketReady.value &&
              callController.isPeerConnectionReady.value;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: isPcAndSocketReady
                    ? Colors.greenAccent
                    : Colors.redAccent,
              ),
              const SizedBox(height: 20),
              Text(
                isPcAndSocketReady
                    ? "Waiting for partner..."
                    : "Setting Up Conection...",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
