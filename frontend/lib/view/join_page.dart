import 'package:flutter/material.dart';
import 'package:frontend/service/room_service.dart';
import 'package:frontend/view/call_page.dart';
import 'package:get/get.dart';

class JoinPage extends StatelessWidget {
  JoinPage({super.key});

  final roomController = TextEditingController();
  final roomService = RoomService();

  void pressCreateRoom() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    String? roomId = await roomService.createRoom();
    Get.back(); // loaded
    if (roomId != null) {
      Get.to(() => CallPage(roomId: roomId));
    } else {
      Get.snackbar(
        "Error",
        "Failed to connect to server. Is Backend running?",
        backgroundColor: Colors.red.withValues(alpha: 0.5),
        colorText: Colors.white,
      );
    }
  }

  Future<void> pressJoinRoom() async {
    final roomId = roomController.text.trim();
    if (roomId.isEmpty) {
      Get.snackbar("Error", "Enter Valid Room ID");
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final stats = await roomService.getRoomStats(roomId);

    Get.back();

    if (stats != null) {
      if (stats['isFull'] == true) {
        Get.snackbar(
          "Room Full",
          "This room already has 2 participants.",
          backgroundColor: Colors.orange.withValues(alpha: 0.5),
        );
      } else {
        Get.to(() => CallPage(roomId: roomId));
      }
    } else {
      Get.snackbar(
        "Not Found",
        "Room ID '$roomId' does not exist.",
        backgroundColor: Colors.red.withValues(alpha: 0.5),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: IconButton(
        icon: Icon(Get.isDarkMode ? Icons.light_mode : Icons.dark_mode),
        onPressed: () => Get.changeThemeMode(
          Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          //* ensure width is not exceed 900
          constraints: BoxConstraints(maxWidth: 900),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // let say 600px is big enough....
              bool isDesktop = constraints.maxWidth > 650;

              return SingleChildScrollView(
                padding: EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.video_camera_front_rounded,
                      size: 80,
                      color: Colors.deepPurple,
                    ),

                    const SizedBox(height: 5),
                    Text(
                      "Real-time Video Meetings",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "WebRTC + WebSocket\n(Supports 1-on-1 calls only)",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    isDesktop
                        ? buildDesktopLayout(context)
                        : buildMobileLayout(context),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(child: buildCreateRoomCard(context)),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Container(height: 60, width: 1, color: Colors.grey.shade300),
              Text(
                "OR",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Container(height: 60, width: 1, color: Colors.grey.shade300),
            ],
          ),
        ),

        Expanded(child: buildJoinRoomCard(context)),
      ],
    );
  }

  Widget buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: buildCreateRoomCard(context),
        ),
        const SizedBox(height: 50),

        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text("OR"),
            ),
            Expanded(child: Divider()),
          ],
        ),

        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: buildJoinRoomCard(context),
        ),
      ],
    );
  }

  Widget buildCreateRoomCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ), //! same with inner inkwell
      child: InkWell(
        onTap: pressCreateRoom,
        borderRadius: BorderRadius.circular(20), //! same with outer card
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                "New Meeting",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Create a waiting room",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildJoinRoomCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Text(
              "Join Meeting",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: roomController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.keyboard),
                labelText: "Room ID",
                hintText: "123456",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true, // check this
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: FilledButton(
                onPressed: pressJoinRoom,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text("Join Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
