import 'package:age_of_gold_mobile/utils/auth_store.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/auth/me.dart';

class SocketServices extends ChangeNotifier {
  late io.Socket socket;

  bool joinedSoloRoom = false;

  static final SocketServices _instance = SocketServices._internal();

  SocketServices._internal() {
    startSockConnection();
  }

  factory SocketServices() {
    return _instance;
  }

  void startSocketConnection() {
    if (!socket.connected) {
      socket.connect();
      joinRooms(AuthStore().me);
    }
  }

  startSockConnection() {
    String socketUrl = dotenv.env['BASE_URL'] ?? "";
    socket = io.io(socketUrl, <String, dynamic>{
      'autoConnect': true,
      'path': "/socket.io",
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      // Rejoin the channels and rooms
      joinRooms(AuthStore().me);
    });

    socket.onDisconnect((_) {});
    socket.open();
  }

  joinRooms(Me me) {
    leaveRoomSolo(me.id);
    joinRoomSolo(me.id);
  }

  void joinRoomSolo(int userId) {
    joinedSoloRoom = true;
    socket.emit("join_solo", {"user_id": userId});
    // First leave the rooms before joining them
    // This is to prevent multiple joins
    leaveSocketsSolo();
    joinSocketsSolo();
  }

  joinSocketsSolo() {}

  leaveSocketsSolo() {}

  void leaveRoomSolo(int userId) {
    joinedSoloRoom = false;
    socket.emit("leave_solo", {"user_id": userId});
    leaveSocketsSolo();
  }

  notify() {
    notifyListeners();
  }
}
