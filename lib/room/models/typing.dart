class Typing {
  final String username;
  final bool isTyping;

  Typing({
    required this.username,
    required this.isTyping,
  });

  factory Typing.fromList(List<dynamic> data) {
    return Typing(
      username: data[0] as String,
      isTyping: data[1].isNotEmpty && data[1][0] == 'user-typing',
    );
  }

  @override
  String toString() => '$username is ${isTyping ? "typing" : "not typing"}';

  @override
  bool operator ==(Object other) {
    return other is Typing &&
        other.username == username &&
        other.isTyping == isTyping;
  }

  @override
  int get hashCode => username.hashCode ^ isTyping.hashCode;
}
