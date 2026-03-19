import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_smart_task/core/theme/app_theme.dart';
import 'package:prm_smart_task/features/project/application/providers/project_providers.dart';
import 'package:prm_smart_task/features/project/domain/entities/project.dart';
import 'package:prm_smart_task/shared/widgets/empty_state_view.dart';
import 'package:prm_smart_task/shared/widgets/error_state_view.dart';
import 'package:prm_smart_task/shared/widgets/glass_card.dart';
import 'package:prm_smart_task/shared/widgets/skeleton_loading.dart';

class ProjectListPage extends ConsumerStatefulWidget {
  const ProjectListPage({super.key, required this.workspaceId});

  final String workspaceId;

  @override
  ConsumerState<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends ConsumerState<ProjectListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectControllerProvider.notifier).loadProjects(
            workspaceId: widget.workspaceId,
          );
    });
  }

  Future<void> _reload() async {
    await ref.read(projectControllerProvider.notifier).loadProjects(
          workspaceId: widget.workspaceId,
          forceReload: true,
        );
  }

  Future<void> _showProjectDialog({Project? project}) async {
    final nameController = TextEditingController(text: project?.name ?? '');
    final descriptionController = TextEditingController(
      text: project?.description ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(project == null ? 'Tạo project' : 'Cập nhật project'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên project',
                  prefixIcon: Icon(Icons.layers_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
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
                final name = nameController.text.trim();
                final description = descriptionController.text.trim();

                if (name.isEmpty || name.length < 3) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Tên project tối thiểu 3 ký tự')),
                  );
                  return;
                }

                Navigator.of(context).pop();

                bool success;
                if (project == null) {
                  success = await ref.read(projectControllerProvider.notifier).createProject(
                        workspaceId: widget.workspaceId,
                        name: name,
                        description: description.isEmpty ? null : description,
                      );
                } else {
                  success = await ref.read(projectControllerProvider.notifier).updateProject(
                        projectId: project.id,
                        name: name,
                        description: description.isEmpty ? null : description,
                      );
                }

                if (!mounted) return;
                final state = ref.read(projectControllerProvider);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? (project == null
                              ? 'Tạo project thành công'
                              : 'Cập nhật project thành công')
                          : (state.errorMessage ?? 'Không thể xử lý project'),
                    ),
                  ),
                );
              },
              child: Text(project == null ? 'Tạo' : 'Lưu'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
  }

  Future<void> _deleteProject(Project project) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xóa project'),
            content: Text('Bạn có chắc muốn xóa project "${project.name}"?'),
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

    final success = await ref.read(projectControllerProvider.notifier).deleteProject(
          projectId: project.id,
        );

    if (!mounted) return;
    final state = ref.read(projectControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Đã xóa project' : (state.errorMessage ?? 'Không thể xóa project'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectControllerProvider);
    final colors = AppBackground.colors(Theme.of(context).brightness);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            onPressed: state.isSubmitting ? null : () => _showProjectDialog(),
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Tạo project',
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
              ? const TabSkeletonView(cardCount: 3)
              : state.errorMessage != null && state.projects.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: GlassCard(
                        child: ErrorStateView(
                          title: 'Không thể tải project',
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
                                'Danh sách project',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Quản lý project trong workspace với trải nghiệm trực quan.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (state.projects.isEmpty)
                          GlassCard(
                            child: EmptyStateView(
                              icon: Icons.layers_clear_outlined,
                              title: 'Chưa có project',
                              message: 'Tạo project đầu tiên để bắt đầu quản lý task.',
                              actionLabel: 'Tạo project',
                              onAction: () => _showProjectDialog(),
                            ),
                          )
                        else
                          ...state.projects.map(
                            (project) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GlassCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            project.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          enabled: !state.isSubmitting,
                                          itemBuilder: (context) => const [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Cập nhật project'),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Xóa project'),
                                            ),
                                          ],
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _showProjectDialog(project: project);
                                              return;
                                            }

                                            _deleteProject(project);
                                          },
                                        ),
                                      ],
                                    ),
                                    if ((project.description ?? '').trim().isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(project.description!.trim()),
                                    ],
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: FilledButton.tonalIcon(
                                            onPressed: () => context.push(
                                              '/projects/${project.id}/tasks?workspaceId=${widget.workspaceId}&projectName=${Uri.encodeComponent(project.name)}',
                                            ),
                                            icon: const Icon(Icons.task_alt_rounded),
                                            label: const Text('Tasks'),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: FilledButton.tonalIcon(
                                            onPressed: () => context.push(
                                              '/projects/${project.id}/kanban?workspaceId=${widget.workspaceId}&projectName=${Uri.encodeComponent(project.name)}',
                                            ),
                                            icon: const Icon(Icons.view_kanban_rounded),
                                            label: const Text('Kanban'),
                                          ),
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
