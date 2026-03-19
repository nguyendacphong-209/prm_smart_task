class KanbanTaskCard {
  const KanbanTaskCard({
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
}
