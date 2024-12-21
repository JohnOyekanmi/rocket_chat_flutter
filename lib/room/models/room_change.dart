import 'subscription.dart';

class RoomChange {
  final String changeType;
  final Subscription subscription;

  RoomChange(this.changeType, this.subscription);

  factory RoomChange.fromList(List<dynamic> args) {
    return RoomChange(
      args[0] as String,
      Subscription.fromJson(args[1]),
    );
  }

  @override
  String toString() {
    return 'RoomChange(changeType: $changeType, subscription: $subscription)';
  }

  @override
  bool operator ==(Object other) {
    return other is RoomChange &&
        other.changeType == changeType &&
        other.subscription == subscription;
  }

  @override
  int get hashCode => changeType.hashCode ^ subscription.hashCode;
}

class RoomChangeType {
  static const updated = 'updated';
  static const inserted = 'inserted';
  static const removed = 'removed';

  static const List<String> values = [updated, inserted, removed];
}
