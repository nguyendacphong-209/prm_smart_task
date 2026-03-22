import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
import 'package:prm_smart_task/features/auth/application/providers/auth_providers.dart';
import 'package:prm_smart_task/features/auth/presentation/widgets/auth_screen_container.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _avatarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _fullNameController.text = user?.fullName ?? '';
    _avatarController.text = user?.avatarUrl ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).updateProfile(
          fullName: _fullNameController.text.trim(),
          avatarUrl: _avatarController.text.trim().isEmpty
              ? null
              : _avatarController.text.trim(),
        );

    if (!mounted) return;

    final state = ref.read(authControllerProvider);
    if (success) {
      showAppSnack('Cập nhật hồ sơ thành công');
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
      title: 'Cập nhật hồ sơ',
      subtitle: 'Cập nhật nhanh thông tin hiển thị của bạn',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Thông tin cơ bản',
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
              controller: _avatarController,
              decoration: const InputDecoration(
                labelText: 'Avatar URL',
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
                    : const Text('Lưu thay đổi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
