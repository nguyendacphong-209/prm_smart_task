import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/features/collaboration/application/states/collaboration_state.dart';
import 'package:prm_smart_task/features/collaboration/domain/repositories/collaboration_repository.dart';

class CollaborationController extends StateNotifier<CollaborationState> {
  CollaborationController(this._repository) : super(CollaborationState.initial());

  final CollaborationRepository _repository;

  Future<void> loadTaskCollaboration({required String taskId}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final commentsFuture = _repository.getComments(taskId: taskId);
      final attachmentsFuture = _repository.getAttachments(taskId: taskId);
      final comments = await commentsFuture;
      final attachments = await attachmentsFuture;

      state = state.copyWith(
        isLoading: false,
        comments: comments,
        attachments: attachments,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> addComment({
    required String taskId,
    required String content,
  }) async {
    state = state.copyWith(isSubmittingComment: true, clearError: true);
    try {
      final comment = await _repository.addComment(taskId: taskId, content: content);
      state = state.copyWith(
        isSubmittingComment: false,
        comments: [...state.comments, comment],
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmittingComment: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> uploadAttachment({
    required String taskId,
    required List<int> bytes,
    required String fileName,
  }) async {
    state = state.copyWith(isUploadingAttachment: true, clearError: true);
    try {
      final attachment = await _repository.uploadAttachment(
        taskId: taskId,
        bytes: bytes,
        fileName: fileName,
      );
      state = state.copyWith(
        isUploadingAttachment: false,
        attachments: [attachment, ...state.attachments],
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUploadingAttachment: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
