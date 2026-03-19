import 'package:prm_smart_task/features/kanban/data/datasources/kanban_remote_data_source.dart';
import 'package:prm_smart_task/features/kanban/domain/entities/kanban_board.dart';
import 'package:prm_smart_task/features/kanban/domain/entities/kanban_status_column.dart';
import 'package:prm_smart_task/features/kanban/domain/entities/kanban_task_card.dart';
import 'package:prm_smart_task/features/kanban/domain/repositories/kanban_repository.dart';

class KanbanRepositoryImpl implements KanbanRepository {
  const KanbanRepositoryImpl(this._remote);

  final KanbanRemoteDataSource _remote;

  @override
  Future<KanbanBoard> getBoard({required String projectId}) async {
    final board = await _remote.getBoard(projectId: projectId);
    return board.toEntity();
  }

  @override
  Future<KanbanStatusColumn> createStatus({
    required String projectId,
    required String name,
  }) async {
    final column = await _remote.createStatus(projectId: projectId, name: name);
    return column.toEntity();
  }

  @override
  Future<KanbanTaskCard> moveTaskToStatus({
    required String taskId,
    required String statusId,
  }) async {
    final task = await _remote.moveTaskToStatus(taskId: taskId, statusId: statusId);
    return task.toEntity();
  }
}
