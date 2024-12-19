class ProfileInfo {
  final String id;
  final String name;
  final List<Email> emails;
  final String status;
  final String statusConnection;
  final String username;
  final int utcOffset;
  final bool active;
  final List<String> roles;
  final Settings settings;
  final CustomFields? customFields;
  final String? avatarUrl;
  final bool success;

  ProfileInfo({
    required this.id,
    required this.name,
    required this.emails,
    required this.status,
    required this.statusConnection,
    required this.username,
    required this.utcOffset,
    required this.active,
    required this.roles,
    required this.settings,
    this.customFields,
    this.avatarUrl,
    required this.success,
  });

  factory ProfileInfo.fromJson(Map<String, dynamic> json) {
    return ProfileInfo(
      id: json['_id'],
      name: json['name'],
      emails: (json['emails'] as List)
          .map((email) => Email.fromJson(email))
          .toList(),
      status: json['status'],
      statusConnection: json['statusConnection'],
      username: json['username'],
      utcOffset: json['utcOffset'],
      active: json['active'],
      roles: List<String>.from(json['roles']),
      settings: Settings.fromJson(json['settings']),
      customFields: json['customFields'] != null
          ? CustomFields.fromJson(json['customFields'])
          : null,
      avatarUrl: json['avatarUrl'],
      success: json['success'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'emails': emails.map((email) => email.toJson()).toList(),
      'status': status,
      'statusConnection': statusConnection,
      'username': username,
      'utcOffset': utcOffset,
      'active': active,
      'roles': roles,
      'settings': settings.toJson(),
      'customFields': customFields?.toJson(),
      'avatarUrl': avatarUrl,
      'success': success,
    };
  }
}

class Email {
  final String address;
  final bool verified;

  Email({
    required this.address,
    required this.verified,
  });

  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      address: json['address'],
      verified: json['verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'verified': verified,
    };
  }
}

class Settings {
  final Preferences preferences;

  Settings({required this.preferences});

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      preferences: Preferences.fromJson(json['preferences']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferences': preferences.toJson(),
    };
  }
}

class Preferences {
  final bool enableAutoAway;
  final int idleTimeoutLimit;
  final int desktopNotificationDuration;
  final String audioNotifications;
  final String desktopNotifications;
  final String mobileNotifications;
  final bool unreadAlert;
  final bool useEmojis;
  final bool convertAsciiEmoji;
  final bool autoImageLoad;
  final bool saveMobileBandwidth;
  final bool collapseMediaByDefault;
  final bool hideUsernames;
  final bool hideRoles;
  final bool hideFlexTab;
  final bool hideAvatars;
  final String roomsListExhibitionMode;
  final String sidebarViewMode;
  final bool sidebarHideAvatar;
  final bool sidebarShowUnread;
  final bool sidebarShowFavorites;
  final String sendOnEnter;
  final int messageViewMode;
  final String emailNotificationMode;
  final bool roomCounterSidebar;
  final String newRoomNotification;
  final String newMessageNotification;
  final bool muteFocusedConversations;
  final int notificationsSoundVolume;

  Preferences({
    required this.enableAutoAway,
    required this.idleTimeoutLimit,
    required this.desktopNotificationDuration,
    required this.audioNotifications,
    required this.desktopNotifications,
    required this.mobileNotifications,
    required this.unreadAlert,
    required this.useEmojis,
    required this.convertAsciiEmoji,
    required this.autoImageLoad,
    required this.saveMobileBandwidth,
    required this.collapseMediaByDefault,
    required this.hideUsernames,
    required this.hideRoles,
    required this.hideFlexTab,
    required this.hideAvatars,
    required this.roomsListExhibitionMode,
    required this.sidebarViewMode,
    required this.sidebarHideAvatar,
    required this.sidebarShowUnread,
    required this.sidebarShowFavorites,
    required this.sendOnEnter,
    required this.messageViewMode,
    required this.emailNotificationMode,
    required this.roomCounterSidebar,
    required this.newRoomNotification,
    required this.newMessageNotification,
    required this.muteFocusedConversations,
    required this.notificationsSoundVolume,
  });

  factory Preferences.fromJson(Map<String, dynamic> json) {
    return Preferences(
      enableAutoAway: json['enableAutoAway'],
      idleTimeoutLimit: json['idleTimeoutLimit'],
      desktopNotificationDuration: json['desktopNotificationDuration'],
      audioNotifications: json['audioNotifications'],
      desktopNotifications: json['desktopNotifications'],
      mobileNotifications: json['mobileNotifications'],
      unreadAlert: json['unreadAlert'],
      useEmojis: json['useEmojis'],
      convertAsciiEmoji: json['convertAsciiEmoji'],
      autoImageLoad: json['autoImageLoad'],
      saveMobileBandwidth: json['saveMobileBandwidth'],
      collapseMediaByDefault: json['collapseMediaByDefault'],
      hideUsernames: json['hideUsernames'],
      hideRoles: json['hideRoles'],
      hideFlexTab: json['hideFlexTab'],
      hideAvatars: json['hideAvatars'],
      roomsListExhibitionMode: json['roomsListExhibitionMode'],
      sidebarViewMode: json['sidebarViewMode'],
      sidebarHideAvatar: json['sidebarHideAvatar'],
      sidebarShowUnread: json['sidebarShowUnread'],
      sidebarShowFavorites: json['sidebarShowFavorites'],
      sendOnEnter: json['sendOnEnter'],
      messageViewMode: json['messageViewMode'],
      emailNotificationMode: json['emailNotificationMode'],
      roomCounterSidebar: json['roomCounterSidebar'],
      newRoomNotification: json['newRoomNotification'],
      newMessageNotification: json['newMessageNotification'],
      muteFocusedConversations: json['muteFocusedConversations'],
      notificationsSoundVolume: json['notificationsSoundVolume'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableAutoAway': enableAutoAway,
      'idleTimeoutLimit': idleTimeoutLimit,
      'desktopNotificationDuration': desktopNotificationDuration,
      'audioNotifications': audioNotifications,
      'desktopNotifications': desktopNotifications,
      'mobileNotifications': mobileNotifications,
      'unreadAlert': unreadAlert,
      'useEmojis': useEmojis,
      'convertAsciiEmoji': convertAsciiEmoji,
      'autoImageLoad': autoImageLoad,
      'saveMobileBandwidth': saveMobileBandwidth,
      'collapseMediaByDefault': collapseMediaByDefault,
      'hideUsernames': hideUsernames,
      'hideRoles': hideRoles,
      'hideFlexTab': hideFlexTab,
      'hideAvatars': hideAvatars,
      'roomsListExhibitionMode': roomsListExhibitionMode,
      'sidebarViewMode': sidebarViewMode,
      'sidebarHideAvatar': sidebarHideAvatar,
      'sidebarShowUnread': sidebarShowUnread,
      'sidebarShowFavorites': sidebarShowFavorites,
      'sendOnEnter': sendOnEnter,
      'messageViewMode': messageViewMode,
      'emailNotificationMode': emailNotificationMode,
      'roomCounterSidebar': roomCounterSidebar,
      'newRoomNotification': newRoomNotification,
      'newMessageNotification': newMessageNotification,
      'muteFocusedConversations': muteFocusedConversations,
      'notificationsSoundVolume': notificationsSoundVolume,
    };
  }
}

class CustomFields {
  final String? twitter;

  CustomFields({this.twitter});

  factory CustomFields.fromJson(Map<String, dynamic> json) {
    return CustomFields(
      twitter: json['twitter'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'twitter': twitter,
    };
  }
}
