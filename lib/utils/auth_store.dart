import 'package:age_of_gold_mobile/auth/login_api.dart';
import 'package:age_of_gold_mobile/models/services/user_response.dart';
import 'package:age_of_gold_mobile/utils/secure_storage.dart';
import 'package:age_of_gold_mobile/utils/socket_services.dart';
import 'package:age_of_gold_mobile/utils/storage.dart';
import 'package:age_of_gold_mobile/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../auth/app_interceptors.dart';
import '../auth/user_api.dart';
import '../models/auth/me.dart';
import '../models/auth/user.dart';
import '../models/friend.dart';
import '../models/services/login_response.dart';
import '../auth/friends_api.dart';
import 'package:age_of_gold_mobile/constants/route_paths.dart' as routes;
import '../views/login/auth_page.dart';
import 'navigation_service.dart';

class AuthStore {
  static final AuthStore _instance = AuthStore._internal();

  final NavigationService navigationService = locator<NavigationService>();
  SecureStorage secureStorage = SecureStorage();
  AuthStore._internal();

  factory AuthStore() {
    return _instance;
  }

  Me? _me;
  List<Friend> _friends = [];

  List<Friend> get friends => _friends;

  Me get me {
    if (_me == null) {
      throw Exception("User not found.");
    }
    return _me!;
  }

  void setMe(Me me) {
    _me = me;
  }

  void setFriends(List<Friend> friends) {
    _friends = friends;
  }

  void updateFriend(Friend friend) {
    final index = _friends.indexWhere((f) => f.friendId == friend.friendId);
    if (index >= 0) {
      _friends[index] = friend;
    } else {
      _friends.add(friend);
    }
  }

  Future<bool> getUserDetails(LoginResponse loginResponse, int? origin) async {
    try {
      UserResponse userResponse = await UserApi.getUser(null);
      if (userResponse.success =
          false ||
          userResponse.id == null ||
          userResponse.username == null ||
          userResponse.profileVersion == null ||
          userResponse.avatarVersion == null) {
        throw Exception("User details are incomplete.");
      }
      User user = User(
        id: userResponse.id!,
        username: userResponse.username!,
        profileVersion: userResponse.profileVersion!,
        avatarVersion: userResponse.avatarVersion!,
      );
      Me? oldMe = await Storage().getMe();
      if (oldMe != null && oldMe.id != user.id) {
        // new user logged in!
        await Storage().clearMe();
        SecureStorage().clearMe();
      }
      Me me = Me(
        id: userResponse.id!,
        username: userResponse.username!,
        profileVersion: userResponse.profileVersion!,
        avatarVersion: userResponse.avatarVersion!,
        origin: 0,
      );
      if (oldMe != null) {
        // keep the old avatar path since it is probably unchanged.
        // If it is not it will detect this later
        me.avatarPath = oldMe.avatarPath;
      }
      me.save();
      _me = me;
      await secureStorage.setProfileVersion(loginResponse.profileVersion!);
      return true;
    } catch (e) {
      String errorMessage = "User not found.";
      if (e is AppException) {
        if (e.message != null) {
          errorMessage = e.message!;
        }
      }
      showToastMessage(errorMessage);
      return false;
    }
  }

  unsuccessfulLogin() async {
    showToastMessage("User not found");
    secureStorage.clearTokens();
    navigationService.navigateTo(routes.signInRoute);
  }

  Future<void> retrieveMissingFriends(
    List<int> friendIds,
    String accessToken,
  ) async {
    if (friendIds.isEmpty) {
      return;
    }

    try {
      // Call the backend API to fetch friends
      final friendsResponse = await FriendsApi.fetchAllFriends();

      if (friendsResponse.isNotEmpty) {
        // Process each friend from the response
        for (final friendData in friendsResponse) {
          // Get the stored user if available
          final storedUser = await Storage().getUser(friendData.friendId);

          // Create the friend object
          final friend = Friend(
            friendId: friendData.friendId,
            accepted: friendData.accepted,
            friendVersion: friendData.friendVersion,
            user: storedUser,
          );

          // Save to storage
          await Storage().saveFriend(friend);

          // Update in-memory store
          updateFriend(friend);
        }
      }
    } catch (error) {
      print('Failed to retrieve missing friends data: $error');
      rethrow;
    }
  }

  Future<void> retrieveMissingUsers(
    List<int> userIds,
    String accessToken,
  ) async {
    if (userIds.isEmpty) {
      return;
    }

    try {
      // Call the backend API to fetch multiple users
      final usersResponse = await FriendsApi.getMultipleUsers(userIds);

      if (usersResponse.isNotEmpty) {
        // Process each user from the response
        for (final userResponse in usersResponse) {
          // Check if we already have this user stored
          final storedUser = await Storage().getUser(userResponse.id);

          // Create the user object
          final user = User(
            id: userResponse.id,
            username: userResponse.username,
            profileVersion: userResponse.profileVersion,
            avatarVersion: userResponse.avatarVersion,
          );

          // Save to storage
          if (storedUser != null) {
            if (storedUser.avatarVersion != userResponse.avatarVersion) {
              user.shouldUpdateAvatar = true;
            }
            await Storage().updateUser(user);
          } else {
            await Storage().saveUser(user);
          }

          // Update any friends that reference this user
          for (final friend in _friends) {
            if (friend.friendId == user.id) {
              friend.user = user;
            }
          }
        }
      }
    } catch (error) {
      print('Failed to retrieve missing users: $error');
      rethrow;
    }
  }

  Future<void> _handleLoginFriends(LoginResponse loginResponse) async {
    // Track user IDs and friend IDs that need retrieval
    final userIdsToRetrieve = <int>[];
    final friendIdsToRetrieve = <int>[];

    // Process each friend from the login response
    for (final friendLogin in loginResponse.friends!) {
      // Check if we have stored user data or need to retrieve it
      final storedUser = await Storage().getUser(friendLogin.friendId);
      final storedFriend = await Storage().getFriendByFriendId(
        friendLogin.friendId,
      );

      // Check if user needs retrieval
      if (storedUser == null) {
        userIdsToRetrieve.add(friendLogin.friendId);
      }

      // Check if friend needs retrieval or update
      if (storedFriend == null ||
          storedFriend.friendVersion != friendLogin.friendVersion) {
        friendIdsToRetrieve.add(friendLogin.friendId);
        if (!userIdsToRetrieve.contains(friendLogin.friendId)) {
          userIdsToRetrieve.add(friendLogin.friendId);
        }

        // Create/update friend entry
        final friend = Friend(
          friendId: friendLogin.friendId,
          accepted: friendLogin.accepted,
          friendVersion: friendLogin.friendVersion,
          user: storedUser,
        );

        await Storage().saveFriend(friend);
      } else {
        if (storedUser != null) {
          // If user is null it will be marked for retrieval.
          if (storedUser.avatarPath != null) {
            storedUser.avatar = await loadAvatarBytes(storedUser.avatarPath!);
          } else {
            if (storedUser.shouldUpdateAvatar != true) {
              storedUser.shouldUpdateAvatar = true;
              await Storage().updateUser(storedUser);
            }
          }
          storedFriend.user = storedUser;
        }
        updateFriend(storedFriend);
      }
    }

    // Retrieve missing friend data
    if (friendIdsToRetrieve.isNotEmpty) {
      await retrieveMissingFriends(
        friendIdsToRetrieve,
        loginResponse.accessToken!,
      );
    }

    // Retrieve missing user data
    if (userIdsToRetrieve.isNotEmpty) {
      await retrieveMissingUsers(userIdsToRetrieve, loginResponse.accessToken!);
    }
  }

  Future<void> loadUserData() async {
    final shouldUpdate = await SecureStorage().getShouldUpdateAvatar();
    if (shouldUpdate) {
      await updateAvatar();
    }
    return;
  }

  Future<void> updateAvatar() async {
    try {
      final avatarBytes = await UserApi.getAvatar(null, false);
      String avatarPath = await saveNewAvatar(avatarBytes, me.id);
      me.avatarPath = avatarPath;
      me.avatar = avatarBytes;
      await _me!.save();
      await SecureStorage().setShouldUpdateAvatar(false);
    } catch (e) {
      showToastMessage('Failed to update avatar. Please try again later.');
    } finally {
      await SecureStorage().setShouldUpdateAvatar(false);
    }
  }

  handleLoginResponse(LoginResponse loginResponse, int? origin) async {
    if (loginResponse.accessToken == null ||
        loginResponse.refreshToken == null) {
      throw Exception("Invalid login response: missing tokens");
    }
    await secureStorage.setAccessToken(loginResponse.accessToken!);
    await secureStorage.setRefreshToken(loginResponse.refreshToken!);
    await secureStorage.setAccessTokenExpiration(
      Jwt.parseJwt(loginResponse.accessToken!)['exp'],
    );
    await secureStorage.setRefreshTokenExpiration(
      Jwt.parseJwt(loginResponse.refreshToken!)['exp'],
    );

    int profileVersion = await secureStorage.getProfileVersion();
    if (profileVersion != loginResponse.profileVersion) {
      if (!await getUserDetails(loginResponse, origin)) {
        unsuccessfulLogin();
      }
    } else {
      // No updates needed, so take what's stored.
      Me? me = await Storage().getMe();
      if (me == null) {
        // User not found, let's try to retrieve it anyway
        if (!await getUserDetails(loginResponse, origin)) {
          unsuccessfulLogin();
        }
      }
      _me = me;
    }

    // Here `me` should be always filled)
    if (_me == null) {
      throw Exception("User not found.");
    }
    print("successful login!");
    SocketServices();

    int avatarVersion = await secureStorage.getAvatarVersion();
    if (avatarVersion != loginResponse.avatarVersion) {
      // Avatar has a change. Update it whenever we need to see the avatar.
      await secureStorage.setShouldUpdateAvatar(true);
      await secureStorage.setAvatarVersion(loginResponse.avatarVersion!);
    } else {
      if (_me!.avatarPath == null) {
        await secureStorage.setShouldUpdateAvatar(true);
      } else {
        if (await _me!.loadAvatarBytes() == false) {
          await secureStorage.setShouldUpdateAvatar(true);
        }
      }
    }

    // Handle friends from login response
    if (loginResponse.friends != null && loginResponse.friends!.isNotEmpty) {
      await _handleLoginFriends(loginResponse);
    }

    await updateValidationTimestamp();
  }

  updateValidationTimestamp() async {
    int validationTimestamp = DateTime.now().millisecondsSinceEpoch;
    await secureStorage.setLastValidation(validationTimestamp);
  }

  isValidationNeeded() async {
    int lastValidated = await SecureStorage().getLastValidation();
    int now = DateTime.now().millisecondsSinceEpoch;
    int oneMinute = 60 * 1000;
    if (now - lastValidated > oneMinute) {
      return true;
    } else {
      return false;
    }
  }

  validateToken() async {
    if (_me == null) {
      // No user logged in.
      return;
    }
    String? accessToken = await SecureStorage().getAccessToken();
    if (accessToken == null) {
      // No token saved.
      return;
    }
    try {
      LoginResponse loginResponse = await AuthLogin.loginToken();
      handleLoginResponse(loginResponse, null);
    } catch (e) {
      throw Exception("Token login failed.");
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await Storage().clearMe();
      await SecureStorage().clearTokens();
      await SecureStorage().clearMe();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
    } catch (e) {
      showToastMessage('Failed to logout: ${e.toString()}');
    }
  }
}
