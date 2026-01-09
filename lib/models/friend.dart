import 'package:age_of_gold_mobile/models/auth/user.dart';

class Friend {
  final int friendId;
  final bool? accepted;
  final int friendVersion;
  User? user;

  Friend({
    required this.friendId,
    this.accepted,
    required this.friendVersion,
    this.user,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      friendId: json['friend_id'] as int,
      accepted: json['accepted'] as bool?,
      friendVersion: json['friend_version'] as int,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
      'accepted': accepted,
      'friendVersion': friendVersion,
      'user': user?.toMap(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'friendId': friendId,
      'accepted': accepted != null ? (accepted! ? 1 : 0) : null,
      'friendVersion': friendVersion,
      'id': user?.id,
      'username': user?.username,
      'profileVersion': user?.profileVersion,
      'avatarVersion': user?.avatarVersion,
      'avatarPath': user?.avatarPath,
    };
  }

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      friendId: map['friendId'] as int,
      accepted: map['accepted'] != null ? (map['accepted'] == 1) : null,
      friendVersion: map['friendVersion'] as int,
      user:
          map['user_id_fk'] != null
              ? User(
                id: map['user_id_fk'] as int,
                username: map['username'] ?? '',
                profileVersion: map['profileVersion'] ?? 0,
                avatarVersion: map['avatarVersion'] ?? 0,
                avatarPath: map['avatarPath'] ?? '',
              )
              : null,
    );
  }
}
