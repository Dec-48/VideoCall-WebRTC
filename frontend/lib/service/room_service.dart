import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RoomService {
  final String baseUrl = "http://localhost:8080/api/rooms";

  /// POST /api/rooms
  Future<String?> createRoom() async {
    try {
      final response = await http.post(Uri.parse(baseUrl));      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['roomId'];
      } else {
        if (kDebugMode) {
          print("Failed to create room: ${response.body}");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error creating room: $e");
      }
      return null;
    }
  }

  /// GET /api/rooms/{id} 
  Future<Map<String, dynamic>?> getRoomStats(String roomId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/$roomId"));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null; // Room not found (404)
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error checking room: $e");
      }
      return null;
    }
  }
}