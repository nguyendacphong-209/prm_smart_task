import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:prm_smart_task/core/theme/app_theme.dart';
import 'package:prm_smart_task/features/collaboration/application/providers/collaboration_providers.dart';
import 'package:prm_smart_task/features/collaboration/domain/entities/task_attachment.dart';
import 'package:prm_smart_task/features/collaboration/domain/entities/task_comment.dart';
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

class TaskDetailPage extends ConsumerStatefulWidget {
  const TaskDetailPage({
    super.key,
    required this.taskId,
    required this.projectId,
    required this.workspaceId,
    this.projectName,
  });

  final String taskId;
  final String projectId;
  final String workspaceId;
  final String? projectName;

  @override
  ConsumerState<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<TaskDetailPage> {
  List<TaskStatusOption> _statusOptions = const [];
  List<WorkspaceMember> _mentionMembers = const [];
  final TextEditingController _commentController = TextEditingController();

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
      _loadStatusOptions();
      _loadMentionMembers();
      ref.read(taskControllerProvider.notifier).loadTaskDetail(
            projectId: widget.projectId,
            taskId: widget.taskId,
          );
      ref
          .read(collaborationControllerProvider.notifier)
          .loadTaskCollaboration(taskId: widget.taskId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadStatusOptions() async {
    try {
      final options = await ref
          .read(taskControllerProvider.notifier)
          .getStatusOptions(projectId: widget.projectId);
      if (!mounted) return;
      setState(() {
        _statusOptions = options;
      });
    } catch (_) {}
  }

  Future<void> _loadMentionMembers() async {
    try {
      final members = await ref
          .read(workspaceRepositoryProvider)
          .getWorkspaceAssignees(workspaceId: widget.workspaceId);
      if (!mounted) return;
      setState(() {
        _mentionMembers = members;
      });
    } catch (_) {}
  }

  void _insertMention(String email) {
    final current = _commentController.text;
    final mention = '@$email';
    if (current.trim().isEmpty) {
      _commentController.text = mention;
      return;
    }
    if (current.contains(mention)) return;
    _commentController.text = '$current $mention';
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      _showSnack('Vui lòng nhập nội dung comment');
      return;
    }

    final success = await ref
        .read(collaborationControllerProvider.notifier)
        .addComment(taskId: widget.taskId, content: content);

    if (!mounted) return;
    final collabState = ref.read(collaborationControllerProvider);
    if (success) {
      _commentController.clear();
      _showSnack('Đã thêm comment');
      return;
    }

    _showSnack(collabState.errorMessage ?? 'Không thể thêm comment');
  }

  Future<void> _pickAndUploadAttachment() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      _showSnack('Không đọc được dữ liệu file');
      return;
    }

    final success = await ref
        .read(collaborationControllerProvider.notifier)
        .uploadAttachment(
          taskId: widget.taskId,
          bytes: bytes,
          fileName: file.name,
        );

    if (!mounted) return;
    final collabState = ref.read(collaborationControllerProvider);
    _showSnack(
      success
          ? 'Upload file thành công'
          : (collabState.errorMessage ?? 'Upload file thất bại'),
    );
  }

  String _statusName(String? statusId) {
    if (statusId == null || statusId.isEmpty) {
      return 'Chưa có trạng thái';
    }

    for (final option in _statusOptions) {
      if (option.id == statusId) {
        return option.name;
      }
    }

    return 'Chưa có trạng thái';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Không deadline';
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  String _formatTimestamp(DateTime? date, {String fallback = 'Không rõ thời gian'}) {
    if (date == null) return fallback;
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
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

  bool _isValidUuid(String value) {
    final uuidRegExp = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    return uuidRegExp.hasMatch(value);
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

  Future<void> _showEditDialog(AppTask task) async {
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

    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description ?? '');

    String priority = task.priority.toLowerCase();
    DateTime? selectedDeadline = task.deadline;
    String? selectedStatusId = task.statusId;

    if (selectedStatusId == null ||
        !statusOptions.any((option) => option.id == selectedStatusId)) {
      selectedStatusId = statusOptions.first.id;
    }

    final selectedAssigneeIds = <String>{...task.assigneeIds};
    selectedAssigneeIds.removeWhere(
      (id) => !assigneeOptions.any((option) => option.userId == id),
    );
    final selectedLabelIds = <String>{...task.labelIds};
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
              title: const Text('Cập nhật task'),
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
                            _formatDate(selectedDeadline),
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
                          label: const Text('Đổi deadline'),
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

                  final normalizedDescription =
                    descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim();

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

                  final nextAssigneeIds = selectedAssigneeIds
                      .where((id) => _isValidUuid(id))
                      .toSet();
                  final currentAssigneeIds = task.assigneeIds.toSet();
                  final changedAssigneeIds =
                    nextAssigneeIds.length != currentAssigneeIds.length ||
                        !nextAssigneeIds.containsAll(currentAssigneeIds)
                      ? selectedAssigneeIds.toList()
                      : null;

                  if (nextAssigneeIds.length != selectedAssigneeIds.length) {
                    _showSnack('Có assignee không hợp lệ (UUID), vui lòng chọn lại');
                    return;
                  }

                  final nextLabelIds = selectedLabelIds.toSet();
                  final currentLabelIds = task.labelIds.toSet();
                  final changedLabelIds =
                    nextLabelIds.length != currentLabelIds.length ||
                        !nextLabelIds.containsAll(currentLabelIds)
                      ? selectedLabelIds.toList()
                      : null;

                  if (changedTitle == null &&
                    changedDescription == null &&
                    changedPriority == null &&
                    changedDeadline == null &&
                    changedStatusId == null &&
                    changedAssigneeIds == null &&
                    changedLabelIds == null) {
                    _showSnack('Không có thay đổi để cập nhật');
                    return;
                  }

                    final updateFormBody = <String, dynamic>{
                      'title': changedTitle,
                      'description': changedDescription,
                      'priority': changedPriority,
                      'deadline': changedDeadline?.toIso8601String(),
                      'statusId': changedStatusId,
                      'assigneeIds': changedAssigneeIds == null
                          ? null
                          : nextAssigneeIds.toList(),
                      'labelIds': changedLabelIds,
                    }..removeWhere((_, value) => value == null);

                    if (kDebugMode) {
                      debugPrint(
                        '[TASK_UPDATE_CLICK] source=task_detail taskId=${task.id} body=$updateFormBody',
                      );
                    }

                    Navigator.of(context).pop();

                    final success = await ref.read(taskControllerProvider.notifier).updateTask(
                          taskId: task.id,
                      title: changedTitle,
                      description: changedDescription,
                      priority: changedPriority,
                      deadline: changedDeadline,
                      statusId: changedStatusId,
                      assigneeIds: changedAssigneeIds == null
                        ? null
                        : nextAssigneeIds.toList(),
                      labelIds: changedLabelIds,
                        );

                    if (!mounted) return;

                    final state = ref.read(taskControllerProvider);
                    if (success) {
                      await ref.read(taskControllerProvider.notifier).loadTaskDetail(
                            projectId: widget.projectId,
                            taskId: widget.taskId,
                          );
                    }

                    _showSnack(
                      success
                          ? 'Cập nhật task thành công'
                          : (state.errorMessage ?? 'Không thể cập nhật task'),
                    );
                  },
                  child: const Text('Lưu'),
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
    if (success) {
      context.pop();
      return;
    }

    _showSnack(state.errorMessage ?? 'Không thể xóa task');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskControllerProvider);
    final collaborationState = ref.watch(collaborationControllerProvider);
    final task = state.selectedTask;
    final colors = AppBackground.colors(Theme.of(context).brightness);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Task detail'),
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
              : state.errorMessage != null && task == null
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: GlassCard(
                        child: ErrorStateView(
                          title: 'Không thể tải task',
                          message: state.errorMessage!,
                          actionLabel: 'Thử lại',
                          onAction: () {
                            ref.read(taskControllerProvider.notifier).loadTaskDetail(
                                  projectId: widget.projectId,
                                  taskId: widget.taskId,
                                );
                          },
                        ),
                      ),
                    )
                  : task == null
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: GlassCard(
                            child: const EmptyStateView(
                              icon: Icons.search_off_rounded,
                              title: 'Không tìm thấy task',
                              message: 'Task có thể đã bị xóa hoặc không tồn tại.',
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
                                    task.title,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 10),
                                  StatusChip(
                                    label: _priorityLabel(task.priority),
                                    type: task.priority,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    task.description?.trim().isNotEmpty == true
                                        ? task.description!.trim()
                                        : 'Không có mô tả',
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      const Icon(Icons.event_outlined, size: 16),
                                      const SizedBox(width: 6),
                                      Expanded(child: Text(_formatDate(task.deadline))),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.view_column_outlined, size: 16),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(_statusName(task.statusId)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            GlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Assignees Section
                                  Text(
                                    'Assignees',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  if (task.assignees.isEmpty)
                                    const Text('Không có assignee')
                                  else
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: task.assignees
                                          .map(
                                            (assignee) => Chip(
                                              label: Text(assignee.displayName),
                                              avatar: assignee.avatarUrl != null
                                                  ? CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(assignee.avatarUrl!),
                                                    )
                                                  : null,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  const SizedBox(height: 12),
                                  // Labels Section
                                  Text(
                                    'Labels',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  if (task.labels.isEmpty)
                                    const Text('Không có label')
                                  else
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: task.labels
                                          .map(
                                            (label) => Tooltip(
                                              message:
                                                  'Tạo bởi: ${label.creatorLabel}',
                                              child: Chip(
                                                label: Text(label.name),
                                                avatar: Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    color: _parseLabelColor(
                                                      label.color,
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            GlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Collaboration',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: _commentController,
                                    minLines: 2,
                                    maxLines: 4,
                                    decoration: const InputDecoration(
                                      labelText: 'Comment',
                                      hintText: 'Nhập nội dung, ví dụ: @member@email.com',
                                      prefixIcon: Icon(Icons.comment_outlined),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (_mentionMembers.isNotEmpty)
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: _mentionMembers
                                            .map(
                                              (member) => Padding(
                                                padding: const EdgeInsets.only(right: 8),
                                                child: ActionChip(
                                                  label: Text(
                                                    '@${member.email}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelSmall,
                                                  ),
                                                  onPressed: () =>
                                                      _insertMention(member.email),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FilledButton.tonalIcon(
                                          onPressed: collaborationState
                                                  .isUploadingAttachment
                                              ? null
                                              : _pickAndUploadAttachment,
                                          icon: collaborationState
                                                  .isUploadingAttachment
                                              ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child:
                                                      CircularProgressIndicator(strokeWidth: 2),
                                                )
                                              : const Icon(Icons.attach_file_rounded),
                                          label: const Text('Upload file'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: FilledButton.icon(
                                          onPressed: collaborationState
                                                  .isSubmittingComment
                                              ? null
                                              : _submitComment,
                                          icon: collaborationState.isSubmittingComment
                                              ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child:
                                                      CircularProgressIndicator(strokeWidth: 2),
                                                )
                                              : const Icon(Icons.send_rounded),
                                          label: const Text('Gửi comment'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (collaborationState.errorMessage != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      collaborationState.errorMessage!,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            GlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Comments',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  if (collaborationState.isLoading)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    )
                                  else if (collaborationState.comments.isEmpty)
                                    const Text('Chưa có comment')
                                  else
                                    ...collaborationState.comments.map(
                                      (comment) => _CommentItem(
                                        comment: comment,
                                        formatDate: _formatTimestamp,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            GlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Attachments',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  if (collaborationState.isLoading)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    )
                                  else if (collaborationState.attachments.isEmpty)
                                    const Text('Chưa có file đính kèm')
                                  else
                                    ...collaborationState.attachments.map(
                                      (attachment) => _AttachmentItem(
                                        attachment: attachment,
                                        formatDate: (date) => _formatTimestamp(
                                          date,
                                          fallback: 'Không rõ thời gian upload',
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.tonalIcon(
                                onPressed: () => _showEditDialog(task),
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Cập nhật task'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                  foregroundColor: Theme.of(context).colorScheme.onError,
                                ),
                                onPressed: () => _deleteTask(task),
                                child: const Text('Xóa task'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => context.push(
                                  '/projects/${widget.projectId}/tasks?workspaceId=${widget.workspaceId}&projectName=${Uri.encodeComponent(widget.projectName ?? '')}',
                                ),
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: const Text('Về danh sách tasks'),
                              ),
                            ),
                          ],
                        ),
        ),
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem({
    required this.comment,
    required this.formatDate,
  });

  final TaskComment comment;
  final String Function(DateTime? date) formatDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  comment.displayName,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Text(
                formatDate(comment.createdAt),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(comment.content),
          if (comment.mentionedEmails.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: comment.mentionedEmails
                  .map((email) => Chip(label: Text('@$email')))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _AttachmentItem extends StatelessWidget {
  const _AttachmentItem({
    required this.attachment,
    required this.formatDate,
  });

  final TaskAttachment attachment;
  final String Function(DateTime? date) formatDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.fileName,
                  style: Theme.of(context).textTheme.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  formatDate(attachment.uploadedAt),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Copy URL',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: attachment.fileUrl));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã copy link file')),
              );
            },
            icon: const Icon(Icons.copy_rounded),
          ),
        ],
      ),
    );
  }
}
