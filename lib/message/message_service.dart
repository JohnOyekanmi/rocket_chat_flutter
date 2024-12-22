import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:rocket_chat_flutter/message/models/message.dart';
import 'package:rocket_chat_flutter/message/models/new_message_request.dart';
import 'package:rocket_chat_flutter/utils/Exceptions/rocket_chat_exception.dart';
import 'package:rocket_chat_flutter/utils/logger_mixin.dart';

/// The message service.
class MessageService with LoggerMixin {
  final Dio _dio;

  MessageService(this._dio) {
    setLogModule(_serviceClass);
  }

  /// The service class name.
  static const String _serviceClass = 'MESSAGE-SERVICE';

  /// Get the room messages.
  Future<List<Message>> getMessages(String roomId, [int count = 50]) async {
    try {
      final response = await _dio.get(
        '/api/v1/im.messages',
        queryParameters: {
          'roomId': roomId,
          'count': count,
        },
      );

      print(response.data['messages'][0]);

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

  /// Get Room Message History
  Future<List<Message>> getRoomMessageHistory(
    String roomId, [
    int count = 50,
  ]) async {
    try {
      final response = await _dio.get(
        '/api/v1/im.history',
        queryParameters: {
          'roomId': roomId,
          'count': count,
        },
      );

      print(response.data['messages']);

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
    String? message, [
    void Function(int count, int total)? onSendProgress,
  ]) async {
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
        onSendProgress: onSendProgress,
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

  /// Delete a message from a room.
  ///
  /// [roomId] The room ID.
  /// [messageId] The message ID.
  Future<bool> deleteMessage(String roomId, String messageId) async {
    try {
      final response = await _dio.post(
        '/api/v1/chat.delete',
        data: {'roomId': roomId, 'msgId': messageId, 'asUser': false},
      );

      // print('response: ${response.data}');
      return response.data['success'];
    } on Exception catch (e, s) {
      if (e is DioException) {
        rethrow;
      }

      throw RocketChatException(
        'Failed to delete message',
        _serviceClass,
        'deleteMessage',
        e,
        s.toString(),
      );
    }
  }
}
