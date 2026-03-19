import 'package:prm_smart_task/features/kanban/data/models/kanban_status_column_model.dart';
import 'package:prm_smart_task/features/kanban/domain/entities/kanban_board.dart';

class KanbanBoardModel {
  const KanbanBoardModel({
    required this.projectId,
    required this.projectName,
    required this.columns,
  });

  final String projectId;
  final String projectName;
  final List<KanbanStatusColumnModel> columns;

  factory KanbanBoardModel.fromJson(Map<String, dynamic> json) {
    final columnsData = json['columns'];

    return KanbanBoardModel(
      projectId: json['projectId']?.toString() ?? '',
      projectName: json['projectName']?.toString() ?? '',
      columns: columnsData is List
          ? columnsData
                .whereType<Map<String, dynamic>>()
                .map(KanbanStatusColumnModel.fromJson)
                .toList()
          : const [],
    );
  }

  KanbanBoard toEntity() {
    return KanbanBoard(
      projectId: projectId,
      projectName: projectName,
      columns: columns.map((item) => item.toEntity()).toList(),
    );
  }
}
