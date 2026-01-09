import 'package:age_of_gold_mobile/utils/auth_store.dart';
import 'package:age_of_gold_mobile/utils/storage.dart';
import 'package:age_of_gold_mobile/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/auth/me.dart';
import '../models/auth/user.dart';
import '../models/friend.dart';

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
    }
    joinRooms(AuthStore().me);
  }

  startSockConnection() {
    socket = io.io(dotenv.env['BASE_URL'], <String, dynamic>{
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
    socket.emit("join", {"user_id": userId});
    // First leave the rooms before joining them
    // This is to prevent multiple joins
    leaveSocketsSolo();
    joinSocketsSolo();
  }

  joinSocketsSolo() {
    print("Joining solo sockets");
    // Friend request received event
    socket.on('friend_request_received', (data) {
      _handleFriendRequestReceived(data);
    });

    // Friend request accepted event
    socket.on('friend_request_accepted', (data) {
      _handleFriendRequestAccepted(data);
    });

    // Friend request rejected event
    socket.on('friend_request_rejected', (data) {
      _handleFriendRequestRejected(data);
    });

    // Friend request canceled event
    socket.on('friend_request_canceled', (data) {
      _handleFriendRequestCanceled(data);
    });

    // Avatar updated event
    socket.on('avatar_updated', (data) {
      _handleAvatarUpdated(data);
    });

    // Username updated event
    socket.on('username_updated', (data) {
      _handleUsernameUpdated(data);
    });

    socket.on('friend_removed', (data) {
      _handleFriendRemoved(data);
    });
  }

  leaveSocketsSolo() {
    // Remove friend request received event
    socket.off('friend_request_received');

    // Remove friend request accepted event
    socket.off('friend_request_accepted');

    // Remove friend request rejected event
    socket.off('friend_request_rejected');

    // Remove friend request canceled event
    socket.off('friend_request_canceled');

    // Remove avatar updated event
    socket.off('avatar_updated');

    // Remove username updated event
    socket.off('username_updated');

    // Removed friend
    socket.off('friend_removed');
  }

  // Friend request received handler
  Future<void> _handleFriendRequestReceived(dynamic data) async {
    print('Friend request received: $data');
    try {
      // Extract data from socket event
      final friendId = data['friend_id'] as int;
      final username = data['username'] as String;
      final avatarVersion = data['avatar_version'] as int? ?? 1;
      final profileVersion = data['profile_version'] as int? ?? 1;

      final newFriend = Friend(
        friendId: friendId,
        accepted: false,
        friendVersion: 1,
        user: User(
          id: friendId,
          username: username,
          avatarVersion: avatarVersion,
          profileVersion: profileVersion,
          avatarPath: null,
        ),
      );

      // Save to storage
      await Storage().saveFriend(newFriend);

      // Update in-memory list
      AuthStore().updateFriend(newFriend);

      // Show notification
      showToastMessage('New friend request from $username!');
    } catch (e) {
      print('Error handling friend request received: $e');
    }
  }

  // Friend request accepted handler
  Future<void> _handleFriendRequestAccepted(dynamic data) async {
    print('Friend request accepted: $data');
    try {
      // Extract data from socket event
      final friendId = data['friend_id'] as int;
      final username = data['username'] as String;
      final avatarVersion = data['avatar_version'] as int? ?? 1;
      final profileVersion = data['profile_version'] as int? ?? 1;
      final accepted = data['accepted'] as bool? ?? true;
      final friendVersion = data['friend_version'] as int? ?? 1;

      final updatedFriend = Friend(
        friendId: friendId,
        accepted: accepted,
        friendVersion: friendVersion,
        user: User(
          id: friendId,
          username: username,
          avatarVersion: avatarVersion,
          profileVersion: profileVersion,
          shouldUpdateAvatar: true,
        ),
      );

      // Save to storage
      await Storage().saveFriend(updatedFriend);

      // Update in-memory list
      AuthStore().updateFriend(updatedFriend);

      // Show notification
      showToastMessage('Friend request accepted by $username!');
    } catch (e) {
      print('Error handling friend request accepted: $e');
    }
  }

  // Friend request rejected handler
  Future<void> _handleFriendRequestRejected(dynamic data) async {
    print('Friend request rejected: $data');
    try {
      // Extract data from socket event
      final friendId = data['friend_id'] as int;

      // Remove the friend from storage and memory
      await Storage().deleteFriend(friendId);

      // Remove from in-memory list
      AuthStore().friends.removeWhere((friend) => friend.friendId == friendId);

      // Show notification
      showToastMessage('Friend request rejected');
    } catch (e) {
      print('Error handling friend request rejected: $e');
    }
  }

  // Friend request canceled handler
  Future<void> _handleFriendRequestCanceled(dynamic data) async {
    print('Friend request canceled: $data');
    try {
      // Extract data from socket event
      final friendId = data['friend_id'] as int;

      // Remove the friend from storage and memory
      await Storage().deleteFriend(friendId);

      // Remove from in-memory list
      AuthStore().friends.removeWhere((friend) => friend.friendId == friendId);

      // Show notification
      showToastMessage('Friend request canceled');
    } catch (e) {
      print('Error handling friend request canceled: $e');
    }
  }

  // Avatar updated handler
  Future<void> _handleAvatarUpdated(dynamic data) async {
    print('Avatar updated: $data');
    try {
      // Extract data from socket event
      final userId = data['user_id'] as int;

      // Mark user for avatar update
      final user = await Storage().getUser(userId);
      if (user != null) {
        user.shouldUpdateAvatar = true;
        await Storage().saveUser(user);
      }

      // Update any friends that reference this user
      for (final friend in AuthStore().friends) {
        if (friend.friendId == userId && friend.user != null) {
          friend.user!.shouldUpdateAvatar = true;
          await Storage().updateFriend(friend);
        }
      }

      // Show notification
      showToastMessage('Avatar updated');
    } catch (e) {
      print('Error handling avatar updated: $e');
    }
  }

  // Username updated handler
  Future<void> _handleUsernameUpdated(dynamic data) async {
    print('Username updated: $data');
    try {
      // Extract data from socket event
      final userId = data['user_id'] as int;
      final newUsername = data['new_username'] as String;
      final profileVersion = data['profile_version'] as int? ?? 1;

      // Update user in storage
      final user = await Storage().getUser(userId);
      if (user != null) {
        user.username = newUsername;
        await Storage().saveUser(user);
      }

      // Update any friends that reference this user
      for (final friend in AuthStore().friends) {
        if (friend.friendId == userId && friend.user != null) {
          friend.user!.username = newUsername;
          await Storage().updateFriend(friend);
        }
      }

      // Show notification
      showToastMessage('Username updated to $newUsername');
    } catch (e) {
      print('Error handling username updated: $e');
    }
  }

  Future<void> _handleFriendRemoved(dynamic data) async {
    print('Friend removed: $data');
    try {
      final friendId = data['friend_id'] as int;

      // Remove the friend from storage and memory
      await Storage().deleteFriend(friendId);

      // Remove from in-memory list
      AuthStore().friends.removeWhere((friend) => friend.friendId == friendId);

      // Show notification
      showToastMessage('A friend removed you as a friend');
    } catch (e) {
      print('Error handling username updated: $e');
    }
  }

  void leaveRoomSolo(int userId) {
    joinedSoloRoom = false;
    socket.emit("leave", {"user_id": userId});
    leaveSocketsSolo();
  }

  notify() {
    notifyListeners();
  }
}
