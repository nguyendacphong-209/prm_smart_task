import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_smart_task/core/theme/app_theme.dart';
import 'package:prm_smart_task/features/workspace/application/providers/workspace_providers.dart';
import 'package:prm_smart_task/features/workspace/domain/entities/workspace_member.dart';
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
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
    final nameController = TextEditingController(text: currentName);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa workspace'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tên workspace',
            prefixIcon: Icon(Icons.edit_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              final nextName = nameController.text.trim();
              if (nextName.length < 3) {
                _showSnack('Tên workspace tối thiểu 3 ký tự');
                return;
              }

              Navigator.of(context).pop();
              final success = await ref
                  .read(workspaceControllerProvider.notifier)
                  .updateWorkspace(workspaceId: workspaceId, name: nextName);
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

    nameController.dispose();
  }

  Future<void> _confirmDeleteWorkspace({
    required String workspaceId,
    required String workspaceName,
  }) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xóa workspace'),
            content: Text('Bạn có chắc muốn xóa workspace "$workspaceName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
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
    final emailController = TextEditingController();
    String role = 'member';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Mời thành viên'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(
                      labelText: 'Vai trò',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'member', child: Text('Member')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      setStateDialog(() {
                        role = value ?? 'member';
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () async {
                    final email = emailController.text.trim();
                    if (email.isEmpty || !email.contains('@')) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Email không hợp lệ')),
                      );
                      return;
                    }

                    Navigator.of(context).pop();
                    final success = await ref
                        .read(workspaceControllerProvider.notifier)
                        .inviteMember(
                          workspaceId: widget.workspaceId,
                          email: email,
                          role: role,
                        );

                    if (!mounted) return;
                    final state = ref.read(workspaceControllerProvider);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Mời thành viên thành công'
                              : (state.errorMessage ?? 'Không thể mời thành viên'),
                        ),
                      ),
                    );
                  },
                  child: const Text('Mời'),
                ),
              ],
            );
          },
        );
      },
    );

    emailController.dispose();
  }

  Future<void> _updateRole(WorkspaceMember member) async {
    final roles = ['member', 'admin'];

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
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
                      Navigator.of(context).pop();
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
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Cập nhật vai trò thành công'
                                : (state.errorMessage ?? 'Không thể cập nhật vai trò'),
                          ),
                        ),
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
          builder: (context) => AlertDialog(
            title: const Text('Xóa thành viên'),
            content: Text('Bạn có chắc muốn xóa ${member.fullName} khỏi workspace?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Đã xóa thành viên' : (state.errorMessage ?? 'Không thể xóa thành viên'),
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    ref.listen(workspaceControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        _showSnack(next.errorMessage!);
      }
    });

    final state = ref.watch(workspaceControllerProvider);
    final colors = AppBackground.colors(Theme.of(context).brightness);
    final workspace = state.selectedWorkspace;

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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workspace?.name ?? '--',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Vai trò của bạn: ${_memberRoleLabel(workspace?.myRole ?? 'member')}',
                                style: Theme.of(context).textTheme.bodyMedium,
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        GlassCard(
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
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
                                    const SizedBox(width: 8),
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
                                            .withValues(alpha: 0.16),
                                      ),
                                      child: Text(
                                        _memberRoleLabel(member.role),
                                        style: Theme.of(context).textTheme.labelMedium,
                                      ),
                                    ),
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
