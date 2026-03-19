class WorkspaceMember {
  const WorkspaceMember({
    required this.id,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.avatarUrl,
    required this.role,
  });

  final String id;
  final String userId;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String role;
}
