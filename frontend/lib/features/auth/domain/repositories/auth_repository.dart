import 'package:prm_smart_task/features/auth/domain/entities/auth_session.dart';
import 'package:prm_smart_task/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
    String? avatarUrl,
  });

  Future<void> logout();

  Future<AuthUser> getCurrentUser();

  Future<AuthUser> updateProfile({
    required String fullName,
    String? avatarUrl,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });

  Future<bool> hasSession();
}
