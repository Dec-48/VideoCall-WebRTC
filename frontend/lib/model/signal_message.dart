class SignalMessage {
  final String type;
  final String? roomId;
  final Map<String, dynamic>? sdp; // เก็บข้อมูล Offer/Answer
  final Map<String, dynamic>? candidate;

  SignalMessage({required this.type, this.roomId, this.sdp, this.candidate});

  factory SignalMessage.fromJson(Map<String, dynamic> json) {
    return SignalMessage(
      type: json['type'] ?? 'unknown',
      roomId: json['roomId'],
      sdp: json['sdp'],
      candidate: json['candidate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      if (roomId != null) "roomId": roomId,
      if (sdp != null) "sdp": sdp,
      if (candidate != null) "canditdate": candidate,
    };
  }
}
