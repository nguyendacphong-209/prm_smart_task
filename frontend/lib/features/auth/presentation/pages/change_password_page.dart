import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
import 'package:prm_smart_task/features/auth/application/providers/auth_providers.dart';
import 'package:prm_smart_task/features/auth/presentation/widgets/auth_screen_container.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success =
        await ref.read(authControllerProvider.notifier).changePassword(
              currentPassword: _currentPasswordController.text.trim(),
              newPassword: _newPasswordController.text.trim(),
              confirmNewPassword: _confirmPasswordController.text.trim(),
            );

    if (!mounted) return;

    final state = ref.read(authControllerProvider);
    if (success) {
      showAppSnack('Đổi mật khẩu thành công');
      context.pop();
      return;
    }

    if (state.errorMessage != null) {
      showAppSnack(state.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return AuthScreenContainer(
      title: 'Đổi mật khẩu',
      subtitle: 'Bảo vệ tài khoản với mật khẩu mới an toàn hơn',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Thông tin bảo mật',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu hiện tại',
                prefixIcon: Icon(Icons.lock_clock_outlined),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Vui lòng nhập mật khẩu hiện tại';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return 'Vui lòng nhập mật khẩu mới';
                if (v.length < 6) return 'Mật khẩu mới tối thiểu 6 ký tự';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                prefixIcon: Icon(Icons.verified_user_outlined),
              ),
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return 'Vui lòng xác nhận mật khẩu mới';
                if (v != _newPasswordController.text.trim()) {
                  return 'Mật khẩu xác nhận không khớp';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: state.isLoading ? null : _submit,
                child: state.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Xác nhận đổi mật khẩu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
