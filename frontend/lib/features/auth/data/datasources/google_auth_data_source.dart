import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthDataSource {
  GoogleAuthDataSource({String? webClientId})
    : _webClientId =
          webClientId ?? const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  final String _webClientId;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Future<void>? _initialization;

  Future<void> initialize() => _ensureInitialized();

  Future<String?> signInAndGetIdToken() async {
    if (_webClientId.isEmpty) {
      throw StateError('Chưa cấu hình GOOGLE_WEB_CLIENT_ID khi chạy Flutter.');
    }

    await _ensureInitialized();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw UnsupportedError(
        'Nền tảng này chưa hỗ trợ đăng nhập Google bằng ứng dụng.',
      );
    }

    try {
      final account = await _googleSignIn.authenticate();
      final authentication = account.authentication;
      final idToken = authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw StateError(
          'Google không trả về ID token. Hãy kiểm tra Web Client ID.',
        );
      }

      return idToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }

      throw Exception(
        error.description ?? 'Đăng nhập Google thất bại. Vui lòng thử lại.',
      );
    }
  }

  Future<void> _ensureInitialized() async {
    _initialization ??= _googleSignIn.initialize(
      clientId: kIsWeb ? _webClientId : null,
      serverClientId: kIsWeb ? null : _webClientId,
    );

    try {
      await _initialization;
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }
}
