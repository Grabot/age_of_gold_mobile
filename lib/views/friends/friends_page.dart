import 'package:age_of_gold_mobile/views/friends/add_friend_page.dart';
import 'package:flutter/material.dart';
import 'package:age_of_gold_mobile/utils/auth_store.dart';
import 'package:age_of_gold_mobile/views/components/shared_app_bar.dart';
import 'package:age_of_gold_mobile/models/friend.dart';
import 'package:age_of_gold_mobile/utils/storage.dart';
import 'package:age_of_gold_mobile/auth/friends_api.dart';
import 'package:age_of_gold_mobile/utils/utils.dart';
import 'package:age_of_gold_mobile/views/age_of_gold_home/age_of_gold_home.dart';
import 'package:age_of_gold_mobile/views/profile/profile_page.dart';
import 'package:age_of_gold_mobile/views/friends/friend_detail_modal.dart';

import '../../auth/user_api.dart';
import '../../models/auth/user.dart';
import '../../models/services/basic_response.dart';
import '../../models/services/user_response.dart';
import '../groups/create_group_page.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  late AuthStore authStore;

  @override
  void initState() {
    super.initState();
    authStore = AuthStore();
    authStore.loadUserData().then((_) {
      _loadFriends();
    });
  }

  getUserAvatar(Friend friend) async {
    final avatarBytes = await UserApi.getAvatar(friend.friendId, null);
    String avatarPath = await saveNewAvatar(avatarBytes, friend.friendId);
    friend.user!.avatarPath = avatarPath;
    friend.user!.avatar = avatarBytes;
    friend.user!.shouldUpdateAvatar = false;
    await Storage().updateUser(friend.user!);
  }

  loadUserAvatar(Friend friend) async {
    if (friend.user!.shouldUpdateAvatar || friend.user!.avatarPath == null) {
      await getUserAvatar(friend);
    }
    if (friend.user!.avatar == null && friend.user!.avatarPath != null) {
      friend.user!.avatar = await loadAvatarBytes(friend.user!.avatarPath!);
    }
  }

  emergencyFallBack(Friend friend) async {
    UserResponse userResponse = await UserApi.getUser(friend.friendId);
    if (userResponse.success = false || userResponse.id == null || userResponse.username == null || userResponse.profileVersion == null || userResponse.avatarVersion == null) {
      print("Error loading user");
    } else {
      User friendUser = User(id: userResponse.id!, username: userResponse.username!, profileVersion: userResponse.profileVersion!, avatarVersion: userResponse.avatarVersion!);
      await Storage().saveUser(friendUser);
      friend.user = friendUser;
      await getUserAvatar(friend);
    }
  }

  Future<void> _loadFriends() async {
    for (Friend friend in authStore.friends) {
      if (friend.user == null) {
        User? user = await Storage().getUser(friend.friendId);
        if (user != null) {
          friend.user = user;
          await loadUserAvatar(friend);
        } else {
          await emergencyFallBack(friend);
        }
      } else {
        await loadUserAvatar(friend);
      }
    }
    setState(() {});
  }

  Future<void> _refreshFriends() async {
    await _loadFriends();
  }

  void backButtonFunctionality() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AgeOfGoldHome(key: UniqueKey())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (!didPop) {
          backButtonFunctionality();
        }
      },
      child: Scaffold(
        appBar: SharedAppBar(
          title: 'Friends',
          homePage: const AgeOfGoldHome(),
          profilePage: const ProfilePage(),
          showHomeOption: true,
          showProfileOption: true,
          showFriendsOption: false,
          backButtonFunctionality: backButtonFunctionality,
        ),
        body: RefreshIndicator(
          onRefresh: _refreshFriends,
          child: _buildFriendsContent(),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'createGroupButton',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateGroupPage(
                      key: UniqueKey(),
                    ),
                  ),
                ).then((_) {
                  setState(() {});
                });
              },
              child: const Icon(Icons.group_add),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'addFriendButton',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddFriendPage(key: UniqueKey())),
                ).then((_) {
                  setState(() {});
                });
              },
              child: const Icon(Icons.person_add),
            ),
        ],
        ),
      ),
    );
  }

  Widget _buildFriendsContent() {
    final incomingRequests =
        authStore.friends.where((f) => f.accepted == false && f.user != null).toList();
    final pendingRequests =
        authStore.friends.where((f) => f.accepted == null && f.user != null).toList();
    final acceptedFriends =
        authStore.friends.where((f) => f.accepted == true && f.user != null).toList();

    return ListView(
      children: [
        if (incomingRequests.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Incoming Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF27ae60),
              ),
            ),
          ),
          ...incomingRequests.map(
            (friend) => _buildFriendRequestTile(friend, isIncoming: true),
          ),
        ],
        if (pendingRequests.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Pending Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFf39c12),
              ),
            ),
          ),
          ...pendingRequests.map(
            (friend) => _buildFriendRequestTile(friend, isPending: true),
          ),
        ],
        if (acceptedFriends.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Your Friends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          ...acceptedFriends.map((friend) => _buildFriendTile(friend)),
        ],
        if (incomingRequests.isEmpty &&
            pendingRequests.isEmpty &&
            acceptedFriends.isEmpty) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'You don\'t have any friends yet. Add some friends to get started!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _removeFriend(Friend friend) async {
    try {
      BasicResponse response = await FriendsApi.rejectFriendRequest(friend.friendId);
      if (response.success == true) {
        Storage().deleteFriend(friend.friendId);
        authStore.friends.removeWhere((element) => element.friendId == friend.friendId);
        if (mounted) {
          showToastMessage('Friend removed');
          Navigator.pop(context);
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        showToastMessage('Failed to remove friend: ${e.toString()}');
      }
    }
  }

  Widget _buildActionButtons(Friend friend) {
    if (friend.accepted == true) {
      return ElevatedButton(
        onPressed: () {
          _removeFriendRequest(friend);
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Remove Friend'),
      );
    } else if (friend.accepted == null) {
      return ElevatedButton(
        onPressed: () {
          _cancelFriendRequest(friend);
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFf39c12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Cancel Request'),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              _acceptFriendRequest(friend);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27ae60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Accept'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              _rejectFriendRequest(friend);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Reject'),
          ),
        ],
      );
    }
  }

  void _showFriendDetailModal(Friend friend) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                image: friend.user?.avatar != null
                                    ? DecorationImage(
                                  image: MemoryImage(friend.user!.avatar!),
                                  fit: BoxFit.cover,
                                )
                                    : null,
                                color: friend.user?.avatar == null ? getRandomColor() : null,
                              ),
                              child: friend.user?.avatar == null
                                  ? Center(
                                child: Text(
                                  friend.user?.username.substring(0, 1).toUpperCase() ?? '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ) : null,
                            ),
                            // Username
                            Text(
                              friend.user?.username ?? 'Unknown User',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Dynamic action buttons
                      _buildActionButtons(friend),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Friend Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: null,
                        child: const Icon(Icons.close, size: 24),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFriendRequestTile(
    Friend friend, {
    bool isIncoming = false,
    bool isPending = false,
  }) {
    final username = friend.user?.username ?? 'Unknown User';
    final initial =
        username.isNotEmpty ? username.substring(0, 1).toUpperCase() : '?';
    final statusText = isIncoming ? 'Incoming request' : 'Pending request';
    final statusColor =
        isIncoming ? const Color(0xFF27ae60) : const Color(0xFFf39c12);
    final backgroundColor =
        isIncoming ? const Color(0xFFf0fff7) : const Color(0xFFfff9f0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(width: 3, color: statusColor)),
      ),
      child: InkWell(
        onTap: () => _showFriendDetailModal(friend),
        child: ListTile(
          leading: friend.user != null && friend.user!.avatar != null
              ? Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: MemoryImage(friend.user!.avatar!),
                fit: BoxFit.cover,
              ),
            ),
          )
              : Container(
            width: 50,
            height: 50,
            color: getRandomColor(),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(
            username,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(statusText, style: TextStyle(color: statusColor)),
          trailing:
              isIncoming
                  ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Color(0xFF27ae60)),
                        onPressed: () => _acceptFriendRequest(friend),
                        tooltip: 'Accept',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFFe74c3c)),
                        onPressed: () => _rejectFriendRequest(friend),
                        tooltip: 'Reject',
                      ),
                    ],
                  )
                  : IconButton(
                    icon: const Icon(Icons.cancel, color: Color(0xFFf39c12)),
                    onPressed: () => _cancelFriendRequest(friend),
                    tooltip: 'Cancel',
                  ),
        ),
      ),
    );
  }

  Widget _buildFriendTile(Friend friend) {
    final username = friend.user?.username ?? 'Unknown User';
    final initial =
        username.isNotEmpty ? username.substring(0, 1).toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(width: 3, color: Colors.blue)),
      ),
      child: ListTile(
        leading: friend.user != null && friend.user!.avatar != null
            ? Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: MemoryImage(friend.user!.avatar!),
              fit: BoxFit.cover,
            ),
          ),
        )
            : Container(
          width: 50,
          height: 50,
          color: getRandomColor(),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        onTap: () => _showFriendDetailModal(friend),
        title: Text(
          username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Friends', style: TextStyle(color: Colors.blue)),
      ),
    );
  }

  Future<void> _acceptFriendRequest(Friend friend) async {
    try {
      BasicResponse acceptResponse = await FriendsApi.acceptFriendRequest(friend.friendId);
      if (acceptResponse.success == true) {
        friend.accepted = true;
        Storage().updateFriend(friend);
      }
      showToastMessage('Friend request accepted!');
      setState(() {});
    } catch (e) {
      showToastMessage('Failed to accept friend request: ${e.toString()}');
    }
  }

  Future<void> _rejectFriendRequest(Friend friend) async {
    try {
      BasicResponse rejectResponse = await FriendsApi.rejectFriendRequest(friend.friendId);
      if (rejectResponse.success == true) {
        Storage().deleteFriend(friend.friendId);
        authStore.friends.removeWhere((element) => element.friendId == friend.friendId);
      }
      showToastMessage('Friend request rejected');
      setState(() {});
    } catch (e) {
      showToastMessage('Failed to reject friend request: ${e.toString()}');
    }
  }

  Future<void> _cancelFriendRequest(Friend friend) async {
    try {
      BasicResponse cancelResponse = await FriendsApi.cancelFriendRequest(friend.friendId);
      if (cancelResponse.success == true) {
        Storage().deleteFriend(friend.friendId);
        authStore.friends.removeWhere((element) => element.friendId == friend.friendId);
      }
      showToastMessage('Friend request cancelled');
      setState(() {});
    } catch (e) {
      showToastMessage('Failed to cancel friend request: ${e.toString()}');
    }
  }

  Future<void> _removeFriendRequest(Friend friend) async {
    try {
      BasicResponse removeResponse = await FriendsApi.removeFriend(friend.friendId);
      if (removeResponse.success == true) {
        Storage().deleteFriend(friend.friendId);
        authStore.friends.removeWhere((element) => element.friendId == friend.friendId);
      }
      showToastMessage('Friendship is over');
      setState(() {});
    } catch (e) {
      showToastMessage('Failed to reject friend request: ${e.toString()}');
    }
  }
}
