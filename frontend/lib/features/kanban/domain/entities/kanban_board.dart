import 'package:prm_smart_task/features/kanban/domain/entities/kanban_status_column.dart';

class KanbanBoard {
  const KanbanBoard({
    required this.projectId,
    required this.projectName,
    required this.columns,
  });

  final String projectId;
  final String projectName;
  final List<KanbanStatusColumn> columns;
}
