class ChatMessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String text;
  final String type;
  final DateTime? createdAt;

  const ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.text,
    required this.type,
    this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final roomId = json['roomId'] ?? json['room_id'];
    final senderId = json['senderId'] ?? json['sender_id'];
    final text = json['text'];
    final type = json['type'];
    if (id is! String ||
        roomId is! String ||
        senderId is! String ||
        text is! String ||
        type is! String) {
      throw const FormatException('ChatMessageModel: datos inválidos');
    }

    DateTime? createdAt;
    final rawCreated = json['createdAt'] ?? json['created_at'];
    if (rawCreated is String) {
      createdAt = DateTime.tryParse(rawCreated);
    }

    return ChatMessageModel(
      id: id,
      roomId: roomId,
      senderId: senderId,
      text: text,
      type: type,
      createdAt: createdAt,
    );
  }
}

class ChatMessageRequest {
  final String senderId;
  final String text;
  final String type;

  const ChatMessageRequest({
    required this.senderId,
    required this.text,
    this.type = 'TEXT',
  });

  Map<String, dynamic> toJson() {
    return {'senderId': senderId, 'text': text, 'type': type};
  }
}
