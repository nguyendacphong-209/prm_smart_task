import 'package:prm_smart_task/features/collaboration/domain/entities/task_attachment.dart';

DateTime? _parseDateTime(dynamic raw) {
  final value = raw?.toString().trim() ?? '';
  if (value.isEmpty) return null;

  final direct = DateTime.tryParse(value);
  if (direct != null) return direct;

  final normalized = value.replaceFirst(' ', 'T');
  return DateTime.tryParse(normalized);
}

class TaskAttachmentModel {
  const TaskAttachmentModel({
    required this.id,
    required this.taskId,
    required this.fileName,
    required this.fileUrl,
    required this.uploadedAt,
  });

  final String id;
  final String taskId;
  final String fileName;
  final String fileUrl;
  final DateTime? uploadedAt;

  factory TaskAttachmentModel.fromJson(Map<String, dynamic> json) {
    return TaskAttachmentModel(
      id: json['id']?.toString() ?? '',
      taskId: json['taskId']?.toString() ?? '',
      fileName: json['fileName']?.toString() ?? '',
      fileUrl: json['fileUrl']?.toString() ?? '',
      uploadedAt: _parseDateTime(json['uploadedAt']),
    );
  }

  TaskAttachment toEntity() {
    return TaskAttachment(
      id: id,
      taskId: taskId,
      fileName: fileName,
      fileUrl: fileUrl,
      uploadedAt: uploadedAt,
    );
  }
}
