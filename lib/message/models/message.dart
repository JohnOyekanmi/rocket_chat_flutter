import 'package:rocket_chat_flutter/message/models/attachment.dart';
import 'package:rocket_chat_flutter/room/models/room_user.dart';
import 'package:rocket_chat_flutter/utils/utils.dart';

/// The room message model.
class Message {
  final String id;
  final String roomId;
  final RoomUser user;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool? groupable; // nullable
  final List<MessageAttachment> attachments;

  Message({
    required this.id,
    required this.roomId,
    required this.user,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.groupable,
    required this.attachments,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      roomId: json['rid'],
      user: RoomUser.fromJson(json['u']),
      text: json['msg'],
      createdAt: RocketChatFlutterUtils.parseDate(
          json['ts'] is String ? json['ts'] : json['ts']['\$date']),
      updatedAt: RocketChatFlutterUtils.parseDate(json['_updatedAt'] is String
          ? json['_updatedAt']
          : json['_updatedAt']['\$date']),
      groupable: json['groupable'],
      attachments: (json['attachments'] as List?)
              ?.map((e) => MessageAttachment.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'rid': roomId,
      'u': user.toJson(),
      'msg': text,
      'ts': {
        '\$date': createdAt.toIso8601String(),
      },
      '_updatedAt': {
        '\$date': updatedAt.toIso8601String(),
      },
      if (groupable != null) 'groupable': groupable,
      'attachments': attachments.map((e) => e.toJson()).toList(),
    };
  }
}
