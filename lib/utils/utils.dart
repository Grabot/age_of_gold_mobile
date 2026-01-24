import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';

showToastMessage(String message) {
  showToast(
    message,
    duration: const Duration(milliseconds: 2000),
    position: ToastPosition.top,
    backgroundColor: Colors.white,
    radius: 1.0,
    textStyle: const TextStyle(fontSize: 30.0, color: Colors.black),
  );
}

Widget zwaarDevelopersLogo(double width, bool normalMode) {
  return Container(
    width: width,
    alignment: Alignment.center,
    child: Image.asset("assets/images/Zwaar_Logo.png"),
  );
}

Color getRandomColor() {
  final Random random = Random();
  return Color.fromARGB(
    255,
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
}

Future<String> saveNewAvatar(Uint8List avatarBytes, int userId) async {
  final appDir = await getApplicationDocumentsDirectory();
  final avatarFile = File('${appDir.path}/avatar_$userId.png');
  await avatarFile.writeAsBytes(avatarBytes);
  return avatarFile.path;
}

Future<String> saveNewGroupAvatar(Uint8List avatarBytes, int groupId) async {
  final appDir = await getApplicationDocumentsDirectory();
  final avatarFile = File('${appDir.path}/avatar_group_$groupId.png');
  await avatarFile.writeAsBytes(avatarBytes);
  return avatarFile.path;
}

Future<Uint8List> loadAvatarBytes(String avatarPath) async {
  final avatarFile = File(avatarPath);
  return await avatarFile.readAsBytes();
}
