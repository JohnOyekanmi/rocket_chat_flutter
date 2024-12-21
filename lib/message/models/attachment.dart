/// The room attachment model.
class MessageAttachment {
  final String? color;
  final String? text;
  final DateTime? timestamp;
  final String? thumbUrl;
  final String? messageLink;
  final bool? collapsed;
  final String? authorName;
  final String? authorLink;
  final String? authorIcon;
  final String? title;
  final String? titleLink;
  final bool? titleLinkDownload;
  final String? imageUrl;
  final String? audioUrl;
  final String? videoUrl;
  final List<AttachmentField>? fields;
  final String? description; // Added based on API docs

  MessageAttachment({
    this.color,
    this.text,
    this.timestamp,
    this.thumbUrl,
    this.messageLink,
    this.collapsed,
    this.authorName,
    this.authorLink,
    this.authorIcon,
    this.title,
    this.titleLink,
    this.titleLinkDownload,
    this.imageUrl,
    this.audioUrl,
    this.videoUrl,
    this.fields,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      if (color != null) 'color': color,
      if (text != null) 'text': text,
      if (timestamp != null) 'ts': timestamp?.toIso8601String(),
      if (thumbUrl != null) 'thumb_url': thumbUrl,
      if (messageLink != null) 'message_link': messageLink,
      if (collapsed != null) 'collapsed': collapsed,
      if (authorName != null) 'author_name': authorName,
      if (authorLink != null) 'author_link': authorLink,
      if (authorIcon != null) 'author_icon': authorIcon,
      if (title != null) 'title': title,
      if (titleLink != null) 'title_link': titleLink,
      if (titleLinkDownload != null) 'title_link_download': titleLinkDownload,
      if (imageUrl != null) 'image_url': imageUrl,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (videoUrl != null) 'video_url': videoUrl,
      if (fields != null) 'fields': fields?.map((e) => e.toJson()).toList(),
      if (description != null) 'description': description,
    };
  }

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      color: json['color'],
      text: json['text'],
      timestamp: json['ts'] != null ? DateTime.parse(json['ts']) : null,
      thumbUrl: json['thumb_url'],
      messageLink: json['message_link'],
      collapsed: json['collapsed'],
      authorName: json['author_name'],
      authorLink: json['author_link'],
      authorIcon: json['author_icon'],
      title: json['title'],
      titleLink: json['title_link'],
      titleLinkDownload: json['title_link_download'],
      imageUrl: json['image_url'],
      audioUrl: json['audio_url'],
      videoUrl: json['video_url'],
      description: json['description'],
      fields: (json['fields'] as List?)
          ?.map((e) => AttachmentField.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'MessageAttachment(color: $color, text: $text, timestamp: $timestamp, thumbUrl: $thumbUrl, messageLink: $messageLink, collapsed: $collapsed, authorName: $authorName, authorLink: $authorLink, authorIcon: $authorIcon, title: $title, titleLink: $titleLink, titleLinkDownload: $titleLinkDownload, imageUrl: $imageUrl, audioUrl: $audioUrl, videoUrl: $videoUrl, fields: $fields, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return other is MessageAttachment &&
        other.color == color &&
        other.text == text &&
        other.timestamp == timestamp &&
        other.thumbUrl == thumbUrl &&
        other.messageLink == messageLink &&
        other.collapsed == collapsed &&
        other.authorName == authorName &&
        other.authorLink == authorLink &&
        other.authorIcon == authorIcon &&
        other.title == title &&
        other.titleLink == titleLink &&
        other.titleLinkDownload == titleLinkDownload;
  }

  @override
  int get hashCode =>
      color.hashCode ^
      text.hashCode ^
      timestamp.hashCode ^
      thumbUrl.hashCode ^
      messageLink.hashCode ^
      collapsed.hashCode ^
      authorName.hashCode ^
      authorLink.hashCode ^
      authorIcon.hashCode ^
      title.hashCode ^
      titleLink.hashCode ^
      titleLinkDownload.hashCode;
}

class AttachmentField {
  final bool short;
  final String title;
  final String value;

  AttachmentField({
    required this.short,
    required this.title,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'short': short,
      'title': title,
      'value': value,
    };
  }

  factory AttachmentField.fromJson(Map<String, dynamic> json) {
    return AttachmentField(
      short: json['short'] as bool,
      title: json['title'] as String,
      value: json['value'] as String,
    );
  }

  @override
  String toString() {
    return 'AttachmentField(short: $short, title: $title, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return other is AttachmentField &&
        other.short == short &&
        other.title == title &&
        other.value == value;
  }

  @override
  int get hashCode => short.hashCode ^ title.hashCode ^ value.hashCode;
}
