import 'package:flutter/material.dart';
import 'package:prm_smart_task/features/auth/data/datasources/google_auth_data_source.dart';

class GoogleSignInButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: const Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        label: const Text('Tiếp tục với Google'),
      ),
    );
  }
}
