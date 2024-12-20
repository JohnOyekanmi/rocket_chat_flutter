import 'dart:convert';

import 'package:rocket_chat_flutter/auth/models/auth.dart';
import 'package:rocket_chat_flutter/utils/logger_mixin.dart';
import 'package:rocket_chat_flutter/websocket/models/collection_type.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'websocket_helper.dart';

class WebSocketService with LoggerMixin {
  final String url;
  final Auth authentication;
  final void Function(dynamic) onData;

  WebSocketService({
    required this.url,
    required this.authentication,
    required this.onData,
  });

  late WebSocketChannel _channel;

  /// Initialize the WebSocket service.
  void init() {
    setLogModule('WebSocketService');
    connect();
  }

  /// Dispose of the WebSocket service.
  void dispose() {
    _channel.sink.close();
  }

  /// Connect to the WebSocket server.
  Future<void> connect() async {
    _channel = WebSocketChannel.connect(Uri.parse('$url/websocket'));
    await _channel.ready;

    _channel.stream.listen(
      _handleMessage,
      onError: _handleError,
      onDone: _handleDone,
      cancelOnError: false,
    );

    _sendConnectRequest();
    _sendLoginRequest();
  }

  /// Reconnect to the WebSocket server.
  void _reconnect() {
    log('_reconnect', 'Reconnecting to WebSocket server');
    connect();
  }

  /// Get the WebSocket channel.
  WebSocketChannel get channel => _channel;

  /// Handle a message from the WebSocket server.
  void _handleMessage(dynamic message) {
    final msg = jsonDecode(message);

    if (msg['msg'] == 'ping') {
      _handleKeepAlive();
      return;
    }

    onData(msg);
  }

  /// Handle an error from the WebSocket server.
  void _handleError(Object error) {
    logE('_handleError', '$error');

    _reconnect();
  }

  /// Handle the WebSocket connection being closed.
  void _handleDone() {
    log('_handleDone', 'WebSocket connection closed');
  }

  /// Send a connect request to the WebSocket server.
  void _sendConnectRequest() {
    final msg = {
      "msg": "connect",
      "version": "1",
      "support": ["1", "pre2", "pre1"]
    };

    _sendWebSocketMessage(msg);
  }

  /// Send a login request to the WebSocket server.
  void _sendLoginRequest() {
    final msg = {
      "msg": "method",
      "method": "login",
      "id": "login-${DateTime.now().millisecondsSinceEpoch}",
      "params": [
        {"resume": authentication.token}
      ]
    };

    _sendWebSocketMessage(msg);
  }

  /// Handle a keep-alive message from the WebSocket server.
  void _handleKeepAlive() {
    final msg = {"msg": "pong"};

    _sendWebSocketMessage(msg);
  }

  /// Send a message through WebSocket with proper formatting
  /// [data] The message data to send
  void _sendWebSocketMessage(Map<String, dynamic> data) {
    final jsonData = jsonEncode(data);
    _channel.sink.add(jsonData);
  }

  /// Subscribe to a WebSocket event.
  /// [id] The subscription ID.
  /// [name] The subscription name.
  /// [event] The event to subscribe to.
  /// [persistent] Whether the subscription is persistent.
  void subscribe(
    String id,
    String name,
    String event, [
    bool persistent = true,
  ]) {
    final msg = {
      "msg": "sub",
      "id": id,
      "name": name,
      "params": [event, persistent]
    };

    _sendWebSocketMessage(msg);
  }

  /// Unsubscribe from a WebSocket event.
  /// [id] The subscription ID.
  void unsubscribe(String id) {
    final msg = {"msg": "unsub", "id": id};

    _sendWebSocketMessage(msg);
  }

  /// Stream user subscription.
  /// [userId] The user ID to stream subscription for.
  void subscribeToUserRoomSubscriptions() {
    subscribe(
      WebSocketHelper.getSubscriptionId(authentication.userId),
      CollectionType.STREAM_NOTIFY_USER,
      "${authentication.userId}/subscriptions-changed",
    );
  }

  /// Unsubscribe from user notifications.
  void unsubscribeFromUserRoomSubscriptions() {
    unsubscribe(WebSocketHelper.getSubscriptionId(authentication.userId));
  }

  /// Call a method on the WebSocket server.
  /// [message] The message type.
  /// [method] The method to call.
  /// [id] The method ID.
  /// [params] The method parameters.
  void call(String message, String method, String id, List<dynamic> params) {
    final msg = {"msg": message, "method": method, "id": id, "params": params};

    _sendWebSocketMessage(msg);
  }

  /// Stream room messages.
  /// [roomId] The room ID to stream messages for.
  void subscribeToRoomMessagesStream(String roomId) {
    subscribe(
      WebSocketHelper.getRoomMsgSubId(roomId),
      CollectionType.STREAM_ROOM_MESSAGES,
      roomId,
    );
  }

  /// Unsubscribe from room messages stream.
  /// [roomId] The room ID to unsubscribe from.
  void unsubscribeFromRoomMessagesStream(String roomId) {
    unsubscribe(WebSocketHelper.getRoomMsgSubId(roomId));
  }

  /// Get user subscriptions.
  void getUserSubscriptions() {
    call(
      "method",
      "subscriptions/get",
      WebSocketHelper.getUserSubscriptionsRequestId(authentication.userId),
      [],
    );
  }

  /// Stream room typing.
  /// [roomId] The room ID to stream typing for.
  void subscribeToRoomTypingStream(String roomId) {
    subscribe(
      WebSocketHelper.getRoomTypingStatusSubId(roomId),
      CollectionType.STREAM_NOTIFY_ROOM,
      "$roomId/user-activity",
    );
  }

  /// Unsubscribe from room typing stream.
  /// [roomId] The room ID to unsubscribe from.
  void unsubscribeFromRoomTypingStream(String roomId) {
    unsubscribe(WebSocketHelper.getRoomTypingStatusSubId(roomId));
  }

  /// Stream user presence.
  void subscribeToUserPresenceStream(String userId) {
    subscribe(
      WebSocketHelper.getUserPresenceSubId(userId),
      CollectionType.STREAM_NOTIFY_LOGGED,
      "user-status",
    );
  }

  /// Unsubscribe from user presence stream.
  void unsubscribeFromUserPresenceStream(String userId) {
    unsubscribe(WebSocketHelper.getUserPresenceSubId(userId));
  }

  // CALL METHODS =====>

  /// Send a user typing status request.
  /// [roomId] The room ID.
  /// [username] The username.
  /// [typing] Whether the user is typing.
  void sendUserTypingStatus(
    String roomId,
    String username,
    bool typing,
  ) {
    call(
      "method",
      CollectionType.STREAM_NOTIFY_ROOM,
      WebSocketHelper.getUserTypingStatusRequestId(username, roomId),
      [
        "$roomId/user-activity",
        username,
        typing ? ["user-typing"] : [],
        {}
      ],
    );
  }

  /// Send a user presence request.
  /// [status] The user presence status.
  void sendUserPresence(String status) {
    call(
      "method",
      "setUserStatus",
      WebSocketHelper.getUserPresenceRequestId(authentication.userId),
      [
        {"status": status}
      ],
    );
  }

  /// Create a direct message.
  /// [username] The username of the user to create a direct message with.
  void createDM(String username) {
    call(
      "method",
      "createDirectMessage",
      WebSocketHelper.getDMCreationRequestId(username),
      [username],
    );
  }

  /// Update a message.
  /// [messageId] The message ID.
  /// [message] The message to update.
  void updateMessage(String messageId, String roomId, String message) {
    call(
      "method",
      "updateMessage",
      WebSocketHelper.getUpdateMsgRequestId(roomId, messageId),
      [
        {"_id": messageId, "rid": roomId, "msg": message}
      ],
    );
  }
}
