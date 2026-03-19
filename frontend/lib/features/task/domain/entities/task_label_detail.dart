class TaskLabelDetail {
  const TaskLabelDetail({
    required this.id,
    required this.name,
    this.color,
    this.createdById,
    this.creatorFullName,
  });

  final String id;
  final String name;
  final String? color;
  final String? createdById;
  final String? creatorFullName;

  String get creatorLabel =>
      creatorFullName?.isNotEmpty == true
          ? creatorFullName!
          : (createdById?.isNotEmpty == true ? 'Unknown' : 'System');
}
