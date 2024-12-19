import 'package:dio/dio.dart';
import 'package:rocket_chat_flutter/utils/Exceptions/rocket_chat_exception.dart';

import 'models/profile_info.dart';

/// Service for user related operations.
class UserService {
  final Dio _dio;

  UserService(this._dio);

  /// The class name for logging purposes.
  final String _serviceClass = 'UserService';

  /// Get the profile information of the current user.
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
}
