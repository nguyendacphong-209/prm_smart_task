import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:prm_smart_task/core/network/dio_client.dart';
import 'package:prm_smart_task/features/task/application/providers/task_pin_provider.dart';

class TaskPinButton extends ConsumerStatefulWidget {
  const TaskPinButton({super.key, required this.taskId});
  final String taskId;
  @override
  ConsumerState<TaskPinButton> createState() => _TaskPinButtonState();
}

class _TaskPinButtonState extends ConsumerState<TaskPinButton> {
  bool _busy = false;
  Future<void> _toggle(bool pinned) async {
    setState(() => _busy = true);
    try {
      final dio = ref.read(dioProvider);
      final path = '/api/tasks/${widget.taskId}/pin';
      if (pinned) {
        await dio.delete(path);
      } else {
        await dio.put(path);
      }
      ref.invalidate(taskPinsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              pinned ? 'Đã bỏ ghim task' : 'Đã ghim vào danh sách của bạn',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        final message =
            error is DioException && error.response?.statusCode == 404
            ? 'Task không còn tồn tại hoặc bạn không có quyền truy cập.'
            : 'Không cập nhật được ghim. Vui lòng thử lại.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pins = ref.watch(taskPinsProvider);
    return pins.when(
      skipLoadingOnRefresh: false,
      data: (items) {
        final pinned = items.any((item) => item.taskId == widget.taskId);
        return IconButton(
          tooltip: pinned ? 'Bỏ ghim task' : 'Ghim task cho tôi',
          onPressed: _busy ? null : () => _toggle(pinned),
          icon: Icon(
            pinned ? Icons.bookmark : Icons.bookmark_border,
            color: pinned ? Theme.of(context).colorScheme.primary : null,
          ),
        );
      },
      loading: () => const IconButton(
        onPressed: null,
        tooltip: 'Đang tải ghim',
        icon: Icon(Icons.bookmark_border),
      ),
      error: (_, _) => IconButton(
        tooltip: 'Không tải được ghim. Bấm để thử lại',
        onPressed: () => ref.invalidate(taskPinsProvider),
        icon: const Icon(Icons.sync_problem),
      ),
    );
  }
}
