import 'dart:io';
import 'dart:typed_data';

class User {
  final int id;
  late String username;
  Uint8List? avatar;
  String? avatarPath;
  int avatarVersion;
  int profileVersion;
  bool shouldUpdateAvatar = false;

  User({
    required this.id,
    required this.username,
    required this.avatarVersion,
    required this.profileVersion,
    this.avatarPath,
    this.shouldUpdateAvatar = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'] as int,
        username: json['username'] as String,
        avatarVersion: json['avatar_version'] as int,
        profileVersion: json['profile_version'] as int
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'avatarPath': avatarPath,
      'avatarVersion': avatarVersion,
      'profileVersion': profileVersion,
      'shouldUpdateAvatar': shouldUpdateAvatar ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      avatarPath: map['avatarPath'],
      avatarVersion: map['avatarVersion'],
      profileVersion: map['profileVersion'],
      shouldUpdateAvatar: map['shouldUpdateAvatar'] == 1,
    );
  }

  Future<bool> loadAvatarBytes() async {
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
