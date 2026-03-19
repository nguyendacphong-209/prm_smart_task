import 'package:prm_smart_task/core/storage/auth_storage.dart';
import 'package:prm_smart_task/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:prm_smart_task/features/auth/domain/entities/auth_session.dart';
import 'package:prm_smart_task/features/auth/domain/entities/auth_user.dart';
import 'package:prm_smart_task/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final sessionModel = await _remote.login(email: email, password: password);
    await AuthStorage.saveTokens(
      accessToken: sessionModel.accessToken,
      refreshToken: sessionModel.refreshToken,
    );
    return sessionModel.toEntity();
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
    String? avatarUrl,
  }) async {
    final sessionModel = await _remote.register(
      email: email,
      password: password,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
    await AuthStorage.saveTokens(
      accessToken: sessionModel.accessToken,
      refreshToken: sessionModel.refreshToken,
    );
    return sessionModel.toEntity();
  }

  @override
  Future<void> logout() async {
    final refreshToken = await AuthStorage.getRefreshToken();

    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _remote.logout(refreshToken: refreshToken);
    }

    await AuthStorage.clear();
  }

  @override
  Future<AuthUser> getCurrentUser() async {
    final userModel = await _remote.getCurrentUser();
    return userModel.toEntity();
  }

  @override
  Future<AuthUser> updateProfile({
    required String fullName,
    String? avatarUrl,
  }) async {
    final userModel = await _remote.updateProfile(
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
    return userModel.toEntity();
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) {
    return _remote.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
  }

  @override
  Future<bool> hasSession() async {
    final token = await AuthStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
