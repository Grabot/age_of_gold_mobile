import 'package:flutter/material.dart';
import 'package:age_of_gold_mobile/utils/auth_store.dart';
import 'package:age_of_gold_mobile/views/components/shared_app_bar.dart';
import 'package:age_of_gold_mobile/models/group.dart';
import 'package:age_of_gold_mobile/utils/utils.dart';
import 'package:age_of_gold_mobile/views/age_of_gold_home/age_of_gold_home.dart';
import 'package:age_of_gold_mobile/views/profile/profile_page.dart';
import 'package:age_of_gold_mobile/views/groups/create_group_page.dart';

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

  Future<void> _loadGroups() async {
    // TODO: Implement group loading logic (e.g., from API or local storage)
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
    // TODO: Replace with actual group data from authStore or API
    final pendingInvites = <Group>[];
    final yourGroups = <Group>[];

    return ListView(
      children: [
        if (pendingInvites.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Pending Invites',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFf39c12),
              ),
            ),
          ),
          ...pendingInvites.map((group) => _buildGroupRequestTile(group)),
        ],
        if (yourGroups.isNotEmpty) ...[
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
        if (pendingInvites.isEmpty && yourGroups.isEmpty) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'You are not in any groups yet. Create or join a group to get started!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color hexToColour(String hexColour) {
    final buffer = StringBuffer();
    if (hexColour.length == 6 || hexColour.length == 7) {
      buffer.write('ff');
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Widget _buildGroupRequestTile(Group group) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFfff9f0),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(width: 3, color: Color(0xFFf39c12))),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          color: hexToColour(group.groupColour),
          child: Center(
            child: Text(
              group.groupName.isNotEmpty ? group.groupName.substring(0, 1).toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          group.groupName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Pending invite', style: TextStyle(color: Color(0xFFf39c12))),
        onTap: () => _showGroupDetailModal(group),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Color(0xFF27ae60)),
              onPressed: () => _acceptGroupInvite(group),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFFe74c3c)),
              onPressed: () => _rejectGroupInvite(group),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupTile(Group group) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(width: 3, color: Colors.blue)),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          color: hexToColour(group.groupColour) ?? getRandomColor(),
          child: Center(
            child: Text(
              group.groupName.isNotEmpty ? group.groupName.substring(0, 1).toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          group.groupName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Group', style: TextStyle(color: Colors.blue)),
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
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: hexToColour(group.groupColour),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          group.groupName.isNotEmpty ? group.groupName.substring(0, 1).toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      group.groupName,
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
    // TODO: Implement group-specific actions (e.g., leave group, view members)
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

  void _acceptGroupInvite(Group group) {
    // TODO: Implement logic to accept group invite
    showToastMessage('Group invite accepted!');
    setState(() {});
  }

  void _rejectGroupInvite(Group group) {
    // TODO: Implement logic to reject group invite
    showToastMessage('Group invite rejected');
    setState(() {});
  }

  void _leaveGroup(Group group) {
    // TODO: Implement logic to leave group
    showToastMessage('Left the group');
    setState(() {});
  }
}
