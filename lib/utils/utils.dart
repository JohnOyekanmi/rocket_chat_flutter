class RocketChatFlutterUtils {
  /// Parse a date string or timestamp to a DateTime object.
  ///
  /// returns [DateTime.now] if the date is not a valid date string or timestamp.
  static DateTime parseDate(dynamic date) {
    if (date is String) {
      return DateTime.parse(date);
    }
    if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date);
    }

    return DateTime.now();
  }
}
