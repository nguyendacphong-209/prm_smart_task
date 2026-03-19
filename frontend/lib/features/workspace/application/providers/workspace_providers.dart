import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/core/network/dio_client.dart';
import 'package:prm_smart_task/features/workspace/application/providers/workspace_controller.dart';
import 'package:prm_smart_task/features/workspace/application/states/workspace_state.dart';
import 'package:prm_smart_task/features/workspace/data/datasources/workspace_remote_data_source.dart';
import 'package:prm_smart_task/features/workspace/data/repositories/workspace_repository_impl.dart';
import 'package:prm_smart_task/features/workspace/domain/repositories/workspace_repository.dart';

final workspaceRemoteDataSourceProvider = Provider<WorkspaceRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return WorkspaceRemoteDataSource(dio);
});

final workspaceRepositoryProvider = Provider<WorkspaceRepository>((ref) {
  final remote = ref.watch(workspaceRemoteDataSourceProvider);
  return WorkspaceRepositoryImpl(remote);
});

final workspaceControllerProvider =
    StateNotifierProvider<WorkspaceController, WorkspaceState>((ref) {
  final repository = ref.watch(workspaceRepositoryProvider);
  return WorkspaceController(repository);
});
