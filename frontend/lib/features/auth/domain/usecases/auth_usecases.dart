import 'package:prm_smart_task/features/auth/domain/entities/auth_session.dart';
import 'package:prm_smart_task/features/auth/domain/entities/auth_user.dart';
import 'package:prm_smart_task/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this.repository);

  final AuthRepository repository;

  Future<AuthSession> call({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}

class RegisterUseCase {
  const RegisterUseCase(this.repository);

  final AuthRepository repository;

  Future<AuthSession> call({
    required String email,
    required String password,
    required String fullName,
    String? avatarUrl,
  }) {
    return repository.register(
      email: email,
      password: password,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
  }
}

class LogoutUseCase {
  const LogoutUseCase(this.repository);

  final AuthRepository repository;

  Future<void> call() => repository.logout();
}

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this.repository);

  final AuthRepository repository;

  Future<AuthUser> call() => repository.getCurrentUser();
}

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this.repository);

  final AuthRepository repository;

  Future<AuthUser> call({required String fullName, String? avatarUrl}) {
    return repository.updateProfile(fullName: fullName, avatarUrl: avatarUrl);
  }
}

class ChangePasswordUseCase {
  const ChangePasswordUseCase(this.repository);

  final AuthRepository repository;

  Future<void> call({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) {
    return repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
  }
}
