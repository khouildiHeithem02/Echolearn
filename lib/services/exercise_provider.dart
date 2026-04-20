import 'package:flutter/foundation.dart';
import '../models/exercise_model.dart';
import '../models/skill_category.dart';
import 'database_helper.dart';
import '../models/user_progress.dart';

class ExerciseProvider with ChangeNotifier {
  List<Exercise> _exercises = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = false;

  List<Exercise> get exercises => _exercises;
  int get currentIndex => _currentIndex;
  int get score => _score;
  bool get isLoading => _isLoading;

  Exercise? get currentExercise => 
      _currentIndex < _exercises.length ? _exercises[_currentIndex] : null;

  void loadExercises(String skillId, Difficulty difficulty) {
    _isLoading = true;
    notifyListeners();

    // Mock Data Generator
    _exercises = _getMockExercises(skillId, difficulty);
    _currentIndex = 0;
    _score = 0;
    _isLoading = false;
    notifyListeners();
  }

  void submitAnswer(String answer) {
    if (currentExercise == null) return;

    if (answer == currentExercise!.correctAnswer) {
      _score += 10;
    }

    _currentIndex++;
    
    if (_currentIndex >= _exercises.length) {
      _saveFinalProgress();
    }
    
    notifyListeners();
  }

  Future<void> _saveFinalProgress() async {
    if (_exercises.isEmpty) return;
    
    final finalScore = ((_score / (_exercises.length * 10)) * 100).toInt();
    final progress = UserProgress(
      skillId: _exercises.first.skillId,
      difficulty: _exercises.first.difficulty,
      score: finalScore,
      isCompleted: true,
    );
    
    await DatabaseHelper.instance.saveProgress(progress);
  }

  List<Exercise> _getMockExercises(String skillId, Difficulty difficulty) {
    // Basic mock logic for "First Try"
    if (skillId == 'aud_1') {
      return [
        // Category: الجهر والهمس (Voiced vs Voiceless) - Simple: "طنين" vs "هواء"
        Exercise(
          id: 'aud_1_1',
          skillId: 'aud_1',
          prompt: 'هل لهذا الصوت طنين قوي؟ (مجهور)',
          type: ExerciseType.trueFalse,
          difficulty: difficulty,
          correctAnswer: 'نعم',
          ttsText: 'ز . ز . ز',
        ),
        Exercise(
          id: 'aud_1_2',
          skillId: 'aud_1',
          prompt: 'هل تسمع هواءً في هذا الصوت؟ (مهموس)',
          type: ExerciseType.trueFalse,
          difficulty: difficulty,
          correctAnswer: 'نعم',
          ttsText: 'س . س . س',
        ),
        // Category: الشدة (Stops) - Simple: "مقطوع" vs "مستمر"
        Exercise(
          id: 'aud_1_3',
          skillId: 'aud_1',
          prompt: 'اختر الصوت الذي ينقطع فجأة (شديد)',
          type: ExerciseType.multipleChoice,
          difficulty: difficulty,
          options: ['س', 'ب', 'ح'],
          correctAnswer: 'ب',
          ttsText: 'س... ب... ح...',
        ),
        // Category: مكان النطق (Articulation Points)
        Exercise(
          id: 'aud_1_4',
          skillId: 'aud_1',
          prompt: 'هل يخرج هذا الصوت من الحلق؟',
          type: ExerciseType.trueFalse,
          difficulty: difficulty,
          correctAnswer: 'نعم',
          ttsText: 'ح . ح . ح',
        ),
        Exercise(
          id: 'aud_1_5',
          skillId: 'aud_1',
          prompt: 'أي صوت يخرج من الشفتين؟',
          type: ExerciseType.multipleChoice,
          difficulty: difficulty,
          options: ['ن', 'ل', 'م'],
          correctAnswer: 'م',
          ttsText: 'ن... ل... م...',
        ),
        // Category: الفروق الدقيقة (Minimal Pairs)
        Exercise(
          id: 'aud_1_6',
          skillId: 'aud_1',
          prompt: 'هل الكلمتان متطابقتان؟',
          type: ExerciseType.trueFalse,
          difficulty: difficulty,
          correctAnswer: 'لا',
          ttsText: 'تاب . طاب',
        ),
      ];
    }
    
    // Default fallback
    return [
      Exercise(
        id: 'default',
        skillId: skillId,
        prompt: 'تمهيد للتمرين',
        type: ExerciseType.trueFalse,
        difficulty: difficulty,
        correctAnswer: 'نعم',
        ttsText: 'أهلاً بك في التعلم الصوتي',
      ),
    ];
  }
}
