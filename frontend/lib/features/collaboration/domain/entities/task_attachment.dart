class TaskAttachment {
  const TaskAttachment({
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
}
