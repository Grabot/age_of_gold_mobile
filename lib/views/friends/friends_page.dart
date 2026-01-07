import 'package:flutter/material.dart';
import 'package:age_of_gold_mobile/utils/auth_store.dart';
import 'package:age_of_gold_mobile/views/components/shared_app_bar.dart';
import 'package:age_of_gold_mobile/models/friend.dart';
import 'package:age_of_gold_mobile/utils/storage.dart';
import 'package:age_of_gold_mobile/auth/friends_api.dart';
import 'package:age_of_gold_mobile/utils/utils.dart';
import 'package:age_of_gold_mobile/views/age_of_gold_home/age_of_gold_home.dart';
import 'package:age_of_gold_mobile/views/profile/profile_page.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  late AuthStore authStore;
  List<Friend> friends = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    authStore = AuthStore();
    authStore.loadUserData().then((_) {
      _loadFriends();
    });
  }

  Future<void> _loadFriends() async {
    try {
      final apiFriends = await FriendsApi.fetchAllFriends();
      await Storage().clearFriends();
      for (var friend in apiFriends) {
        await Storage().saveFriend(friend);
      }
      final storedFriends = await Storage().getFriends();
      setState(() {
        friends = storedFriends;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showToastMessage('Failed to load friends: ${e.toString()}');
    }
  }

  Future<void> _refreshFriends() async {
    await _loadFriends();
  }

  void backButtonFunctionality() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => AgeOfGoldHome(key: UniqueKey())));
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
          child:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildFriendsContent(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/add-friend');
          },
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }

  Widget _buildFriendsContent() {
    // Group friends by status
    final incomingRequests = friends.where((f) => f.accepted == false).toList();
    final pendingRequests = friends.where((f) => f.accepted == null).toList();
    final acceptedFriends = friends.where((f) => f.accepted == true).toList();

    return ListView(
      children: [
        if (incomingRequests.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Incoming Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...incomingRequests.map(
            (friend) => _buildFriendTile(friend, isIncoming: true),
          ),
        ],
        if (pendingRequests.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Pending Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...pendingRequests.map(
            (friend) => _buildFriendTile(friend, isPending: true),
          ),
        ],
        if (acceptedFriends.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Your Friends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildFriendTile(
    Friend friend, {
    bool isIncoming = false,
    bool isPending = false,
  }) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(friend.user?.username.substring(0, 1).toUpperCase() ?? '?'),
      ),
      title: Text(friend.user?.username ?? 'Unknown User'),
      subtitle: Text(
        isIncoming
            ? 'Incoming request'
            : isPending
            ? 'Pending request'
            : 'Friends',
      ),
      trailing:
          isIncoming
              ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _acceptFriendRequest(friend),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _rejectFriendRequest(friend),
                  ),
                ],
              )
              : isPending
              ? IconButton(
                icon: const Icon(Icons.cancel, color: Colors.orange),
                onPressed: () => _cancelFriendRequest(friend),
              )
              : null,
    );
  }

  Future<void> _acceptFriendRequest(Friend friend) async {
    try {
      await FriendsApi.acceptFriendRequest(friend.friendId);
      await _loadFriends();
      showToastMessage('Friend request accepted!');
    } catch (e) {
      showToastMessage('Failed to accept friend request: ${e.toString()}');
    }
  }

  Future<void> _rejectFriendRequest(Friend friend) async {
    try {
      await FriendsApi.rejectFriendRequest(friend.friendId);
      await _loadFriends();
      showToastMessage('Friend request rejected');
    } catch (e) {
      showToastMessage('Failed to reject friend request: ${e.toString()}');
    }
  }

  Future<void> _cancelFriendRequest(Friend friend) async {
    try {
      await FriendsApi.cancelFriendRequest(friend.friendId);
      await _loadFriends();
      showToastMessage('Friend request cancelled');
    } catch (e) {
      showToastMessage('Failed to cancel friend request: ${e.toString()}');
    }
  }
}
