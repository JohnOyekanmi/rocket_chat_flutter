import 'package:dio/dio.dart';
import 'package:rocket_chat_flutter/room/models/room.dart';
import 'package:rocket_chat_flutter/utils/Exceptions/rocket_chat_exception.dart';
import 'package:rocket_chat_flutter/utils/logger_mixin.dart';

import 'models/room_change.dart';

/// The room service class.
///
/// This class provides methods to interact with the Rocket.Chat room API.
class RoomService with LoggerMixin {
  final Dio _dio;

  RoomService(this._dio) {
    setLogModule(_serviceClass);
  }

  /// The service class name for logging purposes.
  static const String _serviceClass = 'ROOM-SERVICE';

  /// Get the subscriptions.
  Future<List<RoomChange>> getSubscriptions() async {
    try {
      final response = await _dio.get('/api/v1/subscriptions.get');
      final updated = response.data['update'];
      final removed = response.data['remove'];
      final List<RoomChange> subs = [];

      // Add updated subscriptions.
      for (var sub in updated) {
        subs.add(RoomChange.fromList(['updated', sub]));
      }

      // Add removed subscriptions.
      for (var sub in removed) {
        subs.add(RoomChange.fromList(['removed', sub]));
      }

      return subs;
    } on Exception catch (e, s) {
      if (e is DioException) {
        rethrow;
      }

      throw RocketChatException(
        'Failed to get subscriptions',
        _serviceClass,
        'getSubscriptions',
        e,
        s.toString(),
      );
    }
  }

  /// Create a room.
  ///
  /// This method creates a direct message room with the given [username] and returns the room ID.
  Future<String> createDM(String username) async {
    try {
      final response = await _dio.post(
        '/api/v1/im.create',
        data: {'username': username},
      );

      return response.data['room']['rid'];
    } on Exception catch (e, s) {
      if (e is DioException) {
        rethrow;
      }

      throw RocketChatException(
        'Failed to create room',
        _serviceClass,
        'createDM',
        e,
        s.toString(),
      );
    }
  }

  /// Get the room information.
  Future<Room> getRoomInfo(String roomId) async {
    try {
      final response = await _dio.get('/api/v1/rooms.info/?roomId=$roomId');
      return Room.fromJson(response.data);
    } on Exception catch (e, s) {
      if (e is DioException) {
        rethrow;
      }

      throw RocketChatException(
        'Failed to fetch room information',
        _serviceClass,
        'getRoomInfo',
        e,
        s.toString(),
      );
    }
  }

  /// Mark the all messages in the room as read.
  Future<bool> markAsRead(String roomId) async {
    try {
      final response = await _dio.post(
        '/api/v1/subscriptions.read',
        data: {'rid': roomId},
      );
      return response.data['success'];
    } on Exception catch (e, s) {
      if (e is DioException) {
        rethrow;
      }

      throw RocketChatException(
        'Failed to mark as read',
        _serviceClass,
        'markAsRead',
        e,
        s.toString(),
      );
    }
  }

  /// Delete the room.
  Future<bool> deleteDM(String roomId) async {
    try {
      final response = await _dio.post(
        '/api/v1/im.delete',
        data: {'roomId': roomId},
      );
      return response.data['success'];
    } on Exception catch (e, s) {
      if (e is DioException) {
        rethrow;
      }

      throw RocketChatException(
        'Failed to delete room',
        _serviceClass,
        'deleteDM',
        e,
        s.toString(),
      );
    }
  }
}
