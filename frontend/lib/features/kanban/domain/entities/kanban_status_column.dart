import 'package:prm_smart_task/features/kanban/domain/entities/kanban_task_card.dart';

class KanbanStatusColumn {
  const KanbanStatusColumn({
    required this.id,
    required this.name,
    required this.position,
    required this.tasks,
  });

  final String id;
  final String name;
  final int position;
  final List<KanbanTaskCard> tasks;
}
