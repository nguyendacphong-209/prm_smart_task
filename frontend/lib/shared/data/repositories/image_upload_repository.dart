import 'package:prm_smart_task/shared/data/datasources/image_upload_remote_data_source.dart';

class ImageUploadRepository {
  const ImageUploadRepository(this._remoteDataSource);

  final ImageUploadRemoteDataSource _remoteDataSource;

  /// Upload user avatar
  /// Returns the avatar URL
  Future<String> uploadAvatar(List<int> bytes, String fileName) async {
    return await _remoteDataSource.uploadAvatar(bytes, fileName);
  }

  /// Upload workspace image
  /// Returns the image URL
  Future<String> uploadWorkspaceImage(
    String workspaceId,
    List<int> bytes,
    String fileName,
  ) async {
    return await _remoteDataSource.uploadWorkspaceImage(
      workspaceId,
      bytes,
      fileName,
    );
  }

  /// Upload project image
  /// Returns the image URL
  Future<String> uploadProjectImage(
    String projectId,
    List<int> bytes,
    String fileName,
  ) async {
    return await _remoteDataSource.uploadProjectImage(
      projectId,
      bytes,
      fileName,
    );
  }

  /// Upload task image
  /// Returns the image URL
  Future<String> uploadTaskImage(
    String taskId,
    List<int> bytes,
    String fileName,
  ) async {
    return await _remoteDataSource.uploadTaskImage(
      taskId,
      bytes,
      fileName,
    );
  }

  /// Delete image by URL
  Future<void> deleteImage(String imageUrl) async {
    return await _remoteDataSource.deleteImage(imageUrl);
  }
}
