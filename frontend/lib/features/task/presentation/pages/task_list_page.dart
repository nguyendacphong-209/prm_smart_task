import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_smart_task/core/theme/app_theme.dart';
import 'package:prm_smart_task/features/task/application/providers/task_providers.dart';
import 'package:prm_smart_task/features/task/domain/entities/app_task.dart';
import 'package:prm_smart_task/features/task/domain/entities/task_label_option.dart';
import 'package:prm_smart_task/features/task/domain/entities/task_status_option.dart';
import 'package:prm_smart_task/features/task/presentation/widgets/assignee_selector.dart';
import 'package:prm_smart_task/features/workspace/application/providers/workspace_providers.dart';
import 'package:prm_smart_task/features/workspace/domain/entities/workspace_member.dart';
import 'package:prm_smart_task/shared/widgets/empty_state_view.dart';
import 'package:prm_smart_task/shared/widgets/error_state_view.dart';
import 'package:prm_smart_task/shared/widgets/glass_card.dart';
import 'package:prm_smart_task/shared/widgets/skeleton_loading.dart';
import 'package:prm_smart_task/shared/widgets/status_chip.dart';

class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({
    super.key,
    required this.projectId,
    required this.workspaceId,
    this.projectName,
  });

  final String projectId;
  final String workspaceId;
  final String? projectName;

  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
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
      ref.read(taskControllerProvider.notifier).loadTasks(projectId: widget.projectId);
    });
  }

  Future<void> _reload() async {
    await ref.read(taskControllerProvider.notifier).loadTasks(
          projectId: widget.projectId,
          forceReload: true,
        );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Không deadline';
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Color _parseLabelColor(String? hexColor, Color fallbackColor) {
    if (hexColor == null || hexColor.isEmpty) return fallbackColor;

    var normalized = hexColor.trim().replaceFirst('#', '');
    if (normalized.length == 6) {
      normalized = 'FF$normalized';
    }

    if (normalized.length != 8) {
      return fallbackColor;
    }

    final value = int.tryParse(normalized, radix: 16);
    if (value == null) return fallbackColor;

    return Color(value);
  }

  bool _isValidUuid(String value) {
    final uuidRegExp = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    return uuidRegExp.hasMatch(value);
  }

  Future<void> _showTaskDialog({AppTask? task}) async {
    List<TaskStatusOption> statusOptions;
    List<WorkspaceMember> assigneeOptions;
    List<TaskLabelOption> labelOptions;

    try {
      statusOptions = await ref
          .read(taskControllerProvider.notifier)
          .getStatusOptions(projectId: widget.projectId);
      assigneeOptions = await ref
          .read(workspaceRepositoryProvider)
          .getWorkspaceAssignees(workspaceId: widget.workspaceId);
      labelOptions = await ref
          .read(taskControllerProvider.notifier)
          .getLabelOptions(projectId: widget.projectId);
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
      return;
    }

    if (statusOptions.isEmpty) {
      _showSnack('Project chưa có status. Vui lòng tạo status trước.');
      return;
    }

    final titleController = TextEditingController(text: task?.title ?? '');
    final descriptionController = TextEditingController(
      text: task?.description ?? '',
    );

    String priority = (task?.priority ?? 'medium').toLowerCase();
    DateTime? selectedDeadline = task?.deadline;
    String? selectedStatusId = task?.statusId;

    if (selectedStatusId == null ||
        !statusOptions.any((option) => option.id == selectedStatusId)) {
      selectedStatusId = statusOptions.first.id;
    }

    final selectedAssigneeIds = <String>{...task?.assigneeIds ?? const <String>[]};
    selectedAssigneeIds.removeWhere(
      (id) => !assigneeOptions.any((option) => option.userId == id),
    );
    final selectedLabelIds = <String>{...task?.labelIds ?? const <String>[]};
    selectedLabelIds.removeWhere(
      (id) => !labelOptions.any((option) => option.id == id),
    );

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(task == null ? 'Tạo task' : 'Cập nhật task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tiêu đề',
                        prefixIcon: Icon(Icons.task_alt_rounded),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      decoration: const InputDecoration(
                        labelText: 'Độ ưu tiên',
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'high', child: Text('High')),
                        DropdownMenuItem(value: 'medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'low', child: Text('Low')),
                      ],
                      onChanged: (value) {
                        setStateDialog(() {
                          priority = value ?? 'medium';
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatusId,
                      decoration: const InputDecoration(
                        labelText: 'Task status',
                        prefixIcon: Icon(Icons.view_column_outlined),
                      ),
                      items: statusOptions
                          .map(
                            (option) => DropdownMenuItem<String>(
                              value: option.id,
                              child: Text(option.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedStatusId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    if (assigneeOptions.isEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Workspace chưa có assignee để chọn',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      )
                    else
                      AssigneeSelector(
                        assigneeOptions: assigneeOptions,
                        selectedAssigneeIds: selectedAssigneeIds,
                        onChanged: (selected) {
                          setStateDialog(() {
                            selectedAssigneeIds.clear();
                            selectedAssigneeIds.addAll(selected);
                          });
                        },
                      ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Labels',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (labelOptions.isEmpty)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Chưa có label khả dụng trong project'),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: labelOptions
                            .map(
                              (label) => FilterChip(
                                avatar: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _parseLabelColor(
                                      label.color,
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                label: Text(label.name),
                                selected: selectedLabelIds.contains(label.id),
                                onSelected: (selected) {
                                  setStateDialog(() {
                                    if (selected) {
                                      selectedLabelIds.add(label.id);
                                    } else {
                                      selectedLabelIds.remove(label.id);
                                    }
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDeadline == null
                                ? 'Không deadline'
                                : _formatDate(selectedDeadline),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDeadline ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (date == null) return;

                            if (!context.mounted) return;
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                selectedDeadline ?? DateTime.now(),
                              ),
                            );
                            if (time == null) return;

                            setStateDialog(() {
                              selectedDeadline = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          },
                          icon: const Icon(Icons.event_outlined),
                          label: const Text('Chọn deadline'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty || title.length < 3) {
                      _showSnack('Tiêu đề tối thiểu 3 ký tự');
                      return;
                    }

                    Navigator.of(context).pop();

                    final description = descriptionController.text.trim();
                    final labelIds = selectedLabelIds.toList();
                    final validAssigneeIds = selectedAssigneeIds
                        .where((id) => _isValidUuid(id))
                        .toSet();

                    if (validAssigneeIds.length != selectedAssigneeIds.length) {
                      _showSnack('Có assignee không hợp lệ (UUID), vui lòng chọn lại');
                      return;
                    }

                    if (selectedStatusId == null || selectedStatusId!.isEmpty) {
                      _showSnack('Vui lòng chọn task status');
                      return;
                    }

                    bool success;
                    if (task == null) {
                      success = await ref.read(taskControllerProvider.notifier).createTask(
                            projectId: widget.projectId,
                            title: title,
                            description: description.isEmpty ? null : description,
                            priority: priority,
                            deadline: selectedDeadline,
                            statusId: selectedStatusId!,
                            assigneeIds: validAssigneeIds.toList(),
                            labelIds: labelIds,
                          );
                    } else {
                          final normalizedDescription =
                            description.isEmpty ? null : description;
                          final originalDescription =
                            (task.description?.trim().isNotEmpty ?? false)
                              ? task.description!.trim()
                              : null;

                          final changedTitle = title != task.title ? title : null;
                          final changedDescription =
                            normalizedDescription != originalDescription
                              ? normalizedDescription
                              : null;
                          final changedPriority =
                            priority != task.priority.toLowerCase() ? priority : null;
                          final changedDeadline =
                            selectedDeadline != task.deadline ? selectedDeadline : null;
                          final changedStatusId =
                            selectedStatusId != task.statusId ? selectedStatusId : null;

                          final nextAssigneeIds = validAssigneeIds;
                          final currentAssigneeIds = task.assigneeIds.toSet();
                          final changedAssigneeIds =
                            nextAssigneeIds.length != currentAssigneeIds.length ||
                                !nextAssigneeIds.containsAll(currentAssigneeIds)
                              ? nextAssigneeIds.toList()
                              : null;

                          final nextLabelIds = selectedLabelIds.toSet();
                          final currentLabelIds = task.labelIds.toSet();
                          final changedLabelIds =
                            nextLabelIds.length != currentLabelIds.length ||
                                !nextLabelIds.containsAll(currentLabelIds)
                              ? labelIds
                              : null;

                      final updateFormBody = <String, dynamic>{
                        'title': changedTitle,
                        'description': changedDescription,
                        'priority': changedPriority,
                        'deadline': changedDeadline?.toIso8601String(),
                        'statusId': changedStatusId,
                        'assigneeIds': changedAssigneeIds,
                        'labelIds': changedLabelIds,
                      }..removeWhere((_, value) => value == null);

                      if (kDebugMode) {
                        debugPrint(
                          '[TASK_UPDATE_CLICK] source=task_list taskId=${task.id} body=$updateFormBody',
                        );
                      }

                      success = await ref.read(taskControllerProvider.notifier).updateTask(
                            taskId: task.id,
                            title: changedTitle,
                            description: changedDescription,
                            priority: changedPriority,
                            deadline: changedDeadline,
                            statusId: changedStatusId,
                            assigneeIds: changedAssigneeIds,
                            labelIds: changedLabelIds,
                          );
                    }

                    if (!mounted) return;
                    final state = ref.read(taskControllerProvider);
                    _showSnack(
                      success
                          ? (task == null
                              ? 'Tạo task thành công'
                              : 'Cập nhật task thành công')
                          : (state.errorMessage ?? 'Không thể xử lý task'),
                    );
                  },
                  child: Text(task == null ? 'Tạo' : 'Lưu'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
  }

  Future<void> _deleteTask(AppTask task) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xóa task'),
            content: Text('Bạn có chắc muốn xóa task "${task.title}"?'),
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

    final success = await ref.read(taskControllerProvider.notifier).deleteTask(
          taskId: task.id,
        );

    if (!mounted) return;
    final state = ref.read(taskControllerProvider);
    _showSnack(
      success ? 'Đã xóa task' : (state.errorMessage ?? 'Không thể xóa task'),
    );
  }

  String _priorityLabel(String value) {
    switch (value.toLowerCase()) {
      case 'high':
        return 'High';
      case 'low':
        return 'Low';
      default:
        return 'Medium';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskControllerProvider);
    final colors = AppBackground.colors(Theme.of(context).brightness);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.projectName?.isNotEmpty == true
            ? 'Tasks - ${widget.projectName}'
            : 'Tasks'),
        actions: [
          IconButton(
            onPressed: state.isSubmitting ? null : () => _showTaskDialog(),
            icon: const Icon(Icons.add_task_rounded),
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
              : state.errorMessage != null && state.tasks.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: GlassCard(
                        child: ErrorStateView(
                          title: 'Không thể tải task',
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
                                'Danh sách task',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Theo dõi task theo độ ưu tiên và deadline.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (state.tasks.isEmpty)
                          GlassCard(
                            child: EmptyStateView(
                              icon: Icons.task_outlined,
                              title: 'Chưa có task',
                              message: 'Tạo task đầu tiên cho project này.',
                              actionLabel: 'Tạo task',
                              onAction: () => _showTaskDialog(),
                            ),
                          )
                        else
                          ...state.tasks.map(
                            (task) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GlassCard(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => context.push(
                                    '/tasks/${task.id}?projectId=${widget.projectId}&workspaceId=${widget.workspaceId}&projectName=${Uri.encodeComponent(widget.projectName ?? '')}',
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              task.title,
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
                                                child: Text('Cập nhật task'),
                                              ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Xóa task'),
                                              ),
                                            ],
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                _showTaskDialog(task: task);
                                                return;
                                              }

                                              _deleteTask(task);
                                            },
                                          ),
                                        ],
                                      ),
                                      if ((task.description ?? '').trim().isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(task.description!.trim()),
                                      ],
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          StatusChip(
                                            label: _priorityLabel(task.priority),
                                            type: task.priority,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(999),
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outline,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.event_rounded, size: 14),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _formatDate(task.deadline),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
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
