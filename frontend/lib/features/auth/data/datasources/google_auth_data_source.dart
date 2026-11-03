import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthDataSource {
  GoogleAuthDataSource({String? serverClientId})
    : _serverClientId =
          serverClientId ??
          const String.fromEnvironment(
            'GOOGLE_SERVER_CLIENT_ID',
            defaultValue:
                '958068311216-d4bc2l0s6bg8havpomk5jvemjss4oe4f.apps.googleusercontent.com',
          );

  final String _serverClientId;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Future<void>? _initialization;

  Future<void> initialize() => _ensureInitialized();

  Future<String?> signInAndGetIdToken() async {
    if (!kIsWeb && _serverClientId.isEmpty) {
      throw StateError(
        'Chưa cấu hình GOOGLE_SERVER_CLIENT_ID cho Google Sign-In.',
      );
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
      serverClientId: kIsWeb ? null : _serverClientId,
    );

    try {
      await _initialization;
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }
}
