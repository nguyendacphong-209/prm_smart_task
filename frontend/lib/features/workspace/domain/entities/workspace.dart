class Workspace {
  const Workspace({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.myRole,
    this.imageUrl,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String ownerId;
  final String myRole;
  final String? imageUrl;
  final DateTime? createdAt;
}
