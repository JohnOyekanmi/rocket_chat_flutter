import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:rocket_chat_flutter/message/models/message.dart';
import 'package:rocket_chat_flutter/message/models/new_message_request.dart';
import 'package:rocket_chat_flutter/utils/Exceptions/rocket_chat_exception.dart';

/// The message service.
class MessageService {
  final Dio _dio;

  MessageService(this._dio);

  /// The service class name.
  static const String _serviceClass = 'MESSAGE-SERVICE';

  /// Get the room messages.
  Future<List<Message>> getMessages(String roomId, [int count = 50]) async {
    try {
      final response = await _dio.get(
        '/api/v1/im.messages?roomId=$roomId',
        queryParameters: {'count': count},
      );

      return List<Message>.from(
        response.data['messages'].map((e) => Message.fromJson(e)),
      );
    } on Exception catch (e, s) {
      if (e is DioException) {
        rethrow;
      }

      throw RocketChatException(
        'Failed to fetch room messages',
        _serviceClass,
        'getMessages',
        e,
        s.toString(),
      );
    }
  }

  /// Send a message to a room.
  Future<Message> sendMessage(String roomId, NewMessageRequest message) async {
    try {
      final response = await _dio.post(
        '/api/v1/chat.sendMessage',
        data: {'roomId': roomId, 'message': message.toJson()},
      );

      return Message.fromJson(response.data['message']);
    } on Exception catch (e, s) {
      if (e is DioException) {
        rethrow;
      }

      throw RocketChatException(
        'Failed to send message',
        _serviceClass,
        'sendMessage',
        e,
        s.toString(),
      );
    }
  }

  /// Send a media message to a room.
  ///
  /// Returns the URL of the uploaded media file.
  Future<String> sendMediaMessage(
    String roomId,
    File mediaFile,
    String? message,
  ) async {
    try {
      final mimeType = lookupMimeType(mediaFile.path);
      final fileName = mediaFile.path.split('/').last;

      // Create form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          mediaFile.path,
          filename: fileName,
          contentType: mimeType != null ? DioMediaType.parse(mimeType) : null,
        ),
        if (message != null) 'msg': message,
      });

      // Send the request
      final response = await _dio.post(
        '/api/v1/rooms.upload/$roomId',
        data: formData,
      );

      return response.data['message']['attachments'][0]['title_link'];
    } on Exception catch (e, s) {
      if (e is DioException) {
        rethrow;
      }

      throw RocketChatException(
        'Failed to send media message',
        _serviceClass,
        'sendMediaMessage',
        e,
        s.toString(),
      );
    }
  }
}
