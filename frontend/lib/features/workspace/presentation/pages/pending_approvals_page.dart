import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
import 'package:prm_smart_task/core/theme/app_theme.dart';
import 'package:prm_smart_task/features/workspace/application/providers/workspace_providers.dart';
import 'package:prm_smart_task/features/workspace/domain/entities/workspace_member.dart';
import 'package:prm_smart_task/shared/widgets/empty_state_view.dart';
import 'package:prm_smart_task/shared/widgets/error_state_view.dart';
import 'package:prm_smart_task/shared/widgets/glass_card.dart';
import 'package:prm_smart_task/shared/widgets/skeleton_loading.dart';

class PendingApprovalsPage extends ConsumerStatefulWidget {
  const PendingApprovalsPage({super.key, required this.workspaceId});

  final String workspaceId;

  @override
  ConsumerState<PendingApprovalsPage> createState() => _PendingApprovalsPageState();
}

class _PendingApprovalsPageState extends ConsumerState<PendingApprovalsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(workspaceControllerProvider.notifier)
          .loadWorkspaceDetail(workspaceId: widget.workspaceId);
    });
  }

  void _showSnack(String message) {
    final messenger = appScaffoldMessengerKey.currentState;
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _reload() async {
    await ref
        .read(workspaceControllerProvider.notifier)
        .loadWorkspaceDetail(workspaceId: widget.workspaceId);
  }

  Future<void> _approveMemberInvitation(WorkspaceMember member) async {
    final success = await ref
        .read(workspaceControllerProvider.notifier)
        .approveMemberInvitation(
          workspaceId: widget.workspaceId,
          userId: member.userId,
        );

    if (!mounted) return;
    final state = ref.read(workspaceControllerProvider);
    _showSnack(
      success
          ? (state.infoMessage ?? 'Đã duyệt lời mời thành viên')
          : (state.errorMessage ?? 'Không thể duyệt lời mời thành viên'),
    );
  }

  Future<void> _rejectMemberInvitation(WorkspaceMember member) async {
    final success = await ref
        .read(workspaceControllerProvider.notifier)
        .rejectMemberInvitation(
          workspaceId: widget.workspaceId,
          userId: member.userId,
        );

    if (!mounted) return;
    final state = ref.read(workspaceControllerProvider);
    _showSnack(
      success
          ? (state.infoMessage ?? 'Đã từ chối lời mời thành viên')
          : (state.errorMessage ?? 'Không thể từ chối lời mời thành viên'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workspaceControllerProvider);
    final colors = AppBackground.colors(Theme.of(context).brightness);
    final workspace = state.selectedWorkspace;
    final isOwner = workspace?.myRole.toLowerCase() == 'owner';
    final pendingMembers = state.members
        .where((member) => member.isPendingOwnerApproval)
        .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Pending approvals'),
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
          child: state.isLoading && workspace == null
              ? const TabSkeletonView(cardCount: 3)
              : state.errorMessage != null && workspace == null
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: GlassCard(
                        style: GlassCardStyle.liquid,
                        child: ErrorStateView(
                          title: 'Không thể tải danh sách duyệt',
                          message: state.errorMessage!,
                          actionLabel: 'Thử lại',
                          onAction: _reload,
                        ),
                      ),
                    )
                  : !isOwner
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: GlassCard(
                            style: GlassCardStyle.liquid,
                            child: const EmptyStateView(
                              icon: Icons.lock_outline_rounded,
                              title: 'Không có quyền truy cập',
                              message: 'Chỉ owner mới có thể duyệt lời mời vào workspace.',
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                          children: [
                            GlassCard(
                              style: GlassCardStyle.spotlight,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Yêu cầu chờ duyệt (${pendingMembers.length})',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (pendingMembers.isEmpty)
                              GlassCard(
                                style: GlassCardStyle.liquid,
                                child: const EmptyStateView(
                                  icon: Icons.approval_outlined,
                                  title: 'Không có yêu cầu chờ duyệt',
                                  message: 'Các yêu cầu mời từ admin sẽ hiển thị tại đây.',
                                ),
                              )
                            else
                              ...pendingMembers.map(
                                (member) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: GlassCard(
                                    style: GlassCardStyle.liquid,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.16),
                                          foregroundColor:
                                              Theme.of(context).colorScheme.primary,
                                          child: Text(
                                            (member.fullName.isNotEmpty
                                                    ? member.fullName
                                                    : member.email)
                                                .trim()
                                                .substring(0, 1)
                                                .toUpperCase(),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                member.fullName.isEmpty
                                                    ? member.email
                                                    : member.fullName,
                                                style: Theme.of(context).textTheme.titleSmall,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                member.email,
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Vai trò đề xuất: ${member.role}',
                                                style: Theme.of(context).textTheme.labelMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            FilledButton.tonal(
                                              onPressed: state.isSubmitting
                                                  ? null
                                                  : () => _approveMemberInvitation(member),
                                              child: const Text('Duyệt'),
                                            ),
                                            const SizedBox(height: 6),
                                            TextButton(
                                              onPressed: state.isSubmitting
                                                  ? null
                                                  : () => _rejectMemberInvitation(member),
                                              child: const Text('Từ chối'),
                                            ),
                                          ],
                                        ),
                                      ],
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
