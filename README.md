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

First, initialize the messaging service:

```dart
import 'package:rocket_chat_flutter/rocket_chat_flutter.dart';

// Initialize the service
MessagingServices.instance.init(
  serverUrl: 'https://your-rocketchat-server.com',
  webSocketUrl: 'wss://your-rocketchat-server.com',
  authToken: 'your-auth-token',
  userId: 'your-user-id',
);
```

### Managing Direct Messages

```dart
// Create a DM
String? roomId = await MessagingServices.instance.createDM('username');

// Delete a DM
await MessagingServices.instance.deleteDM(roomId);

// Get room information
Room room = await MessagingServices.instance.getSingleRoom(roomId);
```

### Real-time Subscriptions and Messages

```dart
// Listen to subscription changes
MessagingServices.instance.getSubscriptionsStream().listen((List<RoomChange> changes) {
  // Handle subscription updates
});

// Listen to messages in a room
MessagingServices.instance.getMessagesStream(roomId).listen((List<Message> messages) {
  // Handle new messages
});

// Listen to typing indicators
MessagingServices.instance.getTypingStream(roomId).listen((Typing typing) {
  // Handle typing status
});
```

### Sending Messages

```dart
// Send text message
MessagingServices.instance.sendMessage(
  roomId: 'room-id',
  message: 'Hello!',
);

// Send audio message
MessagingServices.instance.sendAudioMessage(
  roomId: 'room-id',
  audioFiles: [File('path/to/audio')],
  message: 'Audio message caption',
);

// Send image message
MessagingServices.instance.sendImageMessage(
  roomId: 'room-id',
  imageFiles: [File('path/to/image')],
  message: 'Image caption',
);

// Send video message
MessagingServices.instance.sendVideoMessage(
  roomId: 'room-id',
  videoFiles: [File('path/to/video')],
  message: 'Video caption',
);
```

### User Presence

```dart
// Listen to user presence changes
MessagingServices.instance.getUserPresenceStream(userId).listen((UserPresence presence) {
  // Handle presence updates
});

// Update user presence
MessagingServices.instance.sendUserPresence(userId, Presence.online);
```

### Cleanup

```dart
// Don't forget to dispose when done
MessagingServices.instance.dispose();
```

### Message Read Status

```dart
// Mark all messages in a room as read
await MessagingServices.instance.markAllMessagesAsRead(roomId);
```

Remember to properly handle stream subscriptions and dispose of them when they're no longer needed. Each stream has a corresponding close method:

```dart
// Close specific streams
MessagingServices.instance.closeSubscriptionsStream();
MessagingServices.instance.closeMessagesStream(roomId);
MessagingServices.instance.closeTypingStream(roomId);
MessagingServices.instance.closeUserPresenceStream(userId);
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
