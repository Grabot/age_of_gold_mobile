import 'package:age_of_gold_mobile/utils/auth_store.dart';
import 'package:age_of_gold_mobile/utils/secure_storage.dart';
import 'package:flutter/material.dart';

import '../../../auth/auth_login.dart';
import '../../login/auth_page.dart';
import '../../login/service/google_sign_in_service.dart';

class LogoutDialog extends StatefulWidget {
  const LogoutDialog({super.key});

  @override
  LogoutDialogState createState() => LogoutDialogState();
}

class LogoutDialogState extends State<LogoutDialog> {
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    try {
      if (AuthStore().me.origin == 1) {
        await GoogleSignInService().signOut();
      }
      await AuthLogin().logout();
      await SecureStorage().clearTokens();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Logged out!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        // When it fails we still want to clear the tokens.
        // It would still count as a successful logout
        await SecureStorage().clearTokens();
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Logged out!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthPage()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _handleLogout,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Logout', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
