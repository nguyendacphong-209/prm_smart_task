import 'package:dio/dio.dart';
import 'package:prm_smart_task/core/constants/api_constants.dart';

class ImageUploadRemoteDataSource {
  const ImageUploadRemoteDataSource(this._dio);

  final Dio _dio;

  /// Upload user avatar
  /// Returns the avatar URL from server response
  Future<String> uploadAvatar(List<int> bytes, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });

      final response = await _dio.post(
        ApiConstants.avatarUpload,
        data: formData,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final avatarUrl = data['avatarUrl']?.toString();
        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          return avatarUrl;
        }
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Upload workspace image
  /// Returns the image URL from server response
  Future<String> uploadWorkspaceImage(
    String workspaceId,
    List<int> bytes,
    String fileName,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });

      final response = await _dio.post(
        ApiConstants.workspaceImageUpload(workspaceId),
        data: formData,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final imageUrl = data['imageUrl']?.toString();
        if (imageUrl != null && imageUrl.isNotEmpty) {
          return imageUrl;
        }
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Upload project image
  /// Returns the image URL from server response
  Future<String> uploadProjectImage(
    String projectId,
    List<int> bytes,
    String fileName,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });

      final response = await _dio.post(
        ApiConstants.projectImageUpload(projectId),
        data: formData,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final imageUrl = data['imageUrl']?.toString();
        if (imageUrl != null && imageUrl.isNotEmpty) {
          return imageUrl;
        }
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Upload task image
  /// Returns the image URL from server response
  Future<String> uploadTaskImage(
    String taskId,
    List<int> bytes,
    String fileName,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });

      final response = await _dio.post(
        ApiConstants.taskImageUpload(taskId),
        data: formData,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final imageUrl = data['imageUrl']?.toString();
        if (imageUrl != null && imageUrl.isNotEmpty) {
          return imageUrl;
        }
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Delete image by URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      await _dio.delete(
        ApiConstants.imageDelete,
        queryParameters: {'imageUrl': imageUrl},
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    return e.message ?? 'Request failed';
  }
}
