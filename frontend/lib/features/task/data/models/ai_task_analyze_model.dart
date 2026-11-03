class AiTaskAnalyzeModel {
  const AiTaskAnalyzeModel({
    required this.suggestedPriority,
    required this.estimatedHours,
    required this.aiSummary,
    required this.suggestedSubtasks,
  });

  final String suggestedPriority;
  final int estimatedHours;
  final String aiSummary;
  final List<String> suggestedSubtasks;

  factory AiTaskAnalyzeModel.fromJson(Map<String, dynamic> json) {
    return AiTaskAnalyzeModel(
      suggestedPriority: json['suggestedPriority']?.toString() ?? 'MEDIUM',
      estimatedHours: (json['estimatedHours'] as num?)?.toInt() ?? 4,
      aiSummary: json['aiSummary']?.toString() ?? '',
      suggestedSubtasks: (json['suggestedSubtasks'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
