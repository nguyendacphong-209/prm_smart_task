import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/core/network/dio_client.dart';
import 'package:prm_smart_task/features/task/application/providers/task_controller.dart';
import 'package:prm_smart_task/features/task/application/states/task_state.dart';
import 'package:prm_smart_task/features/task/data/datasources/task_remote_data_source.dart';
import 'package:prm_smart_task/features/task/data/repositories/task_repository_impl.dart';
import 'package:prm_smart_task/features/task/domain/repositories/task_repository.dart';

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return TaskRemoteDataSource(dio);
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final remote = ref.watch(taskRemoteDataSourceProvider);
  return TaskRepositoryImpl(remote);
});

final taskControllerProvider =
    StateNotifierProvider<TaskController, TaskState>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskController(repository);
});
