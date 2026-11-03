class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.vip = false,
    this.vipExpiresAt,
  });

  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final bool vip;
  final DateTime? vipExpiresAt;
}
