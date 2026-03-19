import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/core/network/dio_client.dart';
import 'package:prm_smart_task/features/project/application/providers/project_controller.dart';
import 'package:prm_smart_task/features/project/application/states/project_state.dart';
import 'package:prm_smart_task/features/project/data/datasources/project_remote_data_source.dart';
import 'package:prm_smart_task/features/project/data/repositories/project_repository_impl.dart';
import 'package:prm_smart_task/features/project/domain/repositories/project_repository.dart';

final projectRemoteDataSourceProvider = Provider<ProjectRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ProjectRemoteDataSource(dio);
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final remote = ref.watch(projectRemoteDataSourceProvider);
  return ProjectRepositoryImpl(remote);
});

final projectControllerProvider =
    StateNotifierProvider<ProjectController, ProjectState>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return ProjectController(repository);
});
