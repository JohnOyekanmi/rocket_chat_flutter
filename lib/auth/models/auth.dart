class Auth {
  final String token;
  final String userId;

  Auth(this.token, this.userId);

  factory Auth.fromJson(Map<String, dynamic> json) {
    return Auth(json['token'], json['userId']);
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'userId': userId,
    };
  }

  @override
  String toString() {
    return 'Auth(token: $token, userId: $userId)';
  }


  @override
  bool operator ==(Object other) {
    return other is Auth && other.token == token && other.userId == userId;
  }

  @override
  int get hashCode => token.hashCode ^ userId.hashCode;
}
