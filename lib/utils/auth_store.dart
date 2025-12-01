import 'dart:io';
import 'dart:typed_data';
import 'package:age_of_gold_mobile/models/services/user_response.dart';
import 'package:age_of_gold_mobile/services/auth/auth_settings.dart';
import 'package:age_of_gold_mobile/utils/secure_storage.dart';
import 'package:age_of_gold_mobile/utils/storage.dart';
import 'package:age_of_gold_mobile/utils/utils.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../models/auth/me.dart';
import '../models/auth/user.dart';
import '../models/services/login_response.dart';
import '../services/auth/app_interceptors.dart';
import 'package:age_of_gold_mobile/constants/route_paths.dart' as routes;
import 'navigation_service.dart';
import 'package:path_provider/path_provider.dart';

class AuthStore {
  static final AuthStore _instance = AuthStore._internal();

  final NavigationService navigationService = locator<NavigationService>();
  SecureStorage secureStorage = SecureStorage();
  AuthStore._internal();

  factory AuthStore() {
    return _instance;
  }

  Me? _me;
  Me get me {
    if (_me == null) {
      throw Exception("User not found.");
    }
    return _me!;
  }

  void setMe(Me me) {
    _me = me;
  }

  Future<bool> getUserDetails(LoginResponse loginResponse, int? origin) async {
    try {
      UserResponse userResponse = await AuthSettings().getUserDetails();
      User user = User(id: userResponse.id!, username: userResponse.username!);
      Me? oldMe = await Storage().getMe();
      if (oldMe != null && oldMe.id != user.id) {
        // new user logged in!
        await Storage().clearMe();
        SecureStorage().clearMe();
      }
      Me me = Me(user: user, origin: 0, avatarDefault: false);
      if (oldMe != null) {
        // keep the old avatar path since it is probably unchanged.
        // If it is not it will detect this later
        me.user.avatarPath = oldMe.user.avatarPath;
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

  successfulLogin(LoginResponse loginResponse, int? origin) async {
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

    int avatarVersion = await secureStorage.getAvatarVersion();
    if (avatarVersion != loginResponse.avatarVersion) {
      // Avatar has a change. Update it whenever we need to see the avatar.
      await secureStorage.setShouldUpdateAvatar(true);
      await secureStorage.setAvatarVersion(loginResponse.avatarVersion!);
    } else {
      if (_me!.user.avatarPath == null) {
        await secureStorage.setShouldUpdateAvatar(true);
      } else {
        if (await _me!.user.getAvatarBytes() == false) {
          await secureStorage.setShouldUpdateAvatar(true);
        }
      }
    }

    await updateValidationTimestamp();
  }

  updateValidationTimestamp() async {
    int validationTimestamp = DateTime.now().millisecondsSinceEpoch;
    await secureStorage.setLastValidation(validationTimestamp);
  }

  saveNewAvatar(Uint8List avatarBytes) async {
    final appDir = await getApplicationDocumentsDirectory();
    final avatarFile = File('${appDir.path}/avatar_${AuthStore().me.id}.png');
    await avatarFile.writeAsBytes(avatarBytes);
    _me!.user.avatarPath = avatarFile.path;
    _me!.user.avatar = avatarBytes;
    await _me!.save();
    await SecureStorage().setShouldUpdateAvatar(false);
  }
}
