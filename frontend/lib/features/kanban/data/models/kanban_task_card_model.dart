import 'package:prm_smart_task/features/kanban/domain/entities/kanban_task_card.dart';

class KanbanTaskCardModel {
  const KanbanTaskCardModel({
    required this.id,
    required this.title,
    required this.priority,
    this.deadline,
    this.statusId,
  });

  final String id;
  final String title;
  final String priority;
  final DateTime? deadline;
  final String? statusId;

  factory KanbanTaskCardModel.fromJson(Map<String, dynamic> json) {
    return KanbanTaskCardModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      priority: (json['priority']?.toString() ?? 'medium').toLowerCase(),
      deadline: DateTime.tryParse(json['deadline']?.toString() ?? ''),
      statusId: json['statusId']?.toString(),
    );
  }

  KanbanTaskCard toEntity() {
    return KanbanTaskCard(
      id: id,
      title: title,
      priority: priority,
      deadline: deadline,
      statusId: statusId,
    );
  }
}
