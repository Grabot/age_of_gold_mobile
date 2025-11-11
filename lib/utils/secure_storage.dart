import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {

  final storage = const FlutterSecureStorage();

  final String _keyAccessToken = 'accessToken';
  final String _keyRefreshToken = 'refreshToken';
  final String _keyAccessTokenExpiration = 'accessTokenExpiration';
  final String _keyRefreshTokenExpiration = 'refreshTokenExpiration';

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

  Future<int?> getRefreshTokenExpiration() async {
    String? expiration = await storage.read(key: _keyRefreshTokenExpiration);
    return expiration != null ? int.parse(expiration) : null;
  }

  Future logout() async {
    await storage.delete(key: _keyAccessToken);
    await storage.delete(key: _keyRefreshToken);
    await storage.delete(key: _keyAccessTokenExpiration);
    await storage.delete(key: _keyRefreshTokenExpiration);
  }
}