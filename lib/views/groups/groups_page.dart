import 'dart:math';

import 'package:flutter/material.dart';
import 'package:age_of_gold_mobile/utils/auth_store.dart';
import 'package:age_of_gold_mobile/views/components/shared_app_bar.dart';
import 'package:age_of_gold_mobile/models/group.dart';
import 'package:age_of_gold_mobile/utils/utils.dart';
import 'package:age_of_gold_mobile/views/age_of_gold_home/age_of_gold_home.dart';
import 'package:age_of_gold_mobile/views/profile/profile_page.dart';
import 'package:age_of_gold_mobile/views/groups/create_group_page.dart';
import 'package:age_of_gold_mobile/utils/storage.dart';
import 'package:age_of_gold_mobile/auth/groups_api.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  late AuthStore authStore;

  @override
  void initState() {
    super.initState();
    authStore = AuthStore();
    authStore.loadUserData().then((_) {
      _loadGroups();
    });
  }

  // TODO: Maybe move to a util function? similar to the avatar retrieve in friends page
  getGroupAvatar(Group group) async {
    final avatarBytes = await GroupsApi.getGroupAvatar(group.groupId);
    String avatarPath = await saveNewGroupAvatar(avatarBytes, group.groupId);
    group.avatarPath = avatarPath;
    group.avatar = avatarBytes;
    group.shouldUpdateAvatar = false;
    await Storage().updateGroup(group);
  }

  Future<void> _loadGroups() async {
    for (Group group in authStore.groups) {
      if ((group.shouldUpdateAvatar != null && group.shouldUpdateAvatar!) || group.avatarPath == null) {
        await getGroupAvatar(group);
      }
      if (group.avatar == null && group.avatarPath != null) {
        group.avatar = await loadAvatarBytes(group.avatarPath!);
      }
    }
    setState(() {});
  }

  Future<void> _refreshGroups() async {
    await _loadGroups();
  }

  void backButtonFunctionality() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AgeOfGoldHome()),
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
          title: 'Groups',
          homePage: const AgeOfGoldHome(),
          profilePage: const ProfilePage(),
          showHomeOption: true,
          showProfileOption: true,
          showFriendsOption: false,
          backButtonFunctionality: backButtonFunctionality,
        ),
        body: RefreshIndicator(
          onRefresh: _refreshGroups,
          child: _buildGroupsContent(),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'createGroupButton',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateGroupPage(),
              ),
            ).then((_) {
              setState(() {});
            });
          },
          child: const Icon(Icons.group_add),
        ),
      ),
    );
  }

  Widget _buildGroupsContent() {
    final yourGroups = authStore.groups;

    return yourGroups.isNotEmpty
        ? ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Your Groups',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        ...yourGroups.map((group) => _buildGroupTile(group)),
      ],
    )
        : const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text(
          'You are not in any groups yet. Create or join a group to get started!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String getRandomHexColour() {
    final random = Random();
    final hexColour = (random.nextDouble() * 0xFFFFFF).toInt().toRadixString(16).padLeft(6, '0');
    return '#$hexColour';
  }

  Color hexToColour(String? hexColour) {
    hexColour = hexColour?.replaceAll("#", "") ?? getRandomHexColour();
    if (hexColour.length == 6) {
      hexColour = "ff$hexColour";
    }
    return Color(int.parse(hexColour, radix: 16));
  }

  Widget _buildGroupTile(Group group) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hexToColour(group.groupColour),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: ListTile(
        leading: group.avatar != null
            ? Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: MemoryImage(group.avatar!),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        )
            : Container(
          width: 50,
          height: 50,
          color: Colors.white.withOpacity(0.9),
          child: Center(
            child: Text(
              group.groupName == null || group.groupName!.isEmpty
                  ? '?'
                  : group.groupName!.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Center(
          child: Text(
            group.groupName == null ? "?" : group.groupName!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        onTap: () => _showGroupDetailModal(group),
      ),
    );
  }

  void _showGroupDetailModal(Group group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Group Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    group.avatar != null
                        ? Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: MemoryImage(group.avatar!),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    )
                        : Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: hexToColour(group.groupColour),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          group.groupName == null || group.groupName!.isEmpty
                              ? '?'
                              : group.groupName!.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      group.groupName == null ? "?" : group.groupName!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (group.groupDescription != null)
                      Text(
                        group.groupDescription!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildGroupActionButtons(group),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupActionButtons(Group group) {
    return ElevatedButton(
      onPressed: () => _leaveGroup(group),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text('Leave Group'),
    );
  }

  Future<void> _leaveGroup(Group group) async {
    try {
      final response = await GroupsApi.leaveGroup(group.groupId);
      if (response.success == true) {
        authStore.groups.removeWhere((g) => g.groupId == group.groupId);
        await Storage().deleteGroup(group.groupId);
        showToastMessage('Left the group');
        setState(() {});
      } else {
        showToastMessage('Failed to leave group');
      }
    } catch (e) {
      showToastMessage('Failed to leave group: ${e.toString()}');
    }
  }
}
