import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_smart_task/features/task/application/providers/task_pin_provider.dart';
import 'package:prm_smart_task/features/task/presentation/widgets/task_pin_button.dart';

class PinnedTasksPage extends ConsumerWidget {
  const PinnedTasksPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pins = ref.watch(taskPinsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task đã ghim'),
        actions: [
          IconButton(
            tooltip: 'Làm mới danh sách ghim',
            onPressed: () => ref.invalidate(taskPinsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: pins.when(
        skipLoadingOnRefresh: false,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Không tải được danh sách ghim.'),
              TextButton(
                onPressed: () => ref.invalidate(taskPinsProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (items) => items.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Bạn chưa ghim task nào có thể truy cập.\nBấm biểu tượng dấu trang trên thẻ task để ghim.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(taskPinsProvider);
                  try {
                    await ref.read(taskPinsProvider.future);
                  } catch (_) {
                    // The provider renders the error and retry action above.
                  }
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final task = items[index];
                    return Card(
                      child: ListTile(
                        title: Text(task.title),
                        subtitle: Text(task.projectName),
                        trailing: TaskPinButton(
                          key: ValueKey(task.taskId),
                          taskId: task.taskId,
                        ),
                        onTap: () async {
                          final uri = Uri(
                            path: '/tasks/${task.taskId}',
                            queryParameters: {
                              'projectId': task.projectId,
                              'workspaceId': task.workspaceId,
                              'projectName': task.projectName,
                            },
                          );
                          await context.push(uri.toString());
                          if (context.mounted) {
                            ref.invalidate(taskPinsProvider);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
