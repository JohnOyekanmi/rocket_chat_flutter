/// User presence class-enum.
class Presence {
  /// The offline presence.
  static const String offline = "offline";

  /// The online presence.
  static const String online = "online";

  /// The away presence.
  static const String away = "away";

  /// The busy presence.
  static const String busy = "busy";

  /// The list of all user presences.
  static const List<String> values = [offline, online, away, busy];

  /// Get the user presence from an integer.
  /// [value] The integer value.
  static String fromInt(int value) {
    return values[value];
  }
}

/// User presence model.
class UserPresence {
  final String userId;
  final String username;
  final String status;

  UserPresence(this.userId, this.username, this.status);

  factory UserPresence.fromList(List<dynamic> args) {
    return UserPresence(
      args[0] as String,
      args[1] as String,
      Presence.fromInt(args[2]),
    );
  }

  List<dynamic> toList() {
    return [userId, username, Presence.values.indexOf(status)];
  }

  @override
  String toString() {
    return 'UserPresence(userId: $userId, username: $username, presence: $status)';
  }
}
