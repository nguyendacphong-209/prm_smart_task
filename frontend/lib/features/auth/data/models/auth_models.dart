import 'package:prm_smart_task/features/auth/domain/entities/auth_session.dart';
import 'package:prm_smart_task/features/auth/domain/entities/auth_user.dart';

class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id']?.toString() ?? json['userId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }

  AuthUser toEntity() {
    return AuthUser(
      id: id,
      email: email,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
  }
}

class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AuthUserModel user;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final accessToken = json['accessToken'];
    final refreshToken = json['refreshToken'];
    final userId = json['userId'];
    final email = json['email'];
    if (accessToken is! String ||
        accessToken.isEmpty ||
        refreshToken is! String ||
        refreshToken.isEmpty ||
        userId == null ||
        userId.toString().isEmpty ||
        email is! String ||
        email.isEmpty) {
      throw const FormatException(
        'Server trả về phiên đăng nhập không hợp lệ.',
      );
    }

    final user = AuthUserModel(
      id: userId.toString(),
      email: email,
      fullName: json['fullName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
    );

    return AuthSessionModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
  }

  AuthSession toEntity() {
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user.toEntity(),
    );
  }
}
