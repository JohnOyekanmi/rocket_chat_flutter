<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

Initialize the RocketChat client:

```dart
import 'package:rocket_chat_flutter/rocket_chat_flutter.dart';

final rocketChat = RocketChatFlutter(
  serverUrl: 'https://your-rocketchat-server.com',
  webSocketUrl: 'wss://your-rocketchat-server.com',
  authToken: 'your-auth-token',
  userId: 'your-user-id',
);

// Initialize the connection
await rocketChat.init();
```

### Real-time Messaging

```dart
// Subscribe to room messages
rocketChat.getMessagesStream(roomId).listen((List<Message> messages) {
  // Handle new messages
});

// Send a text message
rocketChat.sendMessageToRoom(roomId, 'Hello, World!');

// Send media messages
final files = [File('path/to/file')];

// Images
rocketChat.sendImageMessage(roomId, 'Image caption', files);

// Audio
rocketChat.sendAudioMessage(roomId, 'Audio caption', files);

// Video
rocketChat.sendVideoMessage(roomId, 'Video caption', files);
```

### Room Management

```dart
// Create a Direct Message room
String roomId = await rocketChat.createNewRoom('username');

// Get room information
Room room = await rocketChat.getRoomInfo(roomId);

// Delete a room
await rocketChat.deleteRoom(roomId);

// Mark all messages as read
await rocketChat.markAllRoomMessagesAsRead(roomId);
```

### Real-time Subscriptions

```dart
// Listen to room subscription changes
rocketChat.getSubscriptionsStream().listen((List<RoomChange> changes) {
  // Handle subscription updates
});

// Listen to typing indicators
rocketChat.getTypingStream(roomId).listen((Typing typing) {
  // Handle typing status
});

// Send typing indicator
rocketChat.sendTypingStatus(roomId, username, true);
```

### User Presence

```dart
// Listen to user presence changes
rocketChat.getUserPresenceStream(userId).listen((UserPresence presence) {
  // Handle presence updates
});

// Update user presence
rocketChat.sendUserPresenceStatus(userId, 'online');
```

### Cleanup

```dart
// Close specific streams
rocketChat.closeMessagesStream(roomId);
rocketChat.closeTypingStream(roomId);
rocketChat.closeUserPresenceStream(userId);
rocketChat.closeRoomSubscriptionsStream();

// Dispose of the client when done
rocketChat.dispose();
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
