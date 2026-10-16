import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
import 'package:prm_smart_task/features/auth/application/providers/auth_providers.dart';
import 'package:prm_smart_task/features/auth/presentation/widgets/auth_screen_container.dart';
import 'package:file_picker/file_picker.dart';
import 'package:prm_smart_task/shared/application/controllers/image_upload_controller.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _avatarController = TextEditingController();
  String? _localAvatarUrl;

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

    final avatarUrl = _localAvatarUrl ?? _avatarController.text.trim();

    final success = await ref.read(authControllerProvider.notifier).updateProfile(
          fullName: _fullNameController.text.trim(),
          avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
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

  Future<void> _pickAndUploadAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      if (mounted) {
        showAppSnack('Không đọc được dữ liệu file');
      }
      return;
    }

    if (!mounted) return;

    final success = await ref
        .read(imageUploadControllerProvider.notifier)
        .uploadAvatar(bytes, file.name);

    if (!mounted) return;

    final uploadState = ref.read(imageUploadControllerProvider);
    if (success && uploadState.uploadedImageUrl != null) {
      setState(() {
        _localAvatarUrl = uploadState.uploadedImageUrl;
        _avatarController.text = uploadState.uploadedImageUrl!;
      });
      showAppSnack('Upload avatar thành công');
    } else {
      showAppSnack(uploadState.errorMessage ?? 'Upload avatar thất bại');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return AuthScreenContainer(
      title: 'Cập nhật hồ sơ',
      subtitle: 'Cập nhật nhanh thông tin hiển thị của bạn',
      icon: Icons.edit_note_rounded,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.45),
                      Theme.of(context)
                          .colorScheme
                          .secondary
                          .withValues(alpha: 0.25),
                    ],
                  ),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: (_avatarController.text.trim().isNotEmpty)
                      ? NetworkImage(_avatarController.text.trim())
                      : null,
                  child: _avatarController.text.trim().isNotEmpty
                      ? null
                      : const Icon(Icons.person_outline_rounded),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickAndUploadAvatar,
                icon: const Icon(Icons.image),
                label: const Text('Chọn avatar từ máy'),
              ),
            ),
            if (_localAvatarUrl?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                'Avatar mới đã được tải lên',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: state.isLoading ? null : _submit,
                icon: state.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                  label: Text(state.isLoading ? 'Đang lưu...' : 'Lưu thay đổi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
