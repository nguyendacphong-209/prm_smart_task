import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
import 'package:prm_smart_task/features/auth/application/providers/auth_providers.dart';
import 'package:prm_smart_task/features/auth/presentation/widgets/auth_screen_container.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _codeSent = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (!_emailFormKey.currentState!.validate()) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .requestPasswordReset(email: _emailController.text.trim());
    if (!mounted) return;

    final state = ref.read(authControllerProvider);
    if (success) {
      setState(() => _codeSent = true);
      showAppSnack(state.infoMessage ?? 'Hãy kiểm tra email để lấy mã khôi phục.');
    } else if (state.errorMessage != null) {
      showAppSnack(state.errorMessage!);
    }
  }

  Future<void> _resetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).resetPassword(
          email: _emailController.text.trim(),
          token: _codeController.text.trim(),
          newPassword: _newPasswordController.text,
          confirmNewPassword: _confirmPasswordController.text,
        );
    if (!mounted) return;

    final state = ref.read(authControllerProvider);
    if (success) {
      showAppSnack(state.infoMessage ?? 'Đặt lại mật khẩu thành công.');
      context.go('/login');
    } else if (state.errorMessage != null) {
      showAppSnack(state.errorMessage!);
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return AuthScreenContainer(
      title: 'Quên mật khẩu',
      subtitle: 'Nhận mã khôi phục qua email của bạn',
      icon: Icons.mark_email_read_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _emailFormKey,
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: !_codeSent,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              validator: _validateEmail,
            ),
          ),
          const SizedBox(height: 12),
          if (!_codeSent) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: state.isLoading ? null : _requestCode,
                icon: state.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.email_outlined),
                label: Text(state.isLoading ? 'Đang gửi...' : 'Gửi mã khôi phục'),
              ),
            ),
          ] else ...[
            Text(
              'Nhập mã trong email. Mã hết hạn sau 30 phút.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Form(
              key: _resetFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _codeController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: const InputDecoration(
                      labelText: 'Mã khôi phục',
                      prefixIcon: Icon(Icons.password_rounded),
                    ),
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? 'Vui lòng nhập mã khôi phục'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscurePassword,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu mới',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ).copyWith(
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                      ),
                    ),
                    validator: (value) {
                      final password = value ?? '';
                      if (password.isEmpty) return 'Vui lòng nhập mật khẩu mới';
                      if (password.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: const InputDecoration(
                      labelText: 'Xác nhận mật khẩu mới',
                      prefixIcon: Icon(Icons.verified_user_outlined),
                    ).copyWith(
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                        icon: Icon(_obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                      ),
                    ),
                    validator: (value) {
                      if ((value ?? '').isEmpty) {
                        return 'Vui lòng xác nhận mật khẩu mới';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Mật khẩu xác nhận không khớp';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: state.isLoading ? null : _resetPassword,
                      icon: state.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.lock_reset_rounded),
                      label: Text(
                        state.isLoading ? 'Đang cập nhật...' : 'Đặt lại mật khẩu',
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        TextButton(
                          onPressed: state.isLoading ? null : _requestCode,
                          child: const Text('Gửi lại mã'),
                        ),
                        TextButton(
                          onPressed: state.isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _codeSent = false;
                                    _emailController.clear();
                                    _codeController.clear();
                                    _newPasswordController.clear();
                                    _confirmPasswordController.clear();
                                  });
                                },
                          child: const Text('Đổi email'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          Center(
            child: TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Quay lại đăng nhập'),
            ),
          ),
        ],
      ),
    );
  }
}
