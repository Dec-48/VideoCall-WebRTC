import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/views/call_page.dart';
import 'package:get/get.dart';

class JoinPage extends StatelessWidget {
  JoinPage({super.key});

  final roomController = TextEditingController();

  void pressCreateRoom() async {
    String randomId = (Random().nextInt(900000) + 100000).toString();
    Get.to(() => CallPage(roomId: randomId));
    // }
  }

  Future<void> pressJoinRoom() async {
    if (roomController.text.isNotEmpty) {
      Get.to(() => CallPage(roomId : roomController.text));
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Call")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: pressCreateRoom,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
              elevation: 5, // Shadow depth
            ),
            child: const Text("CREATE NEW ROOM"),
          ),
          SizedBox(height: 15,),
          const Text("OR JOIN ROOM"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            child: TextField(
              controller: roomController,
              decoration: const InputDecoration(
                labelText: "Enter Room ID",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: pressJoinRoom,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
              elevation: 5, // Shadow depth
            ),
            child: const Text("JOIN"),
          ),
        ],
      ),
    );
  }
}
