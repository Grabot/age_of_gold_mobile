import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../auth/app_interceptors.dart';
import '../../../auth/auth_login.dart';
import '../../../utils/auth_store.dart';
import '../../../utils/secure_storage.dart';
import '../../../utils/utils.dart';

class OAuthWebviewDialog extends StatefulWidget {
  final Uri uri;
  final bool fromRegister;

  const OAuthWebviewDialog({
    super.key,
    required this.uri,
    required this.fromRegister,
  });

  @override
  OAuthWebviewDialogState createState() => OAuthWebviewDialogState();
}

class OAuthWebviewDialogState extends State<OAuthWebviewDialog> {
  late WebViewController webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (String url) {
                setState(() => _isLoading = false);
              },
              onNavigationRequest: (NavigationRequest request) async {
                final baseUrl = dotenv.env['BASE_URL'] ?? "";
                final callbackPath = '/auth/callback';
                if (request.url.startsWith('$baseUrl$callbackPath')) {
                  webViewController.loadRequest(Uri.parse('about:blank'));
                  final uri = Uri.parse(request.url);
                  final accessToken = uri.queryParameters["token"];
                  if (accessToken != null) {
                    try {
                      await SecureStorage().setAccessToken(accessToken);
                      await SecureStorage().setAccessTokenExpiration(
                        Jwt.parseJwt(accessToken)['exp'],
                      );
                      final loginResponse = await AuthLogin().loginToken();
                      // TODO: Pass origin to oauth webview?
                      int origin = 0;
                      await AuthStore().successfulLogin(loginResponse, origin);
                      if (!mounted) return NavigationDecision.prevent;
                      Navigator.of(context).pop(true);
                    } catch (e) {
                      final errorMessage =
                          e is AppException && e.message != null
                              ? e.message!
                              : "Sign in failed. Please try again.";
                      if (!mounted) return NavigationDecision.prevent;
                      showToastMessage(errorMessage);
                      Navigator.of(context).pop(false);
                    }
                  }
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          );
    try {
      await webViewController.loadRequest(widget.uri);
    } catch (e) {
      if (!mounted) return;
      showToastMessage("Failed to load OAuth page.");
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          color: Colors.transparent,
          child: Stack(
            children: [
              WebViewWidget(controller: webViewController),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
