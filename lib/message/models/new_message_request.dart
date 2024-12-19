import 'package:rocket_chat_flutter/message/models/attachment.dart';

class NewMessageRequest {
  final String roomId;  // required
  final String text;    // required
  final String? alias;  // optional
  final String? emoji;  // optional
  final String? avatar; // optional
  final List<MessageAttachment>? attachments; // optional
  final String? tmid;   // optional - thread message ID
  final bool? tshow;    // optional - thread show

  NewMessageRequest({
    required this.roomId,
    required this.text,
    this.alias,
    this.emoji,
    this.avatar,
    this.attachments,
    this.tmid,
    this.tshow,
  });

  Map<String, dynamic> toJson() {
    return {
      'rid': roomId,
      'msg': text,
      if (alias != null) 'alias': alias,
      if (emoji != null) 'emoji': emoji,
      if (avatar != null) 'avatar': avatar,
      if (attachments != null) 'attachments': attachments?.map((e) => e.toJson()).toList(),
      if (tmid != null) 'tmid': tmid,
      if (tshow != null) 'tshow': tshow,
    };
  }
}
