import 'package:flutter/material.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
import 'package:prm_smart_task/features/task/domain/entities/task_label_option.dart';
import 'package:prm_smart_task/features/task/domain/entities/task_status_option.dart';
import 'package:prm_smart_task/features/task/presentation/widgets/assignee_selector.dart';
import 'package:prm_smart_task/features/workspace/domain/entities/workspace_member.dart';

class TaskFormResult {
  const TaskFormResult({
    required this.title,
    this.description,
    required this.priority,
    this.deadline,
    required this.statusId,
    required this.assigneeIds,
    required this.labelIds,
  });

  final String title;
  final String? description;
  final String priority;
  final DateTime? deadline;
  final String statusId;
  final List<String> assigneeIds;
  final List<String> labelIds;
}

class TaskFormDialog extends StatefulWidget {
  const TaskFormDialog({
    super.key,
    required this.dialogTitle,
    required this.confirmLabel,
    required this.statusOptions,
    required this.assigneeOptions,
    required this.labelOptions,
    required this.initialTitle,
    required this.initialDescription,
    required this.initialPriority,
    required this.initialDeadline,
    required this.initialStatusId,
    required this.initialAssigneeIds,
    required this.initialLabelIds,
    required this.deadlineButtonLabel,
  });

  final String dialogTitle;
  final String confirmLabel;
  final List<TaskStatusOption> statusOptions;
  final List<WorkspaceMember> assigneeOptions;
  final List<TaskLabelOption> labelOptions;
  final String initialTitle;
  final String initialDescription;
  final String initialPriority;
  final DateTime? initialDeadline;
  final String initialStatusId;
  final Set<String> initialAssigneeIds;
  final Set<String> initialLabelIds;
  final String deadlineButtonLabel;

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _priority;
  late DateTime? _selectedDeadline;
  late String _selectedStatusId;
  late Set<String> _selectedAssigneeIds;
  late Set<String> _selectedLabelIds;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(text: widget.initialDescription);
    _priority = widget.initialPriority;
    _selectedDeadline = widget.initialDeadline;
    _selectedStatusId = widget.initialStatusId;
    _selectedAssigneeIds = {...widget.initialAssigneeIds};
    _selectedLabelIds = {...widget.initialLabelIds};
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDeadline ?? DateTime.now()),
    );
    if (time == null || !mounted) return;

    setState(() {
      _selectedDeadline = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.length < 3) {
      showAppSnack('Tiêu đề tối thiểu 3 ký tự');
      return;
    }

    if (_selectedStatusId.isEmpty) {
      showAppSnack('Vui lòng chọn task status');
      return;
    }

    final description = _descriptionController.text.trim();

    Navigator.of(context).pop(
      TaskFormResult(
        title: title,
        description: description.isEmpty ? null : description,
        priority: _priority,
        deadline: _selectedDeadline,
        statusId: _selectedStatusId,
        assigneeIds: _selectedAssigneeIds.toList(),
        labelIds: _selectedLabelIds.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                prefixIcon: Icon(Icons.task_alt_rounded),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _priority,
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
                setState(() {
                  _priority = value ?? 'medium';
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatusId,
              decoration: const InputDecoration(
                labelText: 'Task status',
                prefixIcon: Icon(Icons.view_column_outlined),
              ),
              items: widget.statusOptions
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option.id,
                      child: Text(option.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatusId = value ?? _selectedStatusId;
                });
              },
            ),
            const SizedBox(height: 10),
            if (widget.assigneeOptions.isEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Workspace chưa có assignee để chọn',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              )
            else
              AssigneeSelector(
                assigneeOptions: widget.assigneeOptions,
                selectedAssigneeIds: _selectedAssigneeIds,
                onChanged: (selected) {
                  setState(() {
                    _selectedAssigneeIds = {...selected};
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
            if (widget.labelOptions.isEmpty)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Chưa có label khả dụng trong project'),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.labelOptions
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
                        selected: _selectedLabelIds.contains(label.id),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedLabelIds.add(label.id);
                            } else {
                              _selectedLabelIds.remove(label.id);
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
                    _formatDate(_selectedDeadline),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickDeadline,
                  icon: const Icon(Icons.event_outlined),
                  label: Text(widget.deadlineButtonLabel),
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
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
