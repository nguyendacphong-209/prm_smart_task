import 'package:prm_smart_task/features/auth/domain/entities/auth_user.dart';

class AuthState {
  const AuthState({
    required this.isLoading,
    required this.isAuthenticated,
    this.user,
    this.errorMessage,
    this.infoMessage,
  });

  final bool isLoading;
  final bool isAuthenticated;
  final AuthUser? user;
  final String? errorMessage;
  final String? infoMessage;

  factory AuthState.initial() {
    return const AuthState(
      isLoading: false,
      isAuthenticated: false,
    );
  }

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    AuthUser? user,
    String? errorMessage,
    String? infoMessage,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }
}
