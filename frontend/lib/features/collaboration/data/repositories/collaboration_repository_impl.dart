import 'package:prm_smart_task/features/collaboration/data/datasources/collaboration_remote_data_source.dart';
import 'package:prm_smart_task/features/collaboration/domain/entities/task_attachment.dart';
import 'package:prm_smart_task/features/collaboration/domain/entities/task_comment.dart';
import 'package:prm_smart_task/features/collaboration/domain/repositories/collaboration_repository.dart';

class CollaborationRepositoryImpl implements CollaborationRepository {
  const CollaborationRepositoryImpl(this._remote);

  final CollaborationRemoteDataSource _remote;

  @override
  Future<List<TaskComment>> getComments({required String taskId}) async {
    final comments = await _remote.getComments(taskId: taskId);
    return comments.map((item) => item.toEntity()).toList();
  }

  @override
  Future<TaskComment> addComment({
    required String taskId,
    required String content,
  }) async {
    final comment = await _remote.addComment(taskId: taskId, content: content);
    return comment.toEntity();
  }

  @override
  Future<List<TaskAttachment>> getAttachments({required String taskId}) async {
    final attachments = await _remote.getAttachments(taskId: taskId);
    return attachments.map((item) => item.toEntity()).toList();
  }

  @override
  Future<TaskAttachment> uploadAttachment({
    required String taskId,
    required List<int> bytes,
    required String fileName,
  }) async {
    final attachment = await _remote.uploadAttachment(
      taskId: taskId,
      bytes: bytes,
      fileName: fileName,
    );
    return attachment.toEntity();
  }
}
