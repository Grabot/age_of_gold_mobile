import 'package:age_of_gold_mobile/utils/auth_store.dart';
import 'package:flutter/material.dart';
import '../../models/friend.dart';

class CreateGroupPage extends StatefulWidget {

  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final List<Friend> _selectedFriends = [];
  late AuthStore authStore;

  @override
  void initState() {
    super.initState();
    authStore = AuthStore();
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: authStore.friends.length,
              itemBuilder: (context, index) {
                final friend = authStore.friends[index];
                return CheckboxListTile(
                  title: Text(friend.user?.username ?? 'Unknown'),
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
        ],
      ),
    );
  }

  void _createGroup() {
    if (_groupNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }
    if (_selectedFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one friend')),
      );
      return;
    }
    // TODO: Call API to create group
    Navigator.pop(context);
  }
}
