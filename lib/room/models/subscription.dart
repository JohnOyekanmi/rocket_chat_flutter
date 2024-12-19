import 'package:rocket_chat_flutter/utils/utils.dart';

import 'room_user.dart';

/// The subscription model.
class Subscription {
  final String id;
  final bool open;
  final bool alert;
  final int unread;
  final int userMentions;
  final int groupMentions;
  final DateTime ts;
  final String rid;
  final String name;
  final String type;
  final RoomUser u;
  final DateTime updatedAt;

  Subscription({
    required this.id,
    required this.open,
    required this.alert,
    required this.unread,
    required this.userMentions,
    required this.groupMentions,
    required this.ts,
    required this.rid,
    required this.name,
    required this.type,
    required this.u,
    required this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['_id'] as String,
      open: json['open'] == true,
      alert: json['alert'] == true,
      unread: json['unread'] as int,
      userMentions: json['userMentions'] as int,
      groupMentions: json['groupMentions'] as int,
      ts: RocketChatFlutterUtils.parseDate(
          json['ts'] is String ? json['ts'] : json['ts']['\$date']),
      rid: json['rid'] as String,
      name: json['name'] as String,
      type: json['t'] as String,
      u: RoomUser.fromJson(json['u']),
      updatedAt: RocketChatFlutterUtils.parseDate(json['_updatedAt'] is String
          ? json['_updatedAt']
          : json['_updatedAt']['\$date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'open': open,
      'alert': alert,
      'unread': unread,
      'userMentions': userMentions,
      'groupMentions': groupMentions,
      'ts': {'\$date': ts.toIso8601String()},
      'rid': rid,
      'name': name,
      't': type,
      'u': u.toJson(),
      '_updatedAt': {'\$date': updatedAt.toIso8601String()},
    };
  }
}
