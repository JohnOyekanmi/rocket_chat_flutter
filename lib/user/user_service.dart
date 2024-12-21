import 'package:dio/dio.dart';
import 'package:rocket_chat_flutter/utils/Exceptions/rocket_chat_exception.dart';

import 'models/profile_info.dart';
import 'models/user_presence.dart';

/// Service for user related operations.
class UserService {
  final Dio _dio;

  UserService(this._dio);

  /// The class name for logging purposes.
  final String _serviceClass = 'UserService';

  /// Get the profile information of the currently logged in user.
  Future<ProfileInfo> getProfileInfo() async {
    try {
      final response = await _dio.get('/api/v1/me');
      return ProfileInfo.fromJson(response.data);
    } on Exception catch (e, s) {
      if (e is DioException) {
        rethrow;
      }

      throw RocketChatException(
        'Failed to get profile info',
        _serviceClass,
        'getProfileInfo',
        e,
        s.toString(),
      );
    }
  }

  /// Get the presence of a user.
  ///
  /// [username] The ID of the user.
  Future<UserPresence> getUserPresence(String username) async {
    try {
      print('username: $username');
      final response = await _dio.get(
        '/api/v1/users.getStatus',
        queryParameters: {'username': username},
      );
      print('response: ${response.data}');
      final status = response.data['status'] is String
          ? response.data['status']
          : response.data['status']['status'];
      return UserPresence(
        username,
        null,
        status,
      );
    } on Exception catch (e, s) {
      if (e is DioException) {
        rethrow;
      }

      throw RocketChatException(
        'Failed to get user presence',
        _serviceClass,
        'getUserPresence',
        e,
        s.toString(),
      );
    }
  }

  /// Set the presence of a user.
  ///
  /// [userId] The ID of the user.
  /// [status] The user presence status.
  /// [message] The message to set the user status to.
  // @Deprecated('Use WebSocket.sendTemporaryUserPresenceStatus instead')
  Future<void> setUserStatus(
    String userId,
    String status, [
    String? message,
  ]) async {
    try {
      await _dio.post(
        '/api/v1/users.setStatus',
        data: {
          "message": message ?? status,
          "userId": userId,
          "status": status,
        },
      );
    } on Exception catch (e, s) {
      if (e is DioException) {
        rethrow;
      }

      throw RocketChatException(
        'Failed to set user status',
        _serviceClass,
        'setUserStatus',
        e,
        s.toString(),
      );
    }
  }
}
