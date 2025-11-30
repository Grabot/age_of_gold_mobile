import 'dart:convert';
import 'package:age_of_gold_mobile/models/auth/user.dart';

import '../../utils/storage.dart';

class Me {
  late User user;
  final bool origin;
  final bool avatarDefault;

  Me({
    required this.user,
    required this.origin,
    this.avatarDefault = true,
  });

  int get id => user.id;

  String toJson() {
    return jsonEncode({
      'user': {
        'id': user.id,
        'username': user.username,
      },
      'origin': origin,
      'avatarDefault': avatarDefault,
    });
  }

  factory Me.fromJson(Map<String, dynamic> json) {
    return Me(
      user: User.fromJson(json['user']),
      origin: json['origin'] as bool,
      avatarDefault: json['avatarDefault'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': user.id,
      'username': user.username,
      'origin': origin ? 1 : 0,
      'avatarDefault': avatarDefault ? 1 : 0,
      'avatarPath': user.avatarPath
    };
  }

  factory Me.fromMap(Map<String, dynamic> map) {
    return Me(
      user: User.fromMap(map),
      origin: map['origin'] == 1,
      avatarDefault: map['avatarDefault'] == 1,
      // avatarBytes: map['avatarBytes'] as Uint8List?,
    );
  }

  Future<void> save() async {
    await Storage().saveMe(this);
  }

  static Future<Me?> load() async {
    return Storage().getMe();
  }

}
