import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_smart_task/core/theme/app_theme.dart';
import 'package:prm_smart_task/features/workspace/application/providers/workspace_providers.dart';
import 'package:prm_smart_task/shared/widgets/empty_state_view.dart';
import 'package:prm_smart_task/shared/widgets/error_state_view.dart';
import 'package:prm_smart_task/shared/widgets/glass_card.dart';
import 'package:prm_smart_task/shared/widgets/skeleton_loading.dart';

class WorkspaceListPage extends ConsumerStatefulWidget {
  const WorkspaceListPage({super.key});

  @override
  ConsumerState<WorkspaceListPage> createState() => _WorkspaceListPageState();
}

class _WorkspaceListPageState extends ConsumerState<WorkspaceListPage> {
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
      ref.read(workspaceControllerProvider.notifier).loadMyWorkspaces();
    });
  }

  Future<void> _openCreateWorkspace() async {
    final created = await context.push<bool>('/workspaces/create');
    if (!mounted) return;

    if (created == true) {
      await ref.read(workspaceControllerProvider.notifier).loadMyWorkspaces(
        forceReload: true,
      );
    }
  }

  String _roleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'owner':
        return 'Owner';
      default:
        return 'Member';
    }
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
    _showSnack(
      success
          ? 'Xóa workspace thành công'
          : (state.errorMessage ?? 'Không thể xóa workspace'),
    );
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Workspaces'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _openCreateWorkspace,
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
              : state.errorMessage != null && state.workspaces.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: GlassCard(
                        style: GlassCardStyle.liquid,
                        child: ErrorStateView(
                          title: 'Không thể tải workspace',
                          message: state.errorMessage!,
                          actionLabel: 'Thử lại',
                          onAction: () {
                            ref
                                .read(workspaceControllerProvider.notifier)
                                .loadMyWorkspaces(forceReload: true);
                          },
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
                                'Không gian làm việc',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Quản lý workspace, thành viên và phân quyền nhanh chóng.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (state.workspaces.isEmpty)
                          GlassCard(
                            style: GlassCardStyle.liquid,
                            child: EmptyStateView(
                              icon: Icons.folder_open_rounded,
                              title: 'Chưa có workspace',
                              message: 'Nhấn nút + ở góc trên để tạo workspace đầu tiên.',
                              actionLabel: 'Tạo workspace',
                              onAction: _openCreateWorkspace,
                            ),
                          )
                        else
                          ...state.workspaces.map(
                            (workspace) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GlassCard(
                                style: GlassCardStyle.liquid,
                                padding: const EdgeInsets.all(14),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => context.push('/workspaces/${workspace.id}'),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        child: Text(
                                          workspace.name
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
                                              workspace.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
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
                                                _roleLabel(workspace.myRole),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (workspace.myRole.toLowerCase() == 'owner')
                                        PopupMenuButton<String>(
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
                                        )
                                      else
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.62),
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
