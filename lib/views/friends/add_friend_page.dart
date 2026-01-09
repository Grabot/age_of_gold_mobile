import 'dart:math';
import 'dart:typed_data';

import 'package:age_of_gold_mobile/auth/user_api.dart';
import 'package:flutter/material.dart';
import 'package:age_of_gold_mobile/utils/auth_store.dart';
import 'package:age_of_gold_mobile/views/components/shared_app_bar.dart';
import 'package:age_of_gold_mobile/models/friend.dart';
import 'package:age_of_gold_mobile/utils/storage.dart';
import 'package:age_of_gold_mobile/auth/friends_api.dart';
import 'package:age_of_gold_mobile/utils/utils.dart';

import '../../models/auth/user.dart';
import '../age_of_gold_home/age_of_gold_home.dart';
import '../profile/profile_page.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  late AuthStore authStore;
  final TextEditingController _searchController = TextEditingController();
  String? searchResultUsername;
  Uint8List? searchResultAvatar;
  int? searchResultProfileVersion;
  int? searchResultAvatarVersion;
  int? searchResultId;
  bool isSearching = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    authStore = AuthStore();
    authStore.loadUserData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUser() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
      isSearching = true;
      searchResultUsername = null;
      searchResultId = null;
    });

    try {
      final userResponse = await FriendsApi.searchFriend(query);
      if (userResponse.success = false || userResponse.id == null || userResponse.username == null || userResponse.profileVersion == null || userResponse.avatarVersion == null) {
        throw Exception("User details are incomplete.");
      }
      setState(() {
        searchResultUsername = userResponse.username;
        searchResultId = userResponse.id;
        searchResultProfileVersion = userResponse.profileVersion;
        searchResultAvatarVersion = userResponse.avatarVersion;
      });

      UserApi.getAvatar(userResponse.id, null).then((avatarResponse) {
        setState(() {
          searchResultAvatar = avatarResponse;
        });
      });
    } catch (e) {
      setState(() {
        searchResultUsername = null;
      });
      showToastMessage('Failed to search for user: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addFriend() async {
    if (searchResultId == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await FriendsApi.addFriend(searchResultId!);
      if (response.success == true) {
        String avatarPath = await saveNewAvatar(searchResultAvatar!, searchResultId!);
        User friendUser = User(
          id: searchResultId!,
          username: searchResultUsername!,
          profileVersion: searchResultProfileVersion!,
          avatarVersion: searchResultAvatarVersion!,
          avatarPath: avatarPath,
          shouldUpdateAvatar: false
        );
        friendUser.avatar = searchResultAvatar;
        final newFriend = Friend(
          friendId: searchResultId!,
          accepted: null, // Pending
          friendVersion: 1,
          user: friendUser
        );

        await Storage().saveUser(friendUser);
        await Storage().saveFriend(newFriend);

        authStore.updateFriend(newFriend);

        if (mounted) {
          showToastMessage('Friend request sent!');
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          showToastMessage('Failed to send friend request');
        }
      }
    } catch (e) {
      if (mounted) {
        showToastMessage('Failed to send friend request: ${e.toString()}');
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  backButtonFunctionality() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
          title: 'Add Friend',
          homePage: const AgeOfGoldHome(),
          profilePage: const ProfilePage(),
          showProfileOption: true,
          showHomeOption: true,
          backButtonFunctionality: backButtonFunctionality
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by username',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchUser,
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _searchUser(),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            if (isSearching && !isLoading) ...[
              if (searchResultUsername != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        searchResultAvatar != null
                            ? Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: MemoryImage(searchResultAvatar!),
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
                              searchResultUsername!.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(searchResultUsername!),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _addFriend,
                          child: const Text('Add Friend'),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const Text('No user found with that username.'),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
