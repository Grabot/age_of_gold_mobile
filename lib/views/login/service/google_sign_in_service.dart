import 'dart:async';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;

  final List<String> _scopes = <String>['email'];
  final _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  GoogleSignInService._internal() {
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize(
        clientId: Platform.isIOS ? dotenv.env['CLIENT_ID_IOS'] : null,
      );
      _isGoogleSignInInitialized = true;
    } catch (e) {
      // logging.error('Failed to initialize Google Sign-In: $e');
    }
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  GoogleSignInAuthentication getAuthTokens(GoogleSignInAccount account) {
    return account.authentication;
  }

  Future<String> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();

    try {
      final authClient = _googleSignIn.authorizationClient;
      var authorization = await authClient.authorizationForScopes(_scopes);
      authorization ??= await authClient.authorizeScopes(_scopes);
      return authorization.accessToken;
    } catch (error) {
      // logging.error('Google Sign In error: code: $error');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      // logging.error("Error signing out: $error");
      rethrow;
    }
  }
}
