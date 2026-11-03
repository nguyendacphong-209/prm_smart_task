import 'app_task.dart';

List<AppTask> filterTasks(
  List<AppTask> tasks, {
  String query = '',
  String? statusId,
  String? assigneeId,
  String? priority,
  String? labelId,
  bool overdueOnly = false,
  int deadlineOrder = 0,
  required DateTime now,
}) {
  final term = query.trim().toLowerCase();
  final result = tasks
      .where(
        (task) =>
            task.title.toLowerCase().contains(term) &&
            (statusId == null || task.statusId == statusId) &&
            (assigneeId == null || task.assigneeIds.contains(assigneeId)) &&
            (priority == null || task.priority.toLowerCase() == priority) &&
            (labelId == null || task.labelIds.contains(labelId)) &&
            (!overdueOnly ||
                (task.deadline != null && task.deadline!.isBefore(now))),
      )
      .toList();
  if (deadlineOrder != 0) {
    result.sort((a, b) {
      if (a.deadline == null && b.deadline == null) return a.id.compareTo(b.id);
      if (a.deadline == null) return 1;
      if (b.deadline == null) return -1;
      final order = a.deadline!.compareTo(b.deadline!) * deadlineOrder;
      return order == 0 ? a.id.compareTo(b.id) : order;
    });
  }
  return result;
}
