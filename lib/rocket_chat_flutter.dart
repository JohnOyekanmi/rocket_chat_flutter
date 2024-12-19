library rocket_chat_flutter;

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:rocket_chat_flutter/message/models/message.dart';
import 'package:rocket_chat_flutter/room/models/room_change.dart';
import 'package:rocket_chat_flutter/user/models/user_presence.dart';
import 'package:rocket_chat_flutter/websocket/models/collection_type.dart';
import 'package:rocket_chat_flutter/websocket/websocket_helper.dart';

import 'auth/models/auth.dart';
import 'message/message_service.dart';
import 'message/models/new_message_request.dart';
import 'room/models/room.dart';
import 'room/models/typing.dart';
import 'room/room_service.dart';
import 'utils/logger_mixin.dart';
import 'websocket/models/websocket_response.dart';
import 'websocket/websocket_service.dart';

class RocketChatFlutter with LoggerMixin {
  static const _serviceClass = 'RocketChatFlutter';

  final String serverUrl;
  final String webSocketUrl;
  final String authToken;
  final String userId;

  RocketChatFlutter({
    required this.serverUrl,
    required this.webSocketUrl,
    required this.authToken,
    required this.userId,
  }) {
    setLogModule(_serviceClass);
    _dio = Dio(
      BaseOptions(
        baseUrl: serverUrl,
        headers: {
          'X-Auth-Token': authToken,
          'X-User-Id': userId,
        },
      ),
    );
    _auth = Auth(authToken, userId);
    _webSocketService = WebSocketService(
      url: webSocketUrl,
      authentication: _auth,
      onData: _handleWebSocketData,
    );
    _messageService = MessageService(_dio);
    _roomService = RoomService(_dio);

    log(
      'RocketChatFlutter.Constructor',
      '''RocketChatFlutter initialized with:
      baseUrl: $serverUrl
      webSocketUrl: $webSocketUrl
      authToken: $authToken
      userId: $userId
      ''',
    );
  }

  late final Auth _auth;
  late final Dio _dio;
  late final WebSocketService _webSocketService;
  late final MessageService _messageService;
  late final RoomService _roomService;

  // Map<roomId, messagesSubscriptionId>
  final Map<String, String> _roomMessageSubscriptions = {};
  // Map<roomId, typingSubscriptionId>
  final Map<String, String> _roomTypingSubscriptions = {};

  final Map<String, StreamController<List<Message>>> _roomMessages = {};
  final Map<String, StreamController<Typing>> _roomTypings = {};
  final StreamController<List<RoomChange>> _subscriptions =
      StreamController.broadcast();
  bool _isSubscribedToRoomSubscriptions = false;
  final Map<String, StreamController<UserPresence>> _userPresences = {};
  final Map<String, String> _userPresenceSubscriptions = {};

  /// Initialize the RocketChatFlutter instance.
  Future<void> init() async {
    _webSocketService.init();
  }

  /// Dispose of the RocketChatFlutter instance.
  void dispose() {
    _webSocketService.dispose();
    _subscriptions.close();
    for (var value in _roomMessages.values) {
      value.close();
    }
    for (var value in _roomTypings.values) {
      value.close();
    }
    for (var value in _userPresences.values) {
      value.close();
    }
    _roomMessageSubscriptions.clear();
    _roomTypingSubscriptions.clear();
    _userPresenceSubscriptions.clear();
    log('dispose', 'RocketChatFlutter disposed');
  }

  void _handleWebSocketData(dynamic data) {
    // Handle WebSocket data
    log('_handleWebSocketData', 'WebSocket data received: $data');

    final response = WebSocketResponse.fromJson(data);

    if (response.message == 'changed') {
      switch (response.collection) {
        case CollectionType.STREAM_NOTIFY_ROOM:
          final eventName = response.fields['eventName'];
          if (eventName != null && eventName.endsWith('user-activity')) {
            final args = response.fields['args'];
            if (args != null && args.isNotEmpty) {
              final roomId = eventName.split('/')[0];
              _handleUserActivity(args, roomId);
            }
          }
          break;
        case CollectionType.STREAM_NOTIFY_USER:
          final eventName = response.fields['eventName'];
          if (eventName != null &&
              eventName.endsWith('subscriptions-changed')) {
            final args = response.fields['args'];
            if (args != null && args.isNotEmpty) {
              _handleRoomSubscriptionsChanged(args);
            }
          }
          break;
        case CollectionType.STREAM_ROOM_MESSAGES:
          final eventName = response.fields['eventName'];
          if (eventName != null) {
            final args = response.fields['args'];
            if (args != null && args.isNotEmpty) {
              _handleRoomMessages(args, eventName);
            }
          }
          break;
        case CollectionType.STREAM_NOTIFY_LOGGED:
          final eventName = response.fields['eventName'];
          if (eventName != null && eventName.endsWith('user-status')) {
            final args = response.fields['args'];
            if (args != null && args.isNotEmpty) {
              _handleLoggedChange(args);
            }
          }
          break;
        default:
          logE('_handleWebSocketData',
              'Unknown collection type: $response.collection');
          break;
      }
    }
  }

  void _handleUserActivity(List<dynamic> args, String roomId) {
    log('_handleUserActivity', 'User activity: $args');

    _roomTypings[roomId]?.add(Typing.fromList(args));
  }

  void _handleRoomSubscriptionsChanged(List<dynamic> args) {
    log('_handleRoomSubscriptionsChanged', 'Room subscriptions changed: $args');

    _subscriptions.add([RoomChange.fromList(args)]);
  }

  void _handleRoomMessages(List<dynamic> args, String roomId) {
    log('_handleRoomMessages', 'Room messages: $args');

    final List<Message> messages =
        args.map((e) => Message.fromJson(e)).toList();
    _roomMessages[roomId]?.add(messages);
  }

  void _handleLoggedChange(List<dynamic> args) {
    log('_handleLoggedChange', 'Logged change: $args');

    final presence = UserPresence.fromList(args[0]);
    _userPresences[presence.userId]?.add(presence);
  }

  // ==============================
  // GET-STREAMS-METHODS
  // ==============================

  /// Get the subscriptions stream.
  Stream<List<RoomChange>> getSubscriptionsStream() {
    // Use Future.microtask to avoid synchronous subscription
    Future.microtask(() => _subscribeToRoomSubscriptions());

    log(
      'getSubscriptionsStream',
      'Subscribed to subscriptions stream',
    );

    return _subscriptions.stream;
  }

  void _subscribeToRoomSubscriptions() {
    if (_isSubscribedToRoomSubscriptions) {
      // fetch initial subscriptions if the stream is already subscribed.
      _roomService.getSubscriptions().then((subscriptions) {
        _subscriptions.add(subscriptions);
      });
      return;
    }

    _webSocketService.subscribeToUserRoomSubscriptions();

    _isSubscribedToRoomSubscriptions = true;

    // fetch initial subscriptions.
    _roomService.getSubscriptions().then((subscriptions) {
      _subscriptions.add(subscriptions);
    });
  }

  /// Close the subscriptions stream
  void closeRoomSubscriptionsStream() {
    _subscriptions.close();
    _webSocketService.unsubscribeFromUserRoomSubscriptions();
  }

  /// Get the messages stream for a room.
  Stream<List<Message>> getMessagesStream(String roomId) {
    _roomMessages[roomId] ??= StreamController<List<Message>>.broadcast();

    if (!_roomMessageSubscriptions.containsKey(roomId)) {
      // subscribe to the room messages stream if the stream is not already subscribed.
      // Use Future.microtask to avoid synchronous subscription
      Future.microtask(() => _subscribeToRoomMessages(roomId));

      log(
        'getMessagesStream',
        'Subscribed to room messages stream for room $roomId',
      );
    }

    return _roomMessages[roomId]!.stream;
  }

  void _subscribeToRoomMessages(String roomId) {
    if (_roomMessageSubscriptions.keys.contains(roomId)) {
      // fetch initial messages if the room is already subscribed
      // and an additional subscription is requested.
      _messageService.getMessages(roomId).then((messages) {
        _roomMessages[roomId]?.add(messages);
      });
      return;
    }

    _webSocketService.subscribeToRoomMessagesStream(roomId);

    // add the subscription id to the map.
    _roomMessageSubscriptions[roomId] = WebSocketHelper.getRoomMsgSubId(roomId);

    // fetch initial messages.
    _messageService.getMessages(roomId).then((messages) {
      print('_messageService.getMessagesmessages: $messages');
      _roomMessages[roomId]?.add(messages);
    });
  }

  /// Close the messages stream for a room.
  void closeMessagesStream(String roomId) {
    _roomMessages[roomId]?.close();
    _roomMessages.remove(roomId);
    _roomMessageSubscriptions.remove(roomId);
  }

  /// Get the typing stream for a room.
  Stream<Typing> getTypingStream(String roomId) {
    _roomTypings[roomId] ??= StreamController<Typing>.broadcast();

    if (!_roomTypingSubscriptions.containsKey(roomId)) {
      // Use Future.microtask to avoid synchronous subscription
      Future.microtask(() => _subscribeToRoomTyping(roomId));

      log(
        'getTypingStream',
        'Subscribed to room typing stream for room $roomId',
      );
    }

    return _roomTypings[roomId]!.stream;
  }

  void _subscribeToRoomTyping(String roomId) {
    if (_roomTypingSubscriptions.keys.contains(roomId)) {
      return;
    }

    _webSocketService.subscribeToRoomTypingStream(roomId);

    // add the subscription id to the map
    _roomTypingSubscriptions[roomId] =
        WebSocketHelper.getRoomTypingStatusSubId(roomId);
  }

  /// Close the typing stream for a room.
  void closeTypingStream(String roomId) {
    _roomTypings[roomId]?.close();
    _roomTypings.remove(roomId);
    _roomTypingSubscriptions.remove(roomId);
  }

  /// Get the user presence stream.
  Stream<UserPresence> getUserPresenceStream(String userId) {
    _userPresences[userId] ??= StreamController<UserPresence>.broadcast();

    if (!_userPresenceSubscriptions.containsKey(userId)) {
      // Use Future.microtask to avoid synchronous subscription
      Future.microtask(() => _subscribeToUserPresence(userId));

      log(
        'getUserPresenceStream',
        'Subscribed to user presence stream for user $userId',
      );
    }

    return _userPresences[userId]!.stream;
  }

  void _subscribeToUserPresence(String userId) {
    if (_userPresenceSubscriptions.keys.contains(userId)) {
      return;
    }

    _webSocketService.subscribeToUserPresenceStream(userId);
    _userPresenceSubscriptions[userId] =
        WebSocketHelper.getUserPresenceSubId(userId);
  }

  /// Close the user presence stream
  void closeUserPresenceStream(String userId) {
    _userPresences[userId]?.close();
    _userPresences.remove(userId);
    _userPresenceSubscriptions.remove(userId);
  }

  // ==============================
  // SEND-TO-STREAM-METHODS
  // ==============================

  /// Send a message to a room.
  void sendMessageToRoom(String roomId, String message) {
    _messageService.sendMessage(
      roomId,
      NewMessageRequest(roomId: roomId, text: message),
    );
  }

  /// Send a media message to a room.
  ///
  /// [file] The file to send.
  /// [fileType] The type of the file.
  /// [message] The message to send along with the file.
  Future<List<String>> sendMediaMessage(
    String roomId,
    List<File> files,
    String? message,
  ) async {
    final fileUrls = <String>[];
    for (var file in files) {
      final fileUrl = await _messageService.sendMediaMessage(
        roomId,
        file,
        message,
      );
      fileUrls.add(fileUrl);
    }

    return fileUrls;
  }

  /// Send an audio file to the room.
  ///
  /// [roomId] The room ID.
  /// [message] The message to send along with the file.
  /// [audioFiles] The audio files to send.
  void sendAudioMessage(
    String roomId,
    String? message,
    List<File> audioFiles,
  ) {
    sendMediaMessage(roomId, audioFiles, message);
  }

  /// Send an image file to the room.
  ///
  /// [roomId] The room ID.
  /// [message] The message to send along with the file.
  /// [imageFiles] The image files to send.
  void sendImageMessage(
    String roomId,
    String? message,
    List<File> imageFiles,
  ) {
    sendMediaMessage(roomId, imageFiles, message);
  }

  /// Send a video file to the room.
  ///
  /// [roomId] The room ID.
  /// [message] The message to send along with the file.
  /// [videoFiles] The video files to send.
  void sendVideoMessage(
    String roomId,
    String? message,
    List<File> videoFiles,
  ) {
    sendMediaMessage(roomId, videoFiles, message);
  }

  /// Send a typing status to a room.
  ///
  /// [roomId] The room ID.
  /// [username] The username.
  /// [typing] Whether the user is typing.
  void sendTypingStatus(String roomId, String username, [bool typing = true]) {
    _webSocketService.sendUserTypingStatus(
      roomId,
      username,
      typing,
    );
  }

  /// Send a user presence status.
  ///
  /// [status] The user presence status.
  void sendUserPresenceStatus(String userId, String status) {
    _webSocketService.sendUserPresence(userId, status);
  }

  /// Create a new room.
  ///
  /// [username] The username of the user to create a DM with.
  Future<String> createNewRoom(String username) {
    // _webSocketService.createDM(username);
    return _roomService.createDM(username);
  }

  /// Get the room information.
  ///
  /// [roomId] The room ID.
  Future<Room> getRoomInfo(String roomId) {
    return _roomService.getRoomInfo(roomId);
  }

  /// Get the room messages.
  ///
  /// [roomId] The room ID.
  Future<List<Message>> getRoomMessages(String roomId) {
    return _messageService.getMessages(roomId);
  }

  /// Delete a room.
  ///
  /// [roomId] The room ID.
  Future<void> deleteRoom(String roomId) {
    return _roomService.deleteDM(roomId);
  }

  /// Mark all room messages as read.
  ///
  /// [roomId] The room ID.
  Future<bool> markAllRoomMessagesAsRead(String roomId) {
    return _roomService.markAsRead(roomId);
  }
}