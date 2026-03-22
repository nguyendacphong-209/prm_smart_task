import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
import 'package:prm_smart_task/core/theme/theme_mode_controller.dart';
import 'package:prm_smart_task/features/auth/application/providers/auth_providers.dart';
import 'package:prm_smart_task/features/auth/presentation/widgets/auth_screen_container.dart';
import 'package:prm_smart_task/shared/widgets/glass_card.dart';
import 'package:prm_smart_task/shared/widgets/skeleton_loading.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);
    final user = state.user;
    final selectedThemeMode = ref.watch(themeModeProvider);
    final isDarkMode = selectedThemeMode == ThemeMode.dark;

    return AuthScreenContainer(
      title: 'Hồ sơ cá nhân',
      subtitle: 'Quản lý thông tin tài khoản và bảo mật',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.isLoading) ...[
            const SkeletonBox(height: 6, borderRadius: 999),
            const SizedBox(height: 10),
            const SkeletonBox(height: 56),
            const SizedBox(height: 8),
            const SkeletonBox(height: 56),
            const SizedBox(height: 12),
          ],
          GlassCard(
            style: GlassCardStyle.liquid,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin tài khoản',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(user?.fullName ?? '--')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.alternate_email_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(user?.email ?? '--')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            style: GlassCardStyle.liquid,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Giao diện',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      isDarkMode
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isDarkMode ? 'Dark mode' : 'Light mode',
                      ),
                    ),
                    Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        ref.read(themeModeProvider.notifier).setThemeMode(
                              value ? ThemeMode.dark : ThemeMode.light,
                            );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => context.push('/profile/edit'),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Cập nhật hồ sơ cá nhân'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => context.push('/profile/change-password'),
              icon: const Icon(Icons.lock_reset_rounded),
              label: const Text('Đổi mật khẩu'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).refreshMe();
                if (!context.mounted) return;
                final newState = ref.read(authControllerProvider);
                if (newState.errorMessage != null) {
                  showAppSnack(newState.errorMessage!);
                }
              },
              child: const Text('Làm mới hồ sơ'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (!context.mounted) return;
                context.go('/login');
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Đăng xuất'),
            ),
          ),
        ],
      ),
    );
  }
}
