import 'package:prm_smart_task/features/collaboration/domain/entities/task_attachment.dart';
import 'package:prm_smart_task/features/collaboration/domain/entities/task_comment.dart';

class CollaborationState {
  const CollaborationState({
    required this.comments,
    required this.attachments,
    required this.isLoading,
    required this.isSubmittingComment,
    required this.isUploadingAttachment,
    this.errorMessage,
  });

  final List<TaskComment> comments;
  final List<TaskAttachment> attachments;
  final bool isLoading;
  final bool isSubmittingComment;
  final bool isUploadingAttachment;
  final String? errorMessage;

  factory CollaborationState.initial() {
    return const CollaborationState(
      comments: [],
      attachments: [],
      isLoading: false,
      isSubmittingComment: false,
      isUploadingAttachment: false,
      errorMessage: null,
    );
  }

  CollaborationState copyWith({
    List<TaskComment>? comments,
    List<TaskAttachment>? attachments,
    bool? isLoading,
    bool? isSubmittingComment,
    bool? isUploadingAttachment,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CollaborationState(
      comments: comments ?? this.comments,
      attachments: attachments ?? this.attachments,
      isLoading: isLoading ?? this.isLoading,
      isSubmittingComment: isSubmittingComment ?? this.isSubmittingComment,
      isUploadingAttachment: isUploadingAttachment ?? this.isUploadingAttachment,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
