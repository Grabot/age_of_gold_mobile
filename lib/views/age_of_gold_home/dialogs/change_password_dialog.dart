import 'package:flutter/material.dart';

class ChangePasswordDialog {
  static void showChangePasswordDialog(
    BuildContext context, {
    required Function(String) onSave,
    required bool isLoading,
  }) {
    final passwordController = TextEditingController(text: "");
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter your new password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
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
                          onSave(passwordController.text);
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
