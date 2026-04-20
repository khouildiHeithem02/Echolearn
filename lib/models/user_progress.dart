import 'exercise_model.dart';

class UserProgress {
  final String skillId;
  final Difficulty difficulty;
  final int score;
  final bool isCompleted;

  UserProgress({
    required this.skillId,
    required this.difficulty,
    this.score = 0,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'skillId': skillId,
      'difficulty': difficulty.index,
      'score': score,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      skillId: map['skillId'],
      difficulty: Difficulty.values[map['difficulty']],
      score: map['score'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
