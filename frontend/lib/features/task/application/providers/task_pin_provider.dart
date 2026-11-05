import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/core/network/dio_client.dart';
import 'package:prm_smart_task/features/auth/application/providers/auth_providers.dart';

class PinnedTask {
  const PinnedTask({
    required this.taskId,
    required this.projectId,
    required this.workspaceId,
    required this.title,
    required this.projectName,
  });
  final String taskId, projectId, workspaceId, title, projectName;
  factory PinnedTask.fromJson(Map<String, dynamic> json) => PinnedTask(
    taskId: json['taskId'] as String,
    projectId: json['projectId'] as String,
    workspaceId: json['workspaceId'] as String,
    title: json['title'] as String,
    projectName: json['projectName'] as String,
  );
}

final taskPinsProvider = FutureProvider.autoDispose<List<PinnedTask>>((
  ref,
) async {
  // Reset cached bookmarks whenever the signed-in account changes.
  final userId = ref.watch(authControllerProvider.select((s) => s.user?.id));
  final authenticated = ref.watch(
    authControllerProvider.select((s) => s.isAuthenticated),
  );
  if (!authenticated || userId == null) {
    return [];
  }
  final response = await ref.watch(dioProvider).get('/api/me/pinned-tasks');
  return (response.data as List)
      .map(
        (item) => PinnedTask.fromJson(Map<String, dynamic>.from(item as Map)),
      )
      .toList();
});
