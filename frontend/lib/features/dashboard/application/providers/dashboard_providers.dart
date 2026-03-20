import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/core/network/dio_client.dart';
import 'package:prm_smart_task/features/dashboard/application/providers/dashboard_controller.dart';
import 'package:prm_smart_task/features/dashboard/application/states/dashboard_state.dart';
import 'package:prm_smart_task/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:prm_smart_task/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:prm_smart_task/features/dashboard/domain/repositories/dashboard_repository.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return DashboardRemoteDataSource(dio);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final remote = ref.watch(dashboardRemoteDataSourceProvider);
  return DashboardRepositoryImpl(remote);
});

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return DashboardController(repository);
});
