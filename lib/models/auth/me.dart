import 'dart:convert';
import 'package:age_of_gold_mobile/models/auth/user.dart';

import '../../utils/storage.dart';

class Me extends User {
  final int origin;
  final bool avatarDefault;

  Me({
    required int id,
    required String username,
    required int profileVersion,
    required int avatarVersion,
    required this.origin,
    this.avatarDefault = true,
    String? avatarPath,
  }) : super(id: id, username: username, profileVersion: profileVersion, avatarVersion: avatarVersion, avatarPath: avatarPath);

  String toJson() {
    return jsonEncode({
      'user': {
        'id': id,
        'username': username,
        'profileVersion': profileVersion,
        'avatarVersion': avatarVersion,
        'avatarPath': avatarPath,
      },
      'origin': origin,
      'avatarDefault': avatarDefault,
    });
  }

  factory Me.fromJson(Map<String, dynamic> json) {
    final userData = json['user'];
    return Me(
      id: userData['id'],
      username: userData['username'],
      profileVersion: userData['profileVersion'],
      avatarVersion: userData['avatarVersion'],
      origin: json['origin'],
      avatarDefault: json['avatarDefault'] as bool? ?? true,
      avatarPath: userData['avatarPath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'profileVersion': profileVersion,
      'avatarVersion': avatarVersion,
      'origin': origin,
      'avatarDefault': avatarDefault ? 1 : 0,
      'avatarPath': avatarPath,
    };
  }

  factory Me.fromMap(Map<String, dynamic> map) {
    return Me(
      id: map['id'],
      username: map['username'],
      profileVersion: map['profileVersion'],
      avatarVersion: map['avatarVersion'],
      origin: map['origin'],
      avatarDefault: map['avatarDefault'] == 1,
      avatarPath: map['avatarPath'],
    );
  }

  Future<void> save() async {
    await Storage().saveMe(this);
  }

  static Future<Me?> load() async {
    return Storage().getMe();
  }
}
