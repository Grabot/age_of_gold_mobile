import 'package:flutter/material.dart';
import 'package:age_of_gold_mobile/utils/auth_store.dart';
import '../age_of_gold_home/dialogs/logout_dialog.dart';

class SharedAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Widget? profilePage;
  final Widget? homePage;
  final bool showHomeOption;

  const SharedAppBar({
    super.key,
    required this.title,
    this.profilePage,
    this.homePage,
    this.showHomeOption = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<SharedAppBar> createState() => _SharedAppBarState();
}

class _SharedAppBarState extends State<SharedAppBar> {
  late AuthStore authStore;

  @override
  void initState() {
    super.initState();
    authStore = AuthStore();
    authStore.loadUserData().then((_) {
      setState(() {});
    });
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 40,
      height: 40,
      child:
          authStore.me.user.avatar != null
              ? Image.memory(authStore.me.user.avatar!)
              : Center(
                child: Text(
                  authStore.me.user.username.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildProfileAvatar(),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == 'profile' && widget.profilePage != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => widget.profilePage!),
              );
            } else if (value == 'home' && widget.homePage != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => widget.homePage!),
              );
            } else if (value == 'logout') {
              showDialog(
                context: context,
                builder: (BuildContext context) => const LogoutDialog(),
              );
            }
          },
          itemBuilder:
              (BuildContext context) => [
                if (widget.showHomeOption && widget.homePage != null)
                  const PopupMenuItem<String>(
                    value: 'home',
                    child: ListTile(
                      leading: Icon(Icons.home),
                      title: Text('Home'),
                    ),
                  ),
                if (widget.profilePage != null)
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile'),
                    ),
                  ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                  ),
                ),
              ],
        ),
      ],
    );
  }
}
