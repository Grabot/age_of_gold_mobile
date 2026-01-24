import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class Group {
  final int groupId;
  final int groupVersion;
  // TODO: Only groupId and groupVersion required.
  bool? shouldUpdateAvatar;
  int? unreadMessages;
  bool? mute;
  String? muteTimestamp;
  int? messageVersion;
  int? avatarVersion;
  int? lastMessageReadId;
  List<int>? userIds;
  List<int>? adminIds;
  String? groupName;
  bool? private;
  String? groupDescription;
  String? groupColour;
  int? currentMessageId;
  Uint8List? avatar;
  String? avatarPath;
  // TODO: List of users?
  // List<User> user = [];

  Group({
    required this.groupId,
    required this.groupVersion,
    this.unreadMessages,
    this.mute,
    this.muteTimestamp,
    this.messageVersion,
    this.avatarVersion,
    this.lastMessageReadId,
    this.userIds,
    this.adminIds,
    this.groupName,
    this.private,
    this.groupDescription,
    this.groupColour,
    this.currentMessageId,
    this.avatarPath,
    this.shouldUpdateAvatar,
  });

  // TODO: Only required?
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupId: json['group_id'] as int,
      groupVersion: json['group_version'] as int,
    );
  }

  // TODO: When to use this? Feels like a copy of the database mapper
  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupVersion': groupVersion,
      'unreadMessages': unreadMessages,
      'mute': mute,
      'muteTimestamp': muteTimestamp,
      'messageVersion': messageVersion,
      'avatarVersion': avatarVersion,
      'lastMessageReadId': lastMessageReadId,
      'userIds': userIds,
      'adminIds': adminIds,
      'groupName': groupName,
      'private': private,
      'groupDescription': groupDescription,
      'groupColour': groupColour,
      'currentMessageId': currentMessageId
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupVersion': groupVersion,
      'unreadMessages': unreadMessages,
      'mute': mute != null ? (mute! ? 1 : 0) : null,
      'muteTimestamp': muteTimestamp,
      'messageVersion': messageVersion,
      'avatarVersion': avatarVersion,
      'lastMessageReadId': lastMessageReadId,
      'userIds': jsonEncode(userIds),
      'adminIds': jsonEncode(adminIds),
      'groupName': groupName,
      'private': private != null ? (private! ? 1 : 0) : null,
      'groupDescription': groupDescription,
      'groupColour': groupColour,
      'currentMessageId': currentMessageId,
      'avatarPath': avatarPath,
      'shouldUpdateAvatar': shouldUpdateAvatar != null ? (shouldUpdateAvatar! ? 1 : 0) : null,
    };
  }

  // TODO: This is from when you retrieve the full data as opposed to the minimal data with the fromJson function. Maybe improve naming so this is more clear?
  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      groupId: map['group_id'] as int,
      groupVersion: map['group_version'] as int,
      unreadMessages: map['unread_messages'] != null ? (map['unread_messages'] as int) : null,
      mute: map['mute'] != null ? (map['mute'] == 1) : null,
      muteTimestamp: map['mute_timestamp'] != null ? (map['mute_timestamp'] as String) : null,
      messageVersion: map['message_version'] != null ? (map['message_version'] as int) : null,
      avatarVersion: map['avatar_version'] != null ? (map['avatar_version'] as int) : null,
      lastMessageReadId: map['last_message_read_id'] != null ? (map['last_message_read_id'] as int) : null,
      userIds: map['user_ids'] != null ? (map['user_ids'].cast<int>() as List<int>) : null,
      adminIds: map['admin_ids'] != null ? (map['admin_ids'].cast<int>() as List<int>) : null,
      groupName: map['group_name'] != null ? (map['group_name'] as String) : null,
      private: map['private'] != null ? (map['private'] as bool) : null,
      groupDescription: map['group_description'] != null ? (map['group_description'] as String) : null,
      groupColour:  map['group_colour'] != null ? (map['group_colour'] as String) : null,
      currentMessageId: map['current_message_id'] != null ? (map['current_message_id'] as int) : null,
      shouldUpdateAvatar: map['shouldUpdateAvatar'] != null ? (map['shouldUpdateAvatar'] == 1) : null,
    );
  }

  // TODO: Move to a util? Together with the user function?
  Future<bool> loadGroupAvatarBytes() async {
    if (avatarPath != null) {
      final avatarFile = File(avatarPath!);
      if (await avatarFile.exists()) {
        avatar = await avatarFile.readAsBytes();
        return true;
      }
    }
    return false;
  }
}
