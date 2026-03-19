import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/core/network/dio_client.dart';
import 'package:prm_smart_task/features/notification/application/providers/notification_controller.dart';
import 'package:prm_smart_task/features/notification/application/states/notification_state.dart';
import 'package:prm_smart_task/features/notification/data/datasources/notification_remote_data_source.dart';
import 'package:prm_smart_task/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:prm_smart_task/features/notification/domain/repositories/notification_repository.dart';

final notificationRemoteDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationRemoteDataSource(dio);
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final remote = ref.watch(notificationRemoteDataSourceProvider);
  return NotificationRepositoryImpl(remote);
});

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationController(repository);
});
