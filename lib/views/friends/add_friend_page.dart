import 'package:flutter/material.dart';
import 'package:age_of_gold_mobile/utils/auth_store.dart';
import 'package:age_of_gold_mobile/views/components/shared_app_bar.dart';
import 'package:age_of_gold_mobile/models/friend.dart';
import 'package:age_of_gold_mobile/models/auth/user.dart';
import 'package:age_of_gold_mobile/utils/storage.dart';
import 'package:age_of_gold_mobile/auth/friends_api.dart';
import 'package:age_of_gold_mobile/utils/utils.dart';
import 'package:age_of_gold_mobile/models/services/user_response.dart';
import 'package:age_of_gold_mobile/auth/auth_settings.dart';

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
      final response = await FriendsApi.searchFriend(query);
      if (response.success == true) {
        // TODO: Parse the actual user data from response
        // For now, we'll use a mock response since the backend structure might be different
        setState(() {
          searchResultUsername = query;
          searchResultId =
              999; // This should come from the actual API response
        });
      } else {
        setState(() {
          searchResultUsername = null;
        });
      }
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
        // Create a friend object
        final newFriend = Friend(
          friendId: searchResultId!,
          accepted: null, // Pending
          friendVersion: 1,
        );

        await Storage().saveFriend(newFriend);

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
                        CircleAvatar(
                          child: Text(
                            searchResultUsername!.substring(0, 1).toUpperCase(),
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
