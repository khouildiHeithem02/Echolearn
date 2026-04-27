enum ExerciseType {
  multipleChoice,
  matching,
  sequence,
  trueFalse,
  ordering,
  naming,
  speak,
}

enum Difficulty { easy, medium, hard }

class Exercise {
  final String id;
  final String skillId;
  final String prompt;
  final ExerciseType type;
  final Difficulty difficulty;
  final List<String> options;
  final String correctAnswer;
  final String audioAsset; // For environmental sounds
  final String imageAsset; // For visual prompts
  final String ttsText; // For dynamic speech
  final bool isGentle; // For soft/gentle TTS parameters

  Exercise({
    required this.id,
    required this.skillId,
    required this.prompt,
    required this.type,
    required this.difficulty,
    this.options = const [],
    required this.correctAnswer,
    this.audioAsset = '',
    this.imageAsset = '',
    this.ttsText = '',
    this.isGentle = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'skillId': skillId,
      'prompt': prompt,
      'type': type.index,
      'difficulty': difficulty.index,
      'correctAnswer': correctAnswer,
    };
  }
}
