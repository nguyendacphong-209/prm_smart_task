import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/shared/application/providers/image_upload_provider.dart';
import 'package:prm_smart_task/shared/data/repositories/image_upload_repository.dart';

/// State for image upload operations
class ImageUploadState {
  const ImageUploadState({
    this.isUploading = false,
    this.uploadedImageUrl,
    this.errorMessage,
  });

  final bool isUploading;
  final String? uploadedImageUrl;
  final String? errorMessage;

  ImageUploadState copyWith({
    bool? isUploading,
    String? uploadedImageUrl,
    String? errorMessage,
    String? clearImageUrl,
  }) {
    return ImageUploadState(
      isUploading: isUploading ?? this.isUploading,
      uploadedImageUrl: clearImageUrl != null ? null : (uploadedImageUrl ?? this.uploadedImageUrl),
      errorMessage: errorMessage,
    );
  }
}

/// Controller for image upload operations
class ImageUploadController extends StateNotifier<ImageUploadState> {
  ImageUploadController(this._repository) : super(const ImageUploadState());

  final ImageUploadRepository _repository;

  /// Upload user avatar
  Future<bool> uploadAvatar(List<int> bytes, String fileName) async {
    state = state.copyWith(isUploading: true, errorMessage: null);
    try {
      final imageUrl = await _repository.uploadAvatar(bytes, fileName);
      state = state.copyWith(
        isUploading: false,
        uploadedImageUrl: imageUrl,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  /// Upload workspace image
  Future<bool> uploadWorkspaceImage(
    String workspaceId,
    List<int> bytes,
    String fileName,
  ) async {
    state = state.copyWith(isUploading: true, errorMessage: null);
    try {
      final imageUrl = await _repository.uploadWorkspaceImage(
        workspaceId,
        bytes,
        fileName,
      );
      state = state.copyWith(
        isUploading: false,
        uploadedImageUrl: imageUrl,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  /// Upload project image
  Future<bool> uploadProjectImage(
    String projectId,
    List<int> bytes,
    String fileName,
  ) async {
    state = state.copyWith(isUploading: true, errorMessage: null);
    try {
      final imageUrl = await _repository.uploadProjectImage(
        projectId,
        bytes,
        fileName,
      );
      state = state.copyWith(
        isUploading: false,
        uploadedImageUrl: imageUrl,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  /// Upload task image
  Future<bool> uploadTaskImage(
    String taskId,
    List<int> bytes,
    String fileName,
  ) async {
    state = state.copyWith(isUploading: true, errorMessage: null);
    try {
      final imageUrl = await _repository.uploadTaskImage(
        taskId,
        bytes,
        fileName,
      );
      state = state.copyWith(
        isUploading: false,
        uploadedImageUrl: imageUrl,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  /// Clear state
  void clearState() {
    state = const ImageUploadState();
  }
}

/// Provider for ImageUploadController
final imageUploadControllerProvider =
    StateNotifierProvider<ImageUploadController, ImageUploadState>((ref) {
  return ImageUploadController(ref.watch(imageUploadRepositoryProvider));
});
