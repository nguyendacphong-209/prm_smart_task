import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/core/network/dio_client.dart';
import 'package:prm_smart_task/features/kanban/application/providers/kanban_controller.dart';
import 'package:prm_smart_task/features/kanban/application/states/kanban_state.dart';
import 'package:prm_smart_task/features/kanban/data/datasources/kanban_remote_data_source.dart';
import 'package:prm_smart_task/features/kanban/data/repositories/kanban_repository_impl.dart';
import 'package:prm_smart_task/features/kanban/domain/repositories/kanban_repository.dart';

final kanbanRemoteDataSourceProvider = Provider<KanbanRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return KanbanRemoteDataSource(dio);
});

final kanbanRepositoryProvider = Provider<KanbanRepository>((ref) {
  final remote = ref.watch(kanbanRemoteDataSourceProvider);
  return KanbanRepositoryImpl(remote);
});

final kanbanControllerProvider =
    StateNotifierProvider<KanbanController, KanbanState>((ref) {
  final repository = ref.watch(kanbanRepositoryProvider);
  return KanbanController(repository);
});
