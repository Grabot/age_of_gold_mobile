import 'package:flutter/material.dart';

class ChangeUsernameDialog {
  static void showChangeUsernameDialog(
    BuildContext context, {
    required String currentUsername,
    required Function(String) onSave,
    required bool isLoading,
  }) {
    final usernameController = TextEditingController(text: currentUsername);
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Username'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'New Username',
                  hintText: 'Enter your new username',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed:
                  isLoading
                      ? null
                      : () {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(context);
                          onSave(usernameController.text);
                        }
                      },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
