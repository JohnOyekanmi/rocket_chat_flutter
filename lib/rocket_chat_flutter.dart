library rocket_chat_flutter;

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rocket_chat_flutter/message/models/message.dart';
import 'package:rocket_chat_flutter/room/models/room_change.dart';
import 'package:rocket_chat_flutter/room/models/subscription.dart';
import 'package:rocket_chat_flutter/user/models/user_presence.dart';
import 'package:rocket_chat_flutter/websocket/models/collection_type.dart';
import 'package:rocket_chat_flutter/websocket/websocket_helper.dart';
import 'package:uuid/uuid.dart';

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

  // final Map<String, StreamController<List<Message>>> _roomMessages = {};
  // final Map<String, StreamController<Typing>> _roomTypings = {};
  final Map<String, ValueNotifier<List<Message>>> _roomMessages = {};
  final Map<String, ValueNotifier<Typing?>> _roomTypings = {};
  // final StreamController<List<RoomChange>> _subscriptions =
  //     StreamController.broadcast();
  final ValueNotifier<List<RoomChange>> _subscriptions = ValueNotifier([]);

  Timer? _roomSubscriptionQueryTimer;

  bool _isSubscribedToRoomSubscriptions = false;
  // final Map<String, StreamController<UserPresence>> _userPresences = {};
  final Map<String, ValueNotifier<UserPresence?>> _userPresences = {};
  final Map<String, String> _userPresenceSubscriptions = {};

  // Add set to track processed message IDs
  final Set<String> _processedMessageIds = {};

  /// Initialize the RocketChatFlutter instance.
  Future<void> init() async {
    _webSocketService.init();
  }

  /// Dispose of the RocketChatFlutter instance.
  void dispose() {
    _webSocketService.dispose();
    _subscriptions.dispose();
    _roomSubscriptionQueryTimer?.cancel();
    for (var msg in _roomMessages.entries) {
      closeMessages(msg.key);
    }
    for (var typing in _roomTypings.entries) {
      closeTyping(typing.key);
    }
    for (var presence in _userPresences.entries) {
      closeUserPresence(presence.key);
    }
    _roomMessageSubscriptions.clear();
    _roomTypingSubscriptions.clear();
    _userPresenceSubscriptions.clear();
    log('dispose', 'RocketChatFlutter disposed');
  }

  void _handleWebSocketData(dynamic data) {
    // Handle WebSocket data
    log('_handleWebSocketData', 'WebSocket data received: $data');
    // print('data: ${data.toString()}');

    final response = WebSocketResponse.fromJson(data);

    if (response.message == 'result') {
      if (response.id ==
          WebSocketHelper.getUserSubscriptionsRequestId(userId)) {
        _handleUserSubscriptionsQueryResponse(response.result);
      }
    } else {
      print('data: ${data.toString()}');
    }

    if (response.message == 'removed') {
      switch (response.collection) {
        case CollectionType.STREAM_ROOM_MESSAGES:
          final eventName = response.fields['eventName'];
          // a message deleted activity.
          if (eventName == CollectionType.STREAM_ROOM_MESSAGES) {
            final args = response.fields['args'];
            _handleDeleteMessageActivity(args);
          }
          break;
        default:
          logE('_handleWebSocketData',
              'Unknown collection type: $response.collection');
          break;
      }
    }

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
        // case CollectionType.STREAM_NOTIFY_USER:
        //   final eventName = response.fields['eventName'];
        //   if (eventName != null &&
        //       eventName.endsWith('subscriptions-changed')) {
        //     final args = response.fields['args'];
        //     if (args != null && args.isNotEmpty) {
        //       _handleRoomSubscriptionsChanged(args);
        //     }
        //   }
        //   break;
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

    _roomTypings[roomId]?.value = Typing.fromList(args);
  }

  void _handleUserSubscriptionsQueryResponse(List<dynamic> result) {
    log(
      '_handleUserSubscriptionsQueryResponse',
      'User subscriptions query response: $result',
    );

    // print('args: ${result.map((a) => a.toString())}');

    final newSubscriptions = List<Subscription>.from(
      result.map((r) => Subscription.fromJson(r)),
    );
    // final lastValue = _subscriptions.value;

    // // remove the subscriptions that are already in the list but have
    // // been updated.
    // lastValue.removeWhere(
    //   (r) => newSubscriptions.any((ns) => ns.rid == r.subscription.rid),
    // );

    // // add the new subscriptions to the list.
    // final newRoomChanges = newSubscriptions
    //     .map((ns) => RoomChange(RoomChangeType.updated, ns))
    //     .toList();

    // final list = [...lastValue, ...newRoomChanges];

    // // sort the list by updatedAt in descending order.
    // list.sort(
    //   (a, b) => a.subscription.updatedAt.compareTo(b.subscription.updatedAt),
    // );

    // get the ids of the rooms that are no longer subscribed to.
    final roomIds =
        _subscriptions.value.map((ns) => ns.subscription.rid).toList();
    for (var roomId in roomIds) {
      if (!newSubscriptions.map((ns) => ns.rid).contains(roomId)) {
        closeMessages(roomId);
      }
    }

    _subscriptions.value = newSubscriptions
        .map((ns) => RoomChange(RoomChangeType.updated, ns))
        .toList();
  }

  // void _handleRoomSubscriptionsChanged(List<dynamic> args) {
  //   log('_handleRoomSubscriptionsChanged', 'Room subscriptions changed: $args');

  //   print('args: ${args.map((a) => a.toString())}');

  //   final change = RoomChange.fromList(args);
  //   final lastValue = _subscriptions.value;

  //   switch (change.changeType) {
  //     case RoomChangeType.inserted:
  //       _subscriptions.value = [...lastValue, change];
  //     case RoomChangeType.updated:
  //       lastValue
  //           .removeWhere((r) => r.subscription.rid == change.subscription.rid);
  //       final list = [...lastValue, change];
  //       list.sort((a, b) =>
  //           a.subscription.updatedAt.compareTo(b.subscription.updatedAt));
  //       _subscriptions.value = list;
  //     case RoomChangeType.removed:
  //       lastValue
  //           .removeWhere((r) => r.subscription.rid == change.subscription.rid);
  //       _subscriptions.value = lastValue;
  //   }
  // }

  void _handleRoomMessages(List<dynamic> args, String roomId) {
    log('_handleRoomMessages', 'Room messages: $args');

    print('args: ${args.map((a) => a.toString())}');

    final List<dynamic> rawMessages = [];

    // Add duplicate detection using message ID
    for (var messageData in args) {
      final messageId = messageData['_id'];
      if (messageId != null) {
        if (!_processedMessageIds.add(messageId)) {
          // Message already processed, skip it
          continue;
        }

        // Optional: Maintain a reasonable set size by removing old entries
        if (_processedMessageIds.length > 1000) {
          _processedMessageIds.clear();
        }

        rawMessages.add(messageData);
        _processedMessageIds.add(messageId);
      }
    }

    // convert the raw messages to messages.
    final messages = rawMessages.map((m) => Message.fromJson(m)).toList();

    if (messages.isNotEmpty) {
      final lastValue = _roomMessages[roomId]?.value;

      // remove the messages that are already in the list
      // to avoid duplicates (especially in the case of updates).
      lastValue?.removeWhere((m) => messages.any((nm) => nm.id == m.id));
      final list = [if (lastValue != null) ...lastValue, ...messages];

      // sort the messages by createdAt in descending order
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      _roomMessages[roomId]?.value = list;
    }
  }

  void _handleDeleteMessageActivity(List<dynamic> args) {
    log('_handleDeleteMessageActivity', 'Delete message activity: $args');
    print('args: ${args.map((a) => a.toString())}');

    for (var messageData in args) {
      final messageId = messageData['_id'];
      final roomId = messageData['rid'];

      if (messageId != null && roomId != null) {
        final currentMessages =
            List<Message>.from(_roomMessages[roomId]?.value ?? []);
        currentMessages.removeWhere((m) => m.id == messageId);

        // Create a new sorted list
        final updatedMessages = List<Message>.from(currentMessages)
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        // Update the ValueNotifier with the new list
        _roomMessages[roomId]?.value = updatedMessages;
        _processedMessageIds.remove(messageId);
      }
    }
  }

  void _handleLoggedChange(List<dynamic> args) {
    log('_handleLoggedChange', 'Logged change: $args');

    final presence = UserPresence.fromList(args[0]);
    _userPresences[presence.userId]?.value = presence;
  }

  // ==============================
  // GET-STREAMS-METHODS
  // ==============================

  /// Get the subscriptions stream.
  ValueNotifier<List<RoomChange>> getSubscriptions() {
    // Use Future.microtask to avoid synchronous subscription
    Future.microtask(() => _subscribeToRoomSubscriptions());

    log(
      'getSubscriptions',
      'Subscribed to subscriptions',
    );

    return _subscriptions;
  }

  void _subscribeToRoomSubscriptions() {
    if (_isSubscribedToRoomSubscriptions) {
      return;
    }

    // periodically get user subscriptions.
    _periodicallyGetUserSubscriptions();

    _isSubscribedToRoomSubscriptions = true;
  }

  void _periodicallyGetUserSubscriptions() {
    _roomSubscriptionQueryTimer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (timer) {
        _webSocketService.getUserSubscriptions();
      },
    );
  }

  // void _subscribeToRoomSubscriptions() {
  //   if (_isSubscribedToRoomSubscriptions) {
  //     return;
  //   }

  //   _webSocketService.subscribeToUserRoomSubscriptions();

  //   _isSubscribedToRoomSubscriptions = true;

  //   // fetch initial subscriptions.
  //   _roomService.getSubscriptions().then((subscriptions) {
  //     print('initial-subscriptions: ${subscriptions.map((s) => s.toString())}');
  //     _subscriptions.value = subscriptions;
  //   });
  // }

  /// Close the subscriptions stream
  void closeRoomSubscriptions() {
    _isSubscribedToRoomSubscriptions = false;
    _roomSubscriptionQueryTimer?.cancel();
    _subscriptions.dispose();
    // _webSocketService.unsubscribeFromUserRoomSubscriptions();
  }

  /// Get the messages stream for a room.
  ValueNotifier<List<Message>> getMessages(String roomId) {
    _roomMessages[roomId] ??= ValueNotifier([]);

    if (!_roomMessageSubscriptions.containsKey(roomId)) {
      // subscribe to the room messages stream if the stream is not already subscribed.
      // Use Future.microtask to avoid synchronous subscription
      Future.microtask(() => _subscribeToRoomMessages(roomId));

      log(
        'getMessages',
        'Subscribed to room messages stream for room $roomId',
      );
    }

    return _roomMessages[roomId]!;
  }

  void _subscribeToRoomMessages(String roomId) {
    if (_roomMessageSubscriptions.keys.contains(roomId)) {
      return;
    }

    _webSocketService.subscribeToRoomMessagesStream(roomId);

    // add the subscription id to the map.
    _roomMessageSubscriptions[roomId] = WebSocketHelper.getRoomMsgSubId(roomId);

    // fetch initial messages.
    _messageService.getRoomMessageHistory(roomId).then((messages) {
      print('messages: ${messages.map((m) => m.toJson())}');
      if (messages.isNotEmpty) {
        _roomMessages[roomId]?.value = messages;
      }
    });
  }

  /// Close the messages stream for a room.
  void closeMessages(String roomId) {
    _roomMessages[roomId]?.dispose();
    _roomMessages.remove(roomId);
    _roomMessageSubscriptions.remove(roomId);
    _webSocketService.unsubscribeFromRoomMessagesStream(roomId);
  }

  /// Get the typing stream for a room.
  ValueNotifier<Typing?> getTyping(String roomId) {
    _roomTypings[roomId] ??= ValueNotifier(null);

    if (!_roomTypingSubscriptions.containsKey(roomId)) {
      // Use Future.microtask to avoid synchronous subscription
      Future.microtask(() => _subscribeToRoomTyping(roomId));

      log(
        'getTypingStream',
        'Subscribed to room typing stream for room $roomId',
      );
    }

    return _roomTypings[roomId]!;
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
  void closeTyping(String roomId) {
    _roomTypings[roomId]?.dispose();
    _roomTypings.remove(roomId);
    _roomTypingSubscriptions.remove(roomId);
    _webSocketService.unsubscribeFromRoomTypingStream(roomId);
  }

  /// Get the user presence stream.
  ValueNotifier<UserPresence?> getUserPresence(String userId) {
    _userPresences[userId] ??= ValueNotifier(null);

    if (!_userPresenceSubscriptions.containsKey(userId)) {
      // Use Future.microtask to avoid synchronous subscription
      Future.microtask(() => _subscribeToUserPresence(userId));

      log(
        'getUserPresenceStream',
        'Subscribed to user presence stream for user $userId',
      );
    }

    return _userPresences[userId]!;
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
  void closeUserPresence(String userId) {
    _userPresences[userId]?.dispose();
    _userPresences.remove(userId);
    _userPresenceSubscriptions.remove(userId);
    _webSocketService.unsubscribeFromUserPresenceStream(userId);
  }

  // ==============================
  // SEND-TO-STREAM-METHODS
  // ==============================

  /// Send a message to a room.
  void sendMessageToRoom(String roomId, String message) {
    final messageId = const Uuid().v4();
    _messageService.sendMessage(
      roomId,
      NewMessageRequest(
        id: messageId,
        roomId: roomId,
        text: message,
      ),
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

  /// Delete a message from a room.
  ///
  /// [roomId] The room ID.
  /// [messageId] The message ID.
  Future<void> deleteMessage(String roomId, String messageId) async {
    final success = await _messageService.deleteMessage(roomId, messageId);
    if (success) {
      print('success: $success');

      // handling this manually for the time being
      // until a better alternative is found.
      _handleDeleteMessageActivity([
        {'rid': roomId, '_id': messageId},
      ]);
    }
  }

  /// Send a user presence status.
  ///
  /// [status] The user presence status.
  void sendUserPresenceStatus(String status) {
    _webSocketService.sendUserPresence(status);
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

  /// Get the room message history.
  ///
  /// [roomId] The room ID.
  Future<List<Message>> getRoomMessageHistory(String roomId) {
    return _messageService.getRoomMessageHistory(roomId);
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
