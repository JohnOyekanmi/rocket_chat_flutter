class WebSocketHelper {
  /// Get the subscription ID.
  /// [moduleId] The module ID.
  static String getSubscriptionId(String moduleId) {
    return "$moduleId/subscription-id";
  }

  /// Get the user subscriptions request ID.
  /// [userId] The user ID.
  static String getUserSubscriptionsRequestId(String userId) {
    return "subscriptions/get/$userId";
  }

  /// Get the room message subscription ID.
  /// [roomId] The room ID.
  static String getRoomMsgSubId(String roomId) {
    return getSubscriptionId("$roomId/messages");
  }

  /// Get the room message subscription ID.
  /// [roomId] The room ID.
  static String getRoomDeletedMsgSubId(String roomId) {
    return getSubscriptionId("$roomId/deleteMessage");
  }

  /// Get the room typing subscription ID.
  /// [roomId] The room ID.
  static String getRoomTypingStatusSubId(String roomId) {
    return getSubscriptionId("$roomId/typing");
  }

  /// Get the user status subscription ID.
  /// [userId] The user ID.
  static String getUserPresenceSubId(String userId) {
    return getSubscriptionId("$userId/status");
  }

  /// Get the user typing status request ID.
  /// [username] The username.
  /// [roomId] The room ID.
  static String getUserTypingStatusRequestId(String username, String roomId) {
    return "userTyping/$roomId/$username-${DateTime.now().millisecondsSinceEpoch}";
  }

  /// Get the user status request ID.
  /// [userId] The user ID.
  static String getUserPresenceRequestId(String userId) {
    return "userStatus/$userId-${DateTime.now().millisecondsSinceEpoch}";
  }

  /// Get the create direct message request ID.
  /// [username] The username.
  static String getDMCreationRequestId(String username) {
    return "createDirectMessage/$username-${DateTime.now().millisecondsSinceEpoch}";
  }

  /// Get the update message request ID.
  /// [roomId] The room ID.
  /// [messageId] The message ID.
  static String getUpdateMsgRequestId(String roomId, String messageId) {
    return "updateMessage/$roomId/$messageId-${DateTime.now().millisecondsSinceEpoch}";
  }
}
