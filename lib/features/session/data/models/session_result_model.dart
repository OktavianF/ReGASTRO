class SessionResultModel {
  final String? id;
  final String userId;
  final String exerciseId;
  final int completedSets;
  final int completedRepetitions;
  final int durationSeconds;
  final int trunkCompensationCount;
  final int incompleteReachCount;
  final int notReturnedCount;
  final String? llmRecommendation;
  final DateTime? createdAt;

  const SessionResultModel({
    this.id,
    required this.userId,
    required this.exerciseId,
    required this.completedSets,
    required this.completedRepetitions,
    required this.durationSeconds,
    required this.trunkCompensationCount,
    required this.incompleteReachCount,
    required this.notReturnedCount,
    this.llmRecommendation,
    this.createdAt,
  });

  factory SessionResultModel.fromJson(Map<String, dynamic> json) {
    return SessionResultModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      exerciseId: json['exercise_id'] as String,
      completedSets: json['completed_sets'] as int,
      completedRepetitions: json['completed_repetitions'] as int,
      durationSeconds: json['duration_seconds'] as int,
      trunkCompensationCount: json['trunk_compensation_count'] as int? ?? 0,
      incompleteReachCount: json['incomplete_reach_count'] as int? ?? 0,
      notReturnedCount: json['not_returned_count'] as int? ?? 0,
      llmRecommendation: json['llm_recommendation'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'exercise_id': exerciseId,
      'completed_sets': completedSets,
      'completed_repetitions': completedRepetitions,
      'duration_seconds': durationSeconds,
      'trunk_compensation_count': trunkCompensationCount,
      'incomplete_reach_count': incompleteReachCount,
      'not_returned_count': notReturnedCount,
      if (llmRecommendation != null) 'llm_recommendation': llmRecommendation,
    };
  }
}
