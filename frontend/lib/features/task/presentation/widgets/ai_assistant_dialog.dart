import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
import 'package:prm_smart_task/features/task/application/providers/task_providers.dart';
import 'package:prm_smart_task/features/task/data/models/ai_task_analyze_model.dart';

class AiFormApplicationResult {
  const AiFormApplicationResult({
    required this.priority,
    required this.estimatedHours,
    required this.summary,
    required this.selectedSubtasks,
  });

  final String priority;
  final int estimatedHours;
  final String summary;
  final List<String> selectedSubtasks;
}

class AiAssistantDialog extends ConsumerStatefulWidget {
  const AiAssistantDialog({
    super.key,
    required this.initialTitle,
    required this.initialDescription,
  });

  final String initialTitle;
  final String initialDescription;

  @override
  ConsumerState<AiAssistantDialog> createState() => _AiAssistantDialogState();
}

class _AiAssistantDialogState extends ConsumerState<AiAssistantDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  bool _isLoading = false;
  AiTaskAnalyzeModel? _aiResult;
  final Set<int> _selectedSubtaskIndices = {};

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(text: widget.initialDescription);

    if (widget.initialTitle.trim().length >= 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _analyze();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final title = _titleController.text.trim();
    if (title.length < 3) {
      showAppSnack('Vui lòng nhập tiêu đề ít nhất 3 ký tự');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final remoteDataSource = ref.read(taskRemoteDataSourceProvider);
      final result = await remoteDataSource.analyzeTaskWithAi(
        taskTitle: title,
        taskDescription: _descriptionController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _aiResult = result;
        _isLoading = false;
        _selectedSubtaskIndices.clear();
        for (var i = 0; i < result.suggestedSubtasks.length; i++) {
          _selectedSubtaskIndices.add(i);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      showAppSnack('Phân tích AI thất bại: ${e.toString()}');
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'LOW':
        return Colors.green;
      case 'MEDIUM':
      default:
        return Colors.orange;
    }
  }

  void _apply() {
    if (_aiResult == null) return;

    final selectedSubtasks = <String>[];
    for (final index in _selectedSubtaskIndices) {
      if (index < _aiResult!.suggestedSubtasks.length) {
        selectedSubtasks.add(_aiResult!.suggestedSubtasks[index]);
      }
    }

    Navigator.of(context).pop(
      AiFormApplicationResult(
        priority: _aiResult!.suggestedPriority.toLowerCase(),
        estimatedHours: _aiResult!.estimatedHours,
        summary: _aiResult!.aiSummary,
        selectedSubtasks: selectedSubtasks,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.amber),
          SizedBox(width: 8),
          Text('Trợ lý AI Task Assistant'),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề công việc',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Mô tả ngắn (tùy chọn)',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _analyze,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isLoading ? 'AI đang phân tích...' : 'Phân tích công việc bằng AI'),
                ),
              ),
              if (_aiResult != null) ...[
                const Divider(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(_aiResult!.suggestedPriority),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Độ ưu tiên: ${_aiResult!.suggestedPriority}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Dự kiến: ${_aiResult!.estimatedHours} giờ',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '📝 Tóm tắt AI:',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _aiResult!.aiSummary,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '📋 Gợi ý danh sách Sub-tasks:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                ...List.generate(_aiResult!.suggestedSubtasks.length, (index) {
                  final subtask = _aiResult!.suggestedSubtasks[index];
                  final isChecked = _selectedSubtaskIndices.contains(index);
                  return CheckboxListTile(
                    value: isChecked,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      subtask,
                      style: TextStyle(
                        decoration: isChecked ? TextDecoration.none : TextDecoration.lineThrough,
                        color: isChecked ? null : Colors.grey,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedSubtaskIndices.add(index);
                        } else {
                          _selectedSubtaskIndices.remove(index);
                        }
                      });
                    },
                  );
                }),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
        if (_aiResult != null)
          FilledButton.icon(
            onPressed: _apply,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Áp dụng gợi ý AI'),
          ),
      ],
    );
  }
}
