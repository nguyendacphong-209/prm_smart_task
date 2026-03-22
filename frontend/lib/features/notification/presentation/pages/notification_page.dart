import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
import 'package:prm_smart_task/core/theme/app_theme.dart';
import 'package:prm_smart_task/features/notification/application/providers/notification_providers.dart';
import 'package:prm_smart_task/features/notification/domain/entities/task_notification.dart';
import 'package:prm_smart_task/shared/widgets/empty_state_view.dart';
import 'package:prm_smart_task/shared/widgets/error_state_view.dart';
import 'package:prm_smart_task/shared/widgets/glass_card.dart';
import 'package:prm_smart_task/shared/widgets/skeleton_loading.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  ProviderSubscription<dynamic>? _notificationSubscription;

  void _showSnack(String message) {
    final messenger = appScaffoldMessengerKey.currentState;
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Không rõ thời gian';
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();

    _notificationSubscription = ref.listenManual(
      notificationControllerProvider,
      (previous, next) {
        if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
          _showSnack(next.errorMessage!);
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationControllerProvider.notifier).loadNotifications();
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.close();
    super.dispose();
  }

  Future<void> _reload() {
    return ref.read(notificationControllerProvider.notifier).loadNotifications(
          forceReload: true,
        );
  }

  String _typeLabel(TaskNotification notification) {
    if (notification.isTaskAssigned) return 'Task được giao';
    if (notification.isTaskStatusChanged) return 'Task đổi trạng thái';
    if (notification.isWorkspaceInviteApprovalRequest) return 'Yêu cầu duyệt mời thành viên';
    if (notification.isWorkspaceInvitationApproved) return 'Lời mời vào workspace đã duyệt';
    if (notification.isWorkspaceInvitationRejected) return 'Yêu cầu mời bị từ chối';
    if (notification.isWorkspaceInvited) return 'Được thêm vào workspace';
    return notification.type;
  }

  IconData _typeIcon(TaskNotification notification) {
    if (notification.isTaskAssigned) return Icons.assignment_ind_outlined;
    if (notification.isTaskStatusChanged) return Icons.sync_alt_rounded;
    if (notification.isWorkspaceInviteApprovalRequest) return Icons.approval_outlined;
    if (notification.isWorkspaceInvitationApproved) return Icons.verified_outlined;
    if (notification.isWorkspaceInvitationRejected) return Icons.cancel_outlined;
    if (notification.isWorkspaceInvited) return Icons.group_add_outlined;
    return Icons.notifications_outlined;
  }

  Future<void> _handleNotificationTap(TaskNotification notification) async {
    if (!notification.isRead) {
      await ref
          .read(notificationControllerProvider.notifier)
          .markAsRead(notificationId: notification.id);
    }

    if (!mounted) return;
    if (notification.isWorkspaceInviteApprovalRequest &&
        notification.workspaceId != null &&
        notification.workspaceId!.isNotEmpty) {
      context.push('/workspaces/${notification.workspaceId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationControllerProvider);
    final colors = AppBackground.colors(Theme.of(context).brightness);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: SafeArea(
          child: state.isLoading
              ? const TabSkeletonView(cardCount: 2)
              : state.errorMessage != null && state.notifications.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: GlassCard(
                        style: GlassCardStyle.liquid,
                        child: ErrorStateView(
                          title: 'Không thể tải notifications',
                          message: state.errorMessage!,
                          actionLabel: 'Thử lại',
                          onAction: _reload,
                        ),
                      ),
                    )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  children: [
                    GlassCard(
                      style: GlassCardStyle.spotlight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Trung tâm thông báo',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.12),
                                ),
                                child: Text('Unread: ${state.unreadCount}'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonalIcon(
                              onPressed: state.unreadCount <= 0 || state.isSubmitting
                                  ? null
                                  : () async {
                                      final success = await ref
                                          .read(notificationControllerProvider.notifier)
                                          .markAllAsRead();
                                      if (!context.mounted || !success) return;
                                      showAppSnack('Đã đánh dấu tất cả là đã đọc');
                                    },
                              icon: state.isSubmitting
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.done_all_rounded),
                              label: const Text('Mark all as read'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (state.notifications.isEmpty)
                      GlassCard(
                        style: GlassCardStyle.liquid,
                        child: const EmptyStateView(
                          icon: Icons.notifications_active_outlined,
                          title: 'Chưa có thông báo mới',
                          message:
                              'Thông báo khi task được giao hoặc đổi trạng thái sẽ hiển thị tại đây.',
                        ),
                      )
                    else
                      ...state.notifications.map(
                        (notification) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GlassCard(
                            style: GlassCardStyle.liquid,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _handleNotificationTap(notification),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.16),
                                    ),
                                    child: Icon(
                                      _typeIcon(notification),
                                      size: 18,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _typeLabel(notification),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall,
                                              ),
                                            ),
                                            if (!notification.isRead)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(notification.content),
                                        const SizedBox(height: 6),
                                        Text(
                                          _formatDate(notification.createdAt),
                                          style: Theme.of(context).textTheme.labelSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
