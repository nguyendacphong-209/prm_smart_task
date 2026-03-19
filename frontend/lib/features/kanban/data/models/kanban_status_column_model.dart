import 'package:prm_smart_task/features/kanban/data/models/kanban_task_card_model.dart';
import 'package:prm_smart_task/features/kanban/domain/entities/kanban_status_column.dart';

class KanbanStatusColumnModel {
  const KanbanStatusColumnModel({
    required this.id,
    required this.name,
    required this.position,
    required this.tasks,
  });

  final String id;
  final String name;
  final int position;
  final List<KanbanTaskCardModel> tasks;

  factory KanbanStatusColumnModel.fromJson(Map<String, dynamic> json) {
    final tasksData = json['tasks'];

    return KanbanStatusColumnModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      position: (json['position'] as num?)?.toInt() ?? 0,
      tasks: tasksData is List
          ? tasksData
                .whereType<Map<String, dynamic>>()
                .map(KanbanTaskCardModel.fromJson)
                .toList()
          : const [],
    );
  }

  KanbanStatusColumn toEntity() {
    return KanbanStatusColumn(
      id: id,
      name: name,
      position: position,
      tasks: tasks.map((item) => item.toEntity()).toList(),
    );
  }
}
