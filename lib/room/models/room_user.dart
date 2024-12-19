/// The room user model.
class RoomUser {
  final String id;
  final String username;
  final String? name;  // nullable

  RoomUser({
    required this.id,
    required this.username,
    this.name,
  });

  factory RoomUser.fromJson(Map<String, dynamic> json) {
    return RoomUser(
      id: json['_id'],
      username: json['username'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      if (name != null) 'name': name,
    };
  }
} 