import 'package:prm_smart_task/features/kanban/domain/entities/kanban_board.dart';
import 'package:prm_smart_task/features/kanban/domain/entities/kanban_status_column.dart';
import 'package:prm_smart_task/features/kanban/domain/entities/kanban_task_card.dart';

abstract class KanbanRepository {
  Future<KanbanBoard> getBoard({required String projectId});

  Future<KanbanStatusColumn> createStatus({
    required String projectId,
    required String name,
  });

  Future<KanbanTaskCard> moveTaskToStatus({
    required String taskId,
    required String statusId,
  });
}
