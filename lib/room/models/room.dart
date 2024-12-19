import 'package:rocket_chat_flutter/message/models/message.dart';
import 'package:rocket_chat_flutter/utils/utils.dart';

import 'room_user.dart';

/// The room model.
class Room {
  final String id;
  final String? fname;  // nullable
  final Map<String, dynamic>? customFields;  // nullable
  final String? description;  // nullable
  final bool broadcast;
  final bool encrypted;
  final bool federated;
  final String name;
  final String type;  // 't' in API
  final int messageCount;  // 'msgs' in API
  final int usersCount;
  final RoomUser creator;  // 'u' in API
  final DateTime createdAt;  // 'ts' in API
  final bool readOnly;  // 'ro' in API
  final bool isDefault;  // 'default' in API
  final bool systemMessages;  // 'sysMes' in API
  final DateTime updatedAt;  // '_updatedAt' in API
  final Message? lastMessage;  // nullable

  Room({
    required this.id,
    this.fname,
    this.customFields,
    this.description,
    required this.broadcast,
    required this.encrypted,
    required this.federated,
    required this.name,
    required this.type,
    required this.messageCount,
    required this.usersCount,
    required this.creator,
    required this.createdAt,
    required this.readOnly,
    required this.isDefault,
    required this.systemMessages,
    required this.updatedAt,
    this.lastMessage,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['_id'],
      fname: json['fname'],
      customFields: json['customFields'],
      description: json['description'],
      broadcast: json['broadcast'] ?? false,
      encrypted: json['encrypted'] ?? false,
      federated: json['federated'] ?? false,
      name: json['name'],
      type: json['t'],
      messageCount: json['msgs'] ?? 0,
      usersCount: json['usersCount'] ?? 0,
      creator: RoomUser.fromJson(json['u']),
      createdAt: RocketChatFlutterUtils.parseDate(
          json['ts'] is String ? json['ts'] : json['ts']['\$date']),
      readOnly: json['ro'] ?? false,
      isDefault: json['default'] ?? false,
      systemMessages: json['sysMes'] ?? true,
      updatedAt: RocketChatFlutterUtils.parseDate(
          json['_updatedAt'] is String
              ? json['_updatedAt']
              : json['_updatedAt']['\$date']),
      lastMessage: json['lastMessage'] != null 
          ? Message.fromJson(json['lastMessage'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fname': fname,
      'customFields': customFields,
      'description': description,
      'broadcast': broadcast,
      'encrypted': encrypted,
      'federated': federated,
      'name': name,
      't': type,
      'msgs': messageCount,
      'usersCount': usersCount,
      'u': creator.toJson(),
      'ts': {
        '\$date': createdAt.toIso8601String(),
      },
      'ro': readOnly,
      'default': isDefault,
      'sysMes': systemMessages,
      '_updatedAt': {
        '\$date': updatedAt.toIso8601String(),
      },
      'lastMessage': lastMessage?.toJson(),
    };
  }
}