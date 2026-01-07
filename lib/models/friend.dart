import 'package:age_of_gold_mobile/models/auth/user.dart';

class Friend {
  final int friendId;
  final bool? accepted;
  final int? friendVersion;
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
      'friend_id': friendId,
      'accepted': accepted,
      'friend_version': friendVersion,
      'user': user?.toMap(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'friend_id': friendId,
      'accepted': accepted != null ? (accepted! ? 1 : 0) : null,
      'friend_version': friendVersion,
      'user_id_fk': user?.id,
    };
  }

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      friendId: map['friend_id'],
      accepted: map['accepted'] != null ? (map['accepted'] == 1) : null,
      friendVersion: map['friend_version'],
      user:
          map['user_id_fk'] != null
              ? User(id: map['user_id_fk'], username: map['username'] ?? '')
              : null,
    );
  }
}
