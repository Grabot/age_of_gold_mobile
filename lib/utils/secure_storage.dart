import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {

  final storage = const FlutterSecureStorage();

  final String _keyAccessToken = 'accessToken';
  final String _keyRefreshToken = 'refreshToken';
  final String _keyAccessTokenExpiration = 'accessTokenExpiration';
  final String _keyRefreshTokenExpiration = 'refreshTokenExpiration';
  final String _keyProfileVersion = 'profileVersion';
  final String _keyAvatarVersion = 'avatarVersion';
  final String _keyShouldUpdateAvatar = "shouldUpdateAvatar";
  final String _keyLastValidation = "lastValidation";

  Future setAccessToken(String accessToken) async {
    await storage.write(key: _keyAccessToken, value: accessToken);
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: _keyAccessToken);
  }

  Future setAccessTokenExpiration(int expiration) async {
    await storage.write(key: _keyAccessTokenExpiration, value: expiration.toString());
  }

  Future<int?> getAccessTokenExpiration() async {
    String? expiration = await storage.read(key: _keyAccessTokenExpiration);
    return expiration != null ? int.parse(expiration) : null;
  }

  Future setRefreshToken(String refreshToken) async {
    await storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: _keyRefreshToken);
  }

  Future setRefreshTokenExpiration(int expiration) async {
    await storage.write(key: _keyRefreshTokenExpiration, value: expiration.toString());
  }

  clearTokens() {
    storage.delete(key: _keyAccessToken);
    storage.delete(key: _keyAccessTokenExpiration);
    storage.delete(key: _keyRefreshToken);
    storage.delete(key: _keyRefreshTokenExpiration);
    storage.delete(key: _keyProfileVersion);
  }

  clearMe() {
    storage.delete(key: _keyAvatarVersion);
    storage.delete(key: _keyShouldUpdateAvatar);
    storage.delete(key: _keyLastValidation);
  }

  Future<int?> getRefreshTokenExpiration() async {
    String? expiration = await storage.read(key: _keyRefreshTokenExpiration);
    return expiration != null ? int.parse(expiration) : null;
  }

  Future<int> getProfileVersion() async {
    String? profileVersion = await storage.read(key: _keyProfileVersion);
    return profileVersion != null ? int.parse(profileVersion) : 0;
  }

  Future setProfileVersion(int profileVersion) async {
    await storage.write(key: _keyProfileVersion, value: profileVersion.toString());
  }

  Future<int> getAvatarVersion() async {
    String? avatarVersion = await storage.read(key: _keyAvatarVersion);
    return avatarVersion != null ? int.parse(avatarVersion) : 0;
  }

  Future setAvatarVersion(int avatarVersion) async {
    await storage.write(key: _keyAvatarVersion, value: avatarVersion.toString());
  }

  Future<void> setShouldUpdateAvatar(bool value) async {
    await storage.write(key: _keyShouldUpdateAvatar, value: value.toString());
  }

  Future<bool> getShouldUpdateAvatar() async {
    final value = await storage.read(key: _keyShouldUpdateAvatar);
    return value != null ? value.toLowerCase() == 'true' : true;
  }

  Future<void> setLastValidation(int millisecondsSinceEpoch) async {
    await storage.write(key: _keyLastValidation, value: millisecondsSinceEpoch.toString());
  }

  Future<int> getLastValidation() async {
    final lastValidationString = await storage.read(key: _keyLastValidation);
    return lastValidationString != null ? int.parse(lastValidationString) : 0;
  }

  Future logout() async {
    await storage.delete(key: _keyAccessToken);
    await storage.delete(key: _keyRefreshToken);
    await storage.delete(key: _keyAccessTokenExpiration);
    await storage.delete(key: _keyRefreshTokenExpiration);
    await storage.delete(key: _keyProfileVersion);
    await storage.delete(key: _keyAvatarVersion);
    await storage.delete(key: _keyShouldUpdateAvatar);
    await storage.delete(key: _keyLastValidation);
  }
}