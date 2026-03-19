import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/core/network/dio_client.dart';
import 'package:prm_smart_task/features/auth/application/providers/auth_controller.dart';
import 'package:prm_smart_task/features/auth/application/states/auth_state.dart';
import 'package:prm_smart_task/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:prm_smart_task/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:prm_smart_task/features/auth/domain/repositories/auth_repository.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDataSource(dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remote);
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});
