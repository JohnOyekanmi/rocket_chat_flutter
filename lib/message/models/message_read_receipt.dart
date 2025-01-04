/// Message Read Receipt model represents when a user has read a message
class MessageReadReceipt {
  final String id;
  final String messageId;
  final String roomId;
  final String userId;
  final String username;
  final DateTime timestamp;

  const MessageReadReceipt({
    required this.id,
    required this.messageId,
    required this.roomId,
    required this.userId,
    required this.username,
    required this.timestamp,
  });

  /// Create a MessageReadReceipt from JSON
  factory MessageReadReceipt.fromJson(Map<String, dynamic> json) {
    return MessageReadReceipt(
      id: json['_id'] as String,
      messageId: json['messageId'] as String,
      roomId: json['roomId'] as String,
      userId: json['user']['_id'] as String,
      username: json['user']['username'] as String,
      timestamp: DateTime.parse(json['ts'] as String),
    );
  }

  /// Convert MessageReadReceipt to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'messageId': messageId,
      'roomId': roomId,
      'user': {
        '_id': userId,
        'username': username,
      },
      'ts': timestamp.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageReadReceipt &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          messageId == other.messageId &&
          roomId == other.roomId &&
          userId == other.userId &&
          username == other.username &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      id.hashCode ^
      messageId.hashCode ^
      roomId.hashCode ^
      userId.hashCode ^
      username.hashCode ^
      timestamp.hashCode;
}
