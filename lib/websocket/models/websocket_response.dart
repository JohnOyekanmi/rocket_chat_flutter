// TODO: Create a WebSocketRequest model.

/// The WebSocket response model.
class WebSocketResponse {
  final String message;
  final String? id;
  final String? collection;
  final dynamic fields;
  final dynamic result;

  WebSocketResponse({
    required this.message,
    required this.id,
    this.collection,
    this.fields,
    this.result,
  });

  factory WebSocketResponse.fromJson(Map<String, dynamic> json) {
    return WebSocketResponse(
      message: json['msg'],
      id: json['id'],
      collection: json['collection'],
      fields: json['fields'],
      result: json['result'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': message,
      'id': id,
      'collection': collection,
      'fields': fields,
      'result': result,
    };
  }

  @override
  String toString() {
    return 'WebSocketResponse(msg: $message, id: $id, collection: $collection, fields: $fields, result: $result)';
  }
}
