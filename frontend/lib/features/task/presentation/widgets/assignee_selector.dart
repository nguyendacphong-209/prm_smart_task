import 'package:flutter/material.dart';
import 'package:prm_smart_task/features/workspace/domain/entities/workspace_member.dart';

class AssigneeSelector extends StatefulWidget {
  const AssigneeSelector({
    super.key,
    required this.assigneeOptions,
    required this.selectedAssigneeIds,
    required this.onChanged,
  });

  final List<WorkspaceMember> assigneeOptions;
  final Set<String> selectedAssigneeIds;
  final Function(Set<String>) onChanged;

  @override
  State<AssigneeSelector> createState() => _AssigneeSelectorState();
}

class _AssigneeSelectorState extends State<AssigneeSelector> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.selectedAssigneeIds);
  }

  @override
  void didUpdateWidget(covariant AssigneeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedAssigneeIds.length != widget.selectedAssigneeIds.length ||
        !oldWidget.selectedAssigneeIds.containsAll(widget.selectedAssigneeIds)) {
      _selectedIds = Set.from(widget.selectedAssigneeIds);
    }
  }

  void _showAssigneePopup() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Chọn thành viên'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.assigneeOptions
                      .map(
                        (member) => CheckboxListTile(
                          title: Text(
                            member.fullName.isNotEmpty
                                ? member.fullName
                                : member.email,
                          ),
                          subtitle: member.fullName.isNotEmpty
                              ? Text(member.email)
                              : null,
                          value: _selectedIds.contains(member.userId),
                          onChanged: (selected) {
                            setStateDialog(() {
                              if (selected == true) {
                                _selectedIds.add(member.userId);
                              } else {
                                _selectedIds.remove(member.userId);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () {
                    widget.onChanged(Set<String>.from(_selectedIds));
                    Navigator.of(context).pop();
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedMembers = widget.assigneeOptions
        .where((member) => _selectedIds.contains(member.userId))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Assignees',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: _showAssigneePopup,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_drop_down, size: 18),
                  SizedBox(width: 4),
                  Text('Chọn'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (selectedMembers.isEmpty)
          const Text('Chưa chọn assignee')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedMembers
                .map(
                  (member) => Chip(
                    label: Text(
                      member.fullName.isNotEmpty ? member.fullName : member.email,
                    ),
                    onDeleted: () {
                      setState(() {
                        _selectedIds.remove(member.userId);
                        widget.onChanged(Set<String>.from(_selectedIds));
                      });
                    },
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
