import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart';
import 'package:prm_smart_task/features/auth/data/datasources/google_auth_data_source.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.onIdToken,
    required this.onError,
    required this.dataSource,
  });

  final bool isLoading;
  final VoidCallback onPressed;
  final ValueChanged<String> onIdToken;
  final ValueChanged<Object> onError;
  final GoogleAuthDataSource dataSource;

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  StreamSubscription<GoogleSignInAuthenticationEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = GoogleSignIn.instance.authenticationEvents.listen(
      _handleAuthenticationEvent,
      onError: (Object error) {
        if (mounted) widget.onError(error);
      },
    );
    unawaited(_initializeGoogleSignIn());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await widget.dataSource.initialize();
    } catch (error) {
      if (mounted) widget.onError(error);
    }
  }

  void _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) {
    if (event case GoogleSignInAuthenticationEventSignIn(:final user)) {
      final idToken = user.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        widget.onError(
          StateError(
            'Google không trả về ID token. Hãy kiểm tra Web Client ID.',
          ),
        );
        return;
      }

      widget.onIdToken(idToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: AbsorbPointer(
        absorbing: widget.isLoading,
        child: renderButton(
          configuration: GSIButtonConfiguration(
            type: GSIButtonType.standard,
            theme: GSIButtonTheme.outline,
            size: GSIButtonSize.large,
            text: GSIButtonText.continueWith,
            shape: GSIButtonShape.rectangular,
            logoAlignment: GSIButtonLogoAlignment.left,
            minimumWidth: 250,
            locale: 'vi',
          ),
        ),
      ),
    );
  }
}
