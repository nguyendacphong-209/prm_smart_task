import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
import 'package:prm_smart_task/features/auth/application/providers/auth_providers.dart';
import 'package:prm_smart_task/features/auth/presentation/widgets/auth_screen_container.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _avatarController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _fullNameController.text.trim(),
          avatarUrl: _avatarController.text.trim().isEmpty
              ? null
              : _avatarController.text.trim(),
        );

    if (!mounted) return;

    final state = ref.read(authControllerProvider);
    if (success) {
      context.go('/home');
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
      title: 'Đăng ký tài khoản',
      subtitle: 'Tạo tài khoản mới để bắt đầu làm việc ngay',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Thông tin đăng ký',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) return 'Vui lòng nhập họ tên';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return 'Vui lòng nhập email';
                if (!v.contains('@')) return 'Email không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return 'Vui lòng nhập mật khẩu';
                if (v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _avatarController,
              decoration: const InputDecoration(
                labelText: 'Avatar URL (không bắt buộc)',
                prefixIcon: Icon(Icons.image_outlined),
              ),
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
                    : const Text('Đăng ký'),
              ),
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                state.errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Đã có tài khoản? Quay lại đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}
