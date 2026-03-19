import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/features/auth/application/states/auth_state.dart';
import 'package:prm_smart_task/features/auth/domain/repositories/auth_repository.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(AuthState.initial()) {
    initialize();
  }

  final AuthRepository _repository;

  Future<void> initialize() async {
    try {
      final hasSession = await _repository.hasSession();
      if (!hasSession) {
        state = state.copyWith(isAuthenticated: false, user: null);
        return;
      }

      state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);
      final user = await _repository.getCurrentUser();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
      );
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);

    try {
      final session = await _repository.login(email: email, password: password);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: session.user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String? avatarUrl,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);

    try {
      final session = await _repository.register(
        email: email,
        password: password,
        fullName: fullName,
        avatarUrl: avatarUrl,
      );
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: session.user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);

    try {
      await _repository.logout();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> refreshMe() async {
    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);

    try {
      final user = await _repository.getCurrentUser();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    String? avatarUrl,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);

    try {
      final user = await _repository.updateProfile(
        fullName: fullName,
        avatarUrl: avatarUrl,
      );
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        infoMessage: 'Profile updated successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);

    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
      state = state.copyWith(
        isLoading: false,
        infoMessage: 'Password changed successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearInfo: true);
  }
}
