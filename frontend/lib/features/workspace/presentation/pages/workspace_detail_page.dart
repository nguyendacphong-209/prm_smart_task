import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
import 'package:prm_smart_task/core/theme/app_theme.dart';
import 'package:prm_smart_task/features/workspace/application/providers/workspace_providers.dart';
import 'package:prm_smart_task/features/workspace/domain/entities/workspace_member.dart';
import 'package:prm_smart_task/features/workspace/presentation/widgets/invite_member_dialog.dart';
import 'package:prm_smart_task/shared/widgets/empty_state_view.dart';
import 'package:prm_smart_task/shared/widgets/error_state_view.dart';
import 'package:prm_smart_task/shared/widgets/glass_card.dart';
import 'package:prm_smart_task/shared/widgets/skeleton_loading.dart';

class WorkspaceDetailPage extends ConsumerStatefulWidget {
  const WorkspaceDetailPage({super.key, required this.workspaceId});

  final String workspaceId;

  @override
  ConsumerState<WorkspaceDetailPage> createState() => _WorkspaceDetailPageState();
}

class _WorkspaceDetailPageState extends ConsumerState<WorkspaceDetailPage> {
  void _showSnack(String message) {
    final messenger = appScaffoldMessengerKey.currentState;
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(workspaceControllerProvider.notifier)
          .loadWorkspaceDetail(workspaceId: widget.workspaceId);
    });
  }

  Future<void> _reload() async {
    await ref
        .read(workspaceControllerProvider.notifier)
        .loadWorkspaceDetail(workspaceId: widget.workspaceId);
  }

  Future<void> _showEditWorkspaceDialog({
    required String workspaceId,
    required String currentName,
  }) async {
    var nextName = currentName;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
          title: const Text('Sửa workspace'),
          content: TextFormField(
            initialValue: currentName,
            onChanged: (value) => nextName = value,
            decoration: const InputDecoration(
              labelText: 'Tên workspace',
              prefixIcon: Icon(Icons.edit_outlined),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);

                final trimmedName = nextName.trim();
                if (trimmedName.length < 3) {
                  _showSnack('Tên workspace tối thiểu 3 ký tự');
                  return;
                }

                navigator.pop();

                final success = await ref
                    .read(workspaceControllerProvider.notifier)
                    .updateWorkspace(workspaceId: workspaceId, name: trimmedName);

                if (!mounted) return;

                final state = ref.read(workspaceControllerProvider);
                _showSnack(
                  success
                      ? 'Cập nhật workspace thành công'
                      : (state.errorMessage ?? 'Không thể cập nhật workspace'),
                );
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
    );
  }

  Future<void> _confirmDeleteWorkspace({
    required String workspaceId,
    required String workspaceName,
  }) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Xóa workspace'),
            content: Text('Bạn có chắc muốn xóa workspace "$workspaceName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Xóa'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    final success = await ref
        .read(workspaceControllerProvider.notifier)
        .deleteWorkspace(workspaceId: workspaceId);
    final state = ref.read(workspaceControllerProvider);

    if (success) {
      if (!mounted) return;
      context.pop();
      _showSnack('Xóa workspace thành công');
      return;
    }

    _showSnack(state.errorMessage ?? 'Không thể xóa workspace');
  }

  Future<void> _showInviteDialog() async {
    final payload = await showDialog<InviteMemberPayload>(
      context: context,
      builder: (_) => const InviteMemberDialog(),
    );

    if (!mounted || payload == null) return;

    final success = await ref
        .read(workspaceControllerProvider.notifier)
        .inviteMember(
          workspaceId: widget.workspaceId,
          email: payload.email,
          role: payload.role,
        );

    if (!mounted) return;
    if (success) {
      final state = ref.read(workspaceControllerProvider);
      _showSnack(state.infoMessage ?? 'Mời thành viên thành công');
    } else {
      final state = ref.read(workspaceControllerProvider);
      _showSnack(state.errorMessage ?? 'Không thể mời thành viên');
    }
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

  Future<void> _updateRole(WorkspaceMember member) async {
    final roles = ['member', 'admin'];

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: roles
                .map(
                  (role) => ListTile(
                    leading: Icon(
                      role == 'admin' ? Icons.shield_outlined : Icons.person_outline,
                    ),
                    title: Text(role == 'admin' ? 'Admin' : 'Member'),
                    trailing: member.role.toLowerCase() == role
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      if (member.role.toLowerCase() == role) return;

                      final success = await ref
                          .read(workspaceControllerProvider.notifier)
                          .updateMemberRole(
                            workspaceId: widget.workspaceId,
                            userId: member.userId,
                            role: role,
                          );

                      if (!mounted) return;
                      final state = ref.read(workspaceControllerProvider);
                      _showSnack(
                        success
                            ? 'Cập nhật vai trò thành công'
                            : (state.errorMessage ?? 'Không thể cập nhật vai trò'),
                      );
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Future<void> _removeMember(WorkspaceMember member) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Xóa thành viên'),
            content: Text('Bạn có chắc muốn xóa ${member.fullName} khỏi workspace?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Xóa'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    final success = await ref
        .read(workspaceControllerProvider.notifier)
        .removeMember(
          workspaceId: widget.workspaceId,
          userId: member.userId,
        );

    if (!mounted) return;
    final state = ref.read(workspaceControllerProvider);
    _showSnack(
      success ? 'Đã xóa thành viên' : (state.errorMessage ?? 'Không thể xóa thành viên'),
    );
  }

  String _memberRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'owner':
        return 'Owner';
      default:
        return 'Member';
    }
  }

  String _invitationStatusLabel(String invitationStatus) {
    switch (invitationStatus.toLowerCase()) {
      case 'pending_owner_approval':
        return 'Chờ owner duyệt';
      default:
        return 'Đang hoạt động';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workspaceControllerProvider);
    final colors = AppBackground.colors(Theme.of(context).brightness);
    final workspace = state.selectedWorkspace;
    final isOwner = workspace?.myRole.toLowerCase() == 'owner';
    final pendingApprovals = state.members.where((member) => member.isPendingOwnerApproval).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(workspace?.name ?? 'Chi tiết workspace'),
        actions: [
          if (workspace?.myRole.toLowerCase() == 'owner')
            PopupMenuButton<String>(
              enabled: !state.isSubmitting,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Sửa workspace'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Xóa workspace'),
                ),
              ],
              onSelected: (value) {
                if (workspace == null) return;

                if (value == 'edit') {
                  _showEditWorkspaceDialog(
                    workspaceId: workspace.id,
                    currentName: workspace.name,
                  );
                  return;
                }

                _confirmDeleteWorkspace(
                  workspaceId: workspace.id,
                  workspaceName: workspace.name,
                );
              },
            ),
          IconButton(
            onPressed: state.isSubmitting ? null : _showInviteDialog,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: 'Mời thành viên',
          ),
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
                          title: 'Không thể tải workspace',
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
                              Text(
                                workspace?.name ?? '--',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Vai trò của bạn',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 6),
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
                                child: Text(
                                  _memberRoleLabel(workspace?.myRole ?? 'member'),
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.tonalIcon(
                                  onPressed: () => context.push(
                                    '/workspaces/${widget.workspaceId}/projects',
                                  ),
                                  icon: const Icon(Icons.layers_outlined),
                                  label: const Text('Quản lý projects'),
                                ),
                              ),
                              if (isOwner) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.tonalIcon(
                                    onPressed: () => context.push(
                                      '/workspaces/${widget.workspaceId}/pending-approvals',
                                    ),
                                    icon: const Icon(Icons.approval_outlined),
                                    label: Text('Pending approvals (${pendingApprovals.length})'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        GlassCard(
                          style: GlassCardStyle.liquid,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Thành viên (${state.members.length})',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: state.isSubmitting ? null : _showInviteDialog,
                                icon: const Icon(Icons.person_add_alt_1_rounded),
                                label: const Text('Mời'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (state.members.isEmpty)
                          GlassCard(
                            style: GlassCardStyle.liquid,
                            child: EmptyStateView(
                              icon: Icons.group_off_rounded,
                              title: 'Chưa có thành viên',
                              message: 'Mời thành viên đầu tiên vào workspace để bắt đầu cộng tác.',
                              actionLabel: 'Mời thành viên',
                              onAction: _showInviteDialog,
                            ),
                          )
                        else
                          ...state.members.map(
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
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
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
                                          child: Text(
                                            _memberRoleLabel(member.role),
                                            style: Theme.of(context).textTheme.labelMedium,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(999),
                                            color: member.isPendingOwnerApproval
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withValues(alpha: 0.2)
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .tertiary
                                                    .withValues(alpha: 0.18),
                                          ),
                                          child: Text(
                                            _invitationStatusLabel(member.invitationStatus),
                                            style: Theme.of(context).textTheme.labelSmall,
                                          ),
                                        ),
                                        if (member.isPendingOwnerApproval && isOwner) ...[
                                          const SizedBox(height: 8),
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
                                        ] else
                                          PopupMenuButton<String>(
                                            enabled: !state.isSubmitting,
                                            itemBuilder: (context) => const [
                                              PopupMenuItem(
                                                value: 'role',
                                                child: Text('Đổi vai trò'),
                                              ),
                                              PopupMenuItem(
                                                value: 'remove',
                                                child: Text('Xóa khỏi workspace'),
                                              ),
                                            ],
                                            onSelected: (value) {
                                              if (value == 'role') {
                                                _updateRole(member);
                                                return;
                                              }

                                              _removeMember(member);
                                            },
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
