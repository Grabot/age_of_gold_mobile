
import 'dart:io';
import 'dart:typed_data';

class User {
  final int id;
  late String username;
  Uint8List? avatar;
  String? avatarPath;

  User({required this.id, required this.username, this.avatarPath});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'avatarPath': avatarPath,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      avatarPath: map['avatarPath'],
    );
  }

  Future<bool> getAvatarBytes() async {
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
