import 'package:prm_smart_task/features/task/application/providers/task_pin_provider.dart';
import 'package:prm_smart_task/features/task/presentation/widgets/task_pin_button.dart';
import 'package:prm_smart_task/features/task/presentation/pages/pinned_tasks_page.dart';
import 'package:prm_smart_task/features/task/presentation/pages/label_management_page.dart';
import 'package:prm_smart_task/features/task/domain/entities/task_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
import 'package:prm_smart_task/core/theme/app_theme.dart';
import 'package:prm_smart_task/features/task/application/providers/task_providers.dart';
import 'package:prm_smart_task/features/task/domain/entities/app_task.dart';
import 'package:prm_smart_task/features/task/domain/entities/task_label_option.dart';
import 'package:prm_smart_task/features/task/domain/entities/task_status_option.dart';
import 'package:prm_smart_task/features/task/presentation/widgets/task_form_dialog.dart';
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
  final _search = TextEditingController();
  String? _filterStatus, _filterAssignee, _filterPriority, _filterLabel;
  bool _overdueOnly = false;
  int _deadlineOrder = 0;
  List<TaskStatusOption> _filterStatuses = [];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadFilterStatuses() async {
    try {
      final statuses = await ref
          .read(taskControllerProvider.notifier)
          .getStatusOptions(projectId: widget.projectId);
      if (mounted) setState(() => _filterStatuses = statuses);
    } catch (_) {
      if (mounted) {
        _showSnack('Không tải được tên trạng thái. Bấm làm mới để thử lại.');
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _search.clear();
      _filterStatus = _filterAssignee = _filterPriority = _filterLabel = null;
      _overdueOnly = false;
      _deadlineOrder = 0;
    });
  }

  Widget _selectFilter(
    String title,
    String? selected,
    Map<String, String> options,
    ValueChanged<String?> changed,
  ) {
    final entries = {...options};
    if (selected != null && !entries.containsKey(selected)) {
      entries[selected] = 'Giá trị đã chọn (không còn trong danh sách)';
    }
    return SizedBox(
      width: 210,
      child: DropdownButtonFormField<String>(
        initialValue: selected ?? '',
        key: ValueKey('$title:$selected'),
        isExpanded: true,
        decoration: InputDecoration(labelText: title),
        items: [
          const DropdownMenuItem(value: '', child: Text('Tất cả')),
          ...entries.entries.map(
            (e) => DropdownMenuItem(
              value: e.key,
              child: Text(e.value, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
        onChanged: (v) => setState(() => changed(v == '' ? null : v)),
      ),
    );
  }

  Widget _filters(List<AppTask> tasks, int count) {
    final statuses = {for (final s in _filterStatuses) s.id: s.name};
    for (final task in tasks) {
      if (task.statusId != null) {
        statuses.putIfAbsent(
          task.statusId!,
          () => 'Trạng thái ${task.statusId}',
        );
      }
    }
    return GlassCard(
      style: GlassCardStyle.liquid,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Tìm theo tiêu đề',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Xóa từ khóa',
                      onPressed: () => setState(() => _search.clear()),
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _selectFilter(
                'Trạng thái',
                _filterStatus,
                statuses,
                (v) => _filterStatus = v,
              ),
              _selectFilter('Người phụ trách', _filterAssignee, {
                for (final t in tasks)
                  for (final a in t.assignees) a.userId: a.displayName,
              }, (v) => _filterAssignee = v),
              _selectFilter('Ưu tiên', _filterPriority, {
                'high': 'Cao',
                'medium': 'Trung bình',
                'low': 'Thấp',
              }, (v) => _filterPriority = v),
              _selectFilter('Nhãn', _filterLabel, {
                for (final t in tasks)
                  for (final l in t.labels) l.id: l.name,
              }, (v) => _filterLabel = v),
              SizedBox(
                width: 210,
                child: DropdownButtonFormField<int>(
                  key: ValueKey(_deadlineOrder),
                  initialValue: _deadlineOrder,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Sắp xếp'),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Mặc định')),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('Deadline gần nhất'),
                    ),
                    DropdownMenuItem(
                      value: -1,
                      child: Text('Deadline xa nhất'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _deadlineOrder = v ?? 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                label: const Text('Deadline đã qua'),
                selected: _overdueOnly,
                onSelected: (v) => setState(() => _overdueOnly = v),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Xóa bộ lọc'),
              ),
              IconButton(
                tooltip: 'Làm mới danh sách',
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
              ),
              Text('$count / ${tasks.length} task'),
            ],
          ),
          if (_overdueOnly)
            const Text(
              'Lọc theo thời hạn, bao gồm mọi trạng thái. Chọn thêm trạng thái để giới hạn kết quả.',
            ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    showAppSnack(message);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFilterStatuses();
      ref
          .read(taskControllerProvider.notifier)
          .loadTasks(projectId: widget.projectId);
    });
  }

  Future<void> _reload() async {
    ref.invalidate(taskPinsProvider);
    _loadFilterStatuses();
    await ref
        .read(taskControllerProvider.notifier)
        .loadTasks(projectId: widget.projectId, forceReload: true);
  }

  Color _labelColor(String? hex) {
    var value = (hex ?? '').trim().replaceFirst('#', '');
    if (value.length == 6) {
      value = 'FF$value';
    }
    final parsed = value.length == 8 ? int.tryParse(value, radix: 16) : null;
    return parsed == null
        ? Theme.of(context).colorScheme.secondary
        : Color(parsed);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Không deadline';
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
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

    String initialStatusId = task?.statusId ?? statusOptions.first.id;
    if (!statusOptions.any((option) => option.id == initialStatusId)) {
      initialStatusId = statusOptions.first.id;
    }

    final initialAssigneeIds =
        <String>{...task?.assigneeIds ?? const <String>[]}..removeWhere(
          (id) => !assigneeOptions.any((option) => option.userId == id),
        );
    final initialLabelIds = <String>{...task?.labelIds ?? const <String>[]}
      ..removeWhere((id) => !labelOptions.any((option) => option.id == id));

    if (!mounted) return;

    final result = await showDialog<TaskFormResult>(
      context: context,
      builder: (_) => TaskFormDialog(
        dialogTitle: task == null ? 'Tạo task' : 'Cập nhật task',
        confirmLabel: task == null ? 'Tạo' : 'Lưu',
        statusOptions: statusOptions,
        assigneeOptions: assigneeOptions,
        labelOptions: labelOptions,
        initialTitle: task?.title ?? '',
        initialDescription: task?.description ?? '',
        initialPriority: (task?.priority ?? 'medium').toLowerCase(),
        initialDeadline: task?.deadline,
        initialStatusId: initialStatusId,
        initialAssigneeIds: initialAssigneeIds,
        initialLabelIds: initialLabelIds,
        deadlineButtonLabel: 'Chọn deadline',
      ),
    );

    if (!mounted || result == null) return;

    final validAssigneeIds = result.assigneeIds.where(_isValidUuid).toSet();
    if (validAssigneeIds.length != result.assigneeIds.length) {
      _showSnack('Có assignee không hợp lệ (UUID), vui lòng chọn lại');
      return;
    }

    bool success;
    if (task == null) {
      success = await ref
          .read(taskControllerProvider.notifier)
          .createTask(
            projectId: widget.projectId,
            title: result.title,
            description: result.description,
            priority: result.priority,
            deadline: result.deadline,
            statusId: result.statusId,
            assigneeIds: validAssigneeIds.toList(),
            labelIds: result.labelIds,
          );
    } else {
      final originalDescription = (task.description?.trim().isNotEmpty ?? false)
          ? task.description!.trim()
          : null;

      final changedTitle = result.title != task.title ? result.title : null;
      final changedDescription = result.description != originalDescription
          ? result.description
          : null;
      final changedPriority = result.priority != task.priority.toLowerCase()
          ? result.priority
          : null;
      final changedDeadline = result.deadline != task.deadline
          ? result.deadline
          : null;
      final changedStatusId = result.statusId != task.statusId
          ? result.statusId
          : null;

      final nextAssigneeIds = validAssigneeIds;
      final currentAssigneeIds = task.assigneeIds.toSet();
      final changedAssigneeIds =
          nextAssigneeIds.length != currentAssigneeIds.length ||
              !nextAssigneeIds.containsAll(currentAssigneeIds)
          ? nextAssigneeIds.toList()
          : null;

      final nextLabelIds = result.labelIds.toSet();
      final currentLabelIds = task.labelIds.toSet();
      final changedLabelIds =
          nextLabelIds.length != currentLabelIds.length ||
              !nextLabelIds.containsAll(currentLabelIds)
          ? result.labelIds
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

      success = await ref
          .read(taskControllerProvider.notifier)
          .updateTask(
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
          ? (task == null ? 'Tạo task thành công' : 'Cập nhật task thành công')
          : (state.errorMessage ?? 'Không thể xử lý task'),
    );
  }

  Future<void> _deleteTask(AppTask task) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Xóa task'),
            content: Text('Bạn có chắc muốn xóa task "${task.title}"?'),
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
        .read(taskControllerProvider.notifier)
        .deleteTask(taskId: task.id);

    if (!mounted) return;
    if (success) {
      ref.invalidate(taskPinsProvider);
    }
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
    final visibleTasks = filterTasks(
      state.tasks,
      query: _search.text,
      statusId: _filterStatus,
      assigneeId: _filterAssignee,
      priority: _filterPriority,
      labelId: _filterLabel,
      overdueOnly: _overdueOnly,
      deadlineOrder: _deadlineOrder,
      now: DateTime.now(),
    );
    final colors = AppBackground.colors(Theme.of(context).brightness);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.projectName?.isNotEmpty == true
              ? 'Tasks - ${widget.projectName}'
              : 'Tasks',
        ),
        actions: [
          IconButton(
            tooltip: 'Task đã ghim',
            icon: const Icon(Icons.bookmarks_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PinnedTasksPage()),
            ),
          ),
          IconButton(
            tooltip: 'Quản lý nhãn',
            icon: const Icon(Icons.label_outline),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      LabelManagementPage(projectId: widget.projectId),
                ),
              );
              if (!mounted) {
                return;
              }
              setState(() => _filterLabel = null);
              await _reload();
            },
          ),
          IconButton(
            onPressed: state.isSubmitting ? null : () => _showTaskDialog(),
            icon: const Icon(Icons.add_task_rounded),
            tooltip: 'Tạo task',
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
                    style: GlassCardStyle.liquid,
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
                      style: GlassCardStyle.spotlight,
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
                    _filters(state.tasks, visibleTasks.length),
                    const SizedBox(height: 12),
                    if (state.tasks.isNotEmpty && visibleTasks.isEmpty)
                      EmptyStateView(
                        icon: Icons.search_off,
                        title: 'Không có task phù hợp',
                        message: 'Thử đổi từ khóa hoặc xóa bộ lọc.',
                        actionLabel: 'Xóa bộ lọc',
                        onAction: _clearFilters,
                      ),
                    if (state.tasks.isEmpty)
                      GlassCard(
                        style: GlassCardStyle.liquid,
                        child: EmptyStateView(
                          icon: Icons.task_outlined,
                          title: 'Chưa có task',
                          message: 'Tạo task đầu tiên cho project này.',
                          actionLabel: 'Tạo task',
                          onAction: () => _showTaskDialog(),
                        ),
                      )
                    else
                      ...visibleTasks.map(
                        (task) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GlassCard(
                            style: GlassCardStyle.liquid,
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
                                      Builder(
                                        builder: (_) {
                                          final imageUrl = task.imageUrl
                                              ?.trim();
                                          final fallbackInitial =
                                              task.title.trim().isNotEmpty
                                              ? task.title
                                                    .trim()
                                                    .substring(0, 1)
                                                    .toUpperCase()
                                              : '?';
                                          return CircleAvatar(
                                            radius: 20,
                                            backgroundImage:
                                                imageUrl == null ||
                                                    imageUrl.isEmpty
                                                ? null
                                                : NetworkImage(imageUrl),
                                            child:
                                                imageUrl == null ||
                                                    imageUrl.isEmpty
                                                ? Text(fallbackInitial)
                                                : null,
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          task.title,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                      ),
                                      TaskPinButton(
                                        key: ValueKey('pin-${task.id}'),
                                        taskId: task.id,
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
                                  if ((task.description ?? '')
                                      .trim()
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      task.description!.trim(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  if (task.labels.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    LayoutBuilder(
                                      builder: (context, constraints) => Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          for (final label in task.labels)
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: constraints.maxWidth,
                                              ),
                                              child: Tooltip(
                                                message: label.name,
                                                child: Chip(
                                                  avatar: Icon(
                                                    Icons.label_rounded,
                                                    size: 16,
                                                    color: _labelColor(
                                                      label.color,
                                                    ),
                                                  ),
                                                  label: Text(
                                                    label.name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
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
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withValues(alpha: 0.20),
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.10),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.event_rounded,
                                              size: 14,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _formatDate(task.deadline),
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelMedium,
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
