import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:age_of_gold_mobile/utils/auth_store.dart';
import 'package:age_of_gold_mobile/models/friend.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:age_of_gold_mobile/utils/utils.dart';
import 'package:age_of_gold_mobile/auth/groups_api.dart';

import '../../models/group.dart';
import '../../utils/storage.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController = TextEditingController();
  final List<Friend> _selectedFriends = [];
  late AuthStore authStore;
  late Color _groupColor;

  @override
  void initState() {
    super.initState();
    authStore = AuthStore();
    _groupColor = getRandomColor(); // Random default color
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _createGroup,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _groupDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Group Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Group Color: '),
                GestureDetector(
                  onTap: () => _pickColor(),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _groupColor,
                      border: Border.all(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Select Friends to Add'),
            Expanded(
              child: ListView.builder(
                itemCount: authStore.friends.length,
                itemBuilder: (context, index) {
                  final friend = authStore.friends[index];
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Center(
                      child: Text(friend.user?.username ?? 'Unknown'),
                    ),
                    value: _selectedFriends.contains(friend),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedFriends.add(friend);
                        } else {
                          _selectedFriends.remove(friend);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B9476),
                  ),
                  child: const Text('Create Group'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _pickColor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pick a color', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              ColorPicker(
                pickerColor: _groupColor,
                onColorChanged: (color) {
                  setState(() => _groupColor = color);
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> _createGroup() async {
    if (_groupNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group name is required')),
      );
      return;
    }
    if (_selectedFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one friend')),
      );
      return;
    }

    try {
      final groupId = await GroupsApi.createGroup(
        groupName: _groupNameController.text.trim(),
        groupDescription: _groupDescriptionController.text.trim(),
        groupColour: _groupColor.toARGB32().toRadixString(16).substring(2, 8),
        friendIds: _selectedFriends.map((friend) => friend.friendId).toList(),
      );

      final newGroup = Group(
        groupId: groupId,
        groupVersion: 1,
        groupName: _groupNameController.text.trim(),
        groupDescription: _groupDescriptionController.text.trim(),
        groupColour: _groupColor.toARGB32().toRadixString(16).substring(2, 8),
        userIds: _selectedFriends.map((friend) => friend.friendId).toList(),
        adminIds: [authStore.me.id],
        shouldUpdateAvatar: false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group created successfully!')),
        );
      }
      // Slight delay and then retrieve the avatar
      await Future.delayed(const Duration(seconds: 1));
      try {
        Uint8List groupAvatar = await GroupsApi.getGroupAvatar(groupId);
        newGroup.avatar = groupAvatar;
        newGroup.avatarPath = await saveNewGroupAvatar(groupAvatar, groupId);
        print("it managed to retrieve the avatar");
      } catch (e) {
        print('Failed to retrieve group avatar: $e');
        newGroup.shouldUpdateAvatar = true;
      }
      await Storage().saveGroup(newGroup);
      authStore.addGroup(newGroup);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create group: ${e.toString()}')),
        );
      }
    }
  }
}
