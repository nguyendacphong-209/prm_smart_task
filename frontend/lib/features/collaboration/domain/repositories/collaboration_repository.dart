import 'package:prm_smart_task/features/collaboration/domain/entities/task_attachment.dart';
import 'package:prm_smart_task/features/collaboration/domain/entities/task_comment.dart';

abstract class CollaborationRepository {
  Future<List<TaskComment>> getComments({required String taskId});

  Future<TaskComment> addComment({
    required String taskId,
    required String content,
  });

  Future<List<TaskAttachment>> getAttachments({required String taskId});

  Future<TaskAttachment> uploadAttachment({
    required String taskId,
    required List<int> bytes,
    required String fileName,
  });
}
