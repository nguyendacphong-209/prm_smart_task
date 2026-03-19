class Project {
  const Project({
    required this.id,
    required this.workspaceId,
    required this.name,
    this.description,
    this.createdAt,
  });

  final String id;
  final String workspaceId;
  final String name;
  final String? description;
  final DateTime? createdAt;
}
