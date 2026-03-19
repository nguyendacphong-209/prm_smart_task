import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/core/network/dio_client.dart';
import 'package:prm_smart_task/features/collaboration/application/providers/collaboration_controller.dart';
import 'package:prm_smart_task/features/collaboration/application/states/collaboration_state.dart';
import 'package:prm_smart_task/features/collaboration/data/datasources/collaboration_remote_data_source.dart';
import 'package:prm_smart_task/features/collaboration/data/repositories/collaboration_repository_impl.dart';
import 'package:prm_smart_task/features/collaboration/domain/repositories/collaboration_repository.dart';

final collaborationRemoteDataSourceProvider =
    Provider<CollaborationRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return CollaborationRemoteDataSource(dio);
});

final collaborationRepositoryProvider = Provider<CollaborationRepository>((ref) {
  final remote = ref.watch(collaborationRemoteDataSourceProvider);
  return CollaborationRepositoryImpl(remote);
});

final collaborationControllerProvider =
    StateNotifierProvider<CollaborationController, CollaborationState>((ref) {
  final repository = ref.watch(collaborationRepositoryProvider);
  return CollaborationController(repository);
});
