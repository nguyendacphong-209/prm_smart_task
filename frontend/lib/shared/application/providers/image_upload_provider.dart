import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/core/network/dio_client.dart';
import 'package:prm_smart_task/shared/data/datasources/image_upload_remote_data_source.dart';
import 'package:prm_smart_task/shared/data/repositories/image_upload_repository.dart';

/// Provider for ImageUploadRemoteDataSource
final imageUploadRemoteDataSourceProvider = Provider<ImageUploadRemoteDataSource>(
  (ref) => ImageUploadRemoteDataSource(ref.watch(dioProvider)),
);

/// Provider for ImageUploadRepository
final imageUploadRepositoryProvider = Provider<ImageUploadRepository>(
  (ref) => ImageUploadRepository(
    ref.watch(imageUploadRemoteDataSourceProvider),
  ),
);
