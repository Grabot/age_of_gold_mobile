import 'dart:typed_data';

import 'package:age_of_gold_mobile/services/auth/auth_settings.dart';
import 'package:age_of_gold_mobile/utils/secure_storage.dart';
import 'package:age_of_gold_mobile/views/age_of_gold_home/dialogs/change_username_dialog.dart';
import 'package:age_of_gold_mobile/views/age_of_gold_home/dialogs/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'package:age_of_gold_mobile/utils/auth_store.dart';
import '../../utils/utils.dart';
import 'dialogs/change_avatar_dialog.dart';

class AgeOfGoldHome extends StatefulWidget {
  const AgeOfGoldHome({super.key});

  @override
  State<AgeOfGoldHome> createState() => _AgeOfGoldHomeState();
}

class _AgeOfGoldHomeState extends State<AgeOfGoldHome> {
  bool _isLoading = false;
  late AuthStore authStore;

  @override
  void initState() {
    super.initState();
    authStore = AuthStore();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SecureStorage().getShouldUpdateAvatar().then((shouldUpdate) async {
      if (shouldUpdate) {
        await _updateAvatar();
      }
    });
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _updateAvatar() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final avatarBytes = await AuthSettings().getAvatar(false);
      await AuthStore().saveNewAvatar(avatarBytes);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      showToastMessage('Failed to update avatar. Please try again later.');
    } finally {
      await SecureStorage().setShouldUpdateAvatar(false);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildAvatar() {
    return SizedBox(
      width: 120,
      height: 120,
      child:
          authStore.me.user.avatar != null
              ? Image.memory(
                authStore.me.user.avatar!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              )
              : Center(
                child: Text(
                  authStore.me.user.username.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
    );
  }

  Widget _buildSettingsButton() {
    return Positioned(
      top: 10,
      right: 20,
      child: PopupMenuButton<String>(
        enabled: !_isLoading,
        icon: const Icon(Icons.settings, color: Colors.grey),
        onSelected:
            _isLoading
                ? null
                : (value) {
                  if (value == 'logout') {
                    _showLogoutDialog(context);
                  } else if (value == 'change_username') {
                    _showChangeUsernameDialog(context);
                  } else if (value == 'change_avatar') {
                    _showChangeAvatarDialog(context).then((avatarChanged) {
                      if (mounted && avatarChanged) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Avatar updated successfully!'),
                          ),
                        );
                        setState(() {});
                      }
                    });
                  }
                },
        itemBuilder:
            (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'change_username',
                child: Text('Change Username'),
              ),
              const PopupMenuItem<String>(
                value: 'change_avatar',
                child: Text('Change Avatar'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAvatar(),
                const SizedBox(height: 20),
                Text(
                  authStore.me.user.username,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2C3E50),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                              _showLogoutDialog(context);
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildSettingsButton(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEF1F3),
      body: Stack(
        children: [
          Container(
            color: const Color(0xffEEF1F3),
            child: Center(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                child: _buildMainContent(),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    LogoutDialog.showLogoutDialog(context);
  }

  void updateUsername(String newUsername) async {
    try {
      await AuthSettings().updateUsername(newUsername);
      authStore.me.user.username = newUsername;
      authStore.me.save();
      int profileVersion = await SecureStorage().getProfileVersion();
      SecureStorage().setProfileVersion(profileVersion + 1);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username updated successfully!')),
      );
    } catch (e) {
      showToastMessage('Failed to update username: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showChangeUsernameDialog(BuildContext context) {
    ChangeUsernameDialog.showChangeUsernameDialog(
      context,
      currentUsername: authStore.me.user.username,
      onSave: (newUsername) {
        setState(() {
          _isLoading = true;
        });
        updateUsername(newUsername);
      },
      isLoading: _isLoading,
    );
  }

  Future<bool> _showChangeAvatarDialog(BuildContext context) async {
    final avatarChanged = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ChangeAvatarDialog(
          onSave: (Uint8List image, bool defaultAvatar) async {
            setState(() {
              _isLoading = true;
            });
            try {
              await authStore.saveNewAvatar(image);
              await authStore.me.save();
              if (authStore.me.user.avatarPath == null) {
                throw Exception("Avatar path is not found");
              }
              await AuthSettings().updateAvatar(
                authStore.me.user.avatarPath!,
                defaultAvatar,
              );
              int avatarVersion = await SecureStorage().getAvatarVersion();
              await SecureStorage().setAvatarVersion(avatarVersion + 1);
            } catch (e) {
              showToastMessage("Error saving avatar: $e");
              return false;
            } finally {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            }
            return true;
          },
        );
      },
    );

    return avatarChanged ?? false;
  }
}
