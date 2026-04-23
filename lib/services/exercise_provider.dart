import 'dart:math';
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
  List<bool> _userResults = [];

  List<Exercise> get exercises => _exercises;
  int get currentIndex => _currentIndex;
  int get score => _score;
  bool get isLoading => _isLoading;
  List<bool> get userResults => _userResults;

  int get scorePercentage => _exercises.isEmpty ? 0 : ((_score / (_exercises.length * 10)) * 100).toInt();

  Exercise? get currentExercise => 
      _currentIndex < _exercises.length ? _exercises[_currentIndex] : null;

  void loadExercises(String skillId, Difficulty difficulty) {
    _isLoading = true;
    notifyListeners();

    // Mock Data Generator
    _exercises = _getMockExercises(skillId, difficulty);
    _currentIndex = 0;
    _score = 0;
    _userResults = [];
    _isLoading = false;
    notifyListeners();
  }

  void submitAnswer(String answer) {
    if (currentExercise == null) return;

    if (answer == currentExercise!.correctAnswer) {
      _score += 10;
      _userResults.add(true);
    } else {
      _userResults.add(false);
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
    if (skillId == 'aud_1') {
      final random = Random();
      
      final pools = [
        // Category 1: Voiced vs Voiceless (الجهر والهمس)
        [
          Exercise(
            id: 'aud_1_1_a',
            skillId: 'aud_1',
            prompt: 'هل لهذا الصوت طنين قوي؟ (مجهور)',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'ز . ز . ز',
          ),
          Exercise(
            id: 'aud_1_1_b',
            skillId: 'aud_1',
            prompt: 'هل تشعر بابتزاز في الحنجرة؟ (مجهور)',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'ب . ب . ب',
          ),
          Exercise(
            id: 'aud_1_1_c',
            skillId: 'aud_1',
            prompt: 'هل هذا الصوت قوي وله رنين؟ (مجهور)',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'د . د . د',
          ),
        ],
        // Category 2: Voiceless (المهموس)
        [
          Exercise(
            id: 'aud_1_2_a',
            skillId: 'aud_1',
            prompt: 'هل تسمع هواءً في هذا الصوت؟ (مهموس)',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'س . س . س',
          ),
          Exercise(
            id: 'aud_1_2_b',
            skillId: 'aud_1',
            prompt: 'هل هذا الصوت رقيق مثل الهواء؟ (مهموس)',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'ف . ف . ف',
          ),
          Exercise(
            id: 'aud_1_2_c',
            skillId: 'aud_1',
            prompt: 'هل يخرج هواء كثير مع هذا الصوت؟ (مهموس)',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'هـ . هـ . هـ',
          ),
        ],
        // Category 3: Stops (الشدة)
        [
          Exercise(
            id: 'aud_1_3_a',
            skillId: 'aud_1',
            prompt: 'اختر الصوت الذي ينقطع فجأة (شديد)',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['س', 'ب', 'ح'],
            correctAnswer: 'ب',
            ttsText: 'س... ب... ح...',
          ),
          Exercise(
            id: 'aud_1_3_b',
            skillId: 'aud_1',
            prompt: 'أي صوت يتوقف فيه النفس تماماً؟ (شديد)',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ل', 'ق', 'ف'],
            correctAnswer: 'ق',
            ttsText: 'ل... ق... ف...',
          ),
          Exercise(
            id: 'aud_1_3_c',
            skillId: 'aud_1',
            prompt: 'ما هو الصوت الذي لا يمكن مطّه؟ (شديد)',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['م', 'ت', 'ر'],
            correctAnswer: 'ت',
            ttsText: 'م... ت... ر...',
          ),
        ],
        // Category 4: Articulation Points (مخارج الحروف)
        [
          Exercise(
            id: 'aud_1_4_a',
            skillId: 'aud_1',
            prompt: 'هل يخرج هذا الصوت من الحلق؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'ح . ح . ح',
          ),
          Exercise(
            id: 'aud_1_4_b',
            skillId: 'aud_1',
            prompt: 'هل تحس بهذا الصوت في أقصى الحلق؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'خ . خ . خ',
          ),
          Exercise(
            id: 'aud_1_4_c',
            skillId: 'aud_1',
            prompt: 'هل هذا صوت حلقي عميق؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'ع . ع . ع',
          ),
        ],
        // Category 5: Lip sounds (الشفتين)
        [
          Exercise(
            id: 'aud_1_5_a',
            skillId: 'aud_1',
            prompt: 'أي صوت يخرج من الشفتين؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ن', 'ل', 'م'],
            correctAnswer: 'م',
            ttsText: 'ن... ل... م...',
          ),
          Exercise(
            id: 'aud_1_5_b',
            skillId: 'aud_1',
            prompt: 'أي صوت نستخدم فيه الشفتين بقوة؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ج', 'ب', 'ك'],
            correctAnswer: 'ب',
            ttsText: 'ج... ب... ك...',
          ),
          Exercise(
            id: 'aud_1_5_c',
            skillId: 'aud_1',
            prompt: 'اختر الصوت الشفوي من القائمة:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['د', 'و', 'س'],
            correctAnswer: 'و',
            ttsText: 'د... و... س...',
          ),
        ],
        // Category 6: Minimal Pairs (الفروق الدقيقة)
        [
          Exercise(
            id: 'aud_1_6_a',
            skillId: 'aud_1',
            prompt: 'هل الكلمتان متطابقتان؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'لا',
            ttsText: 'تاب . طاب',
          ),
          Exercise(
            id: 'aud_1_6_b',
            skillId: 'aud_1',
            prompt: 'هل تسمع نفس الكلمة مرتين؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'لا',
            ttsText: 'سار . صار',
          ),
          Exercise(
            id: 'aud_1_6_c',
            skillId: 'aud_1',
            prompt: 'هل هناك فرق بين الكلمتين؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'نام . عام',
          ),
        ],
      ];

      // Pick one random exercise from each pool
      return pools.map((pool) => pool[random.nextInt(pool.length)]).toList();
    }

    if (skillId == 'aud_2') {
      final random = Random();
      
      final pools = [
        // Category 1: Similar Letters (ب/ت/ث)
        [
          Exercise(
            id: 'aud_2_1_a',
            skillId: 'aud_2',
            prompt: 'أي حرف تسمعه؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ب', 'ت', 'ث'],
            correctAnswer: 'ب',
            ttsText: 'ب . ب . ب',
          ),
          Exercise(
            id: 'aud_2_1_b',
            skillId: 'aud_2',
            prompt: 'اختر الحرف الذي تسمعه الآن:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ب', 'ت', 'ث'],
            correctAnswer: 'ت',
            ttsText: 'ت . ت . ت',
          ),
          Exercise(
            id: 'aud_2_1_c',
            skillId: 'aud_2',
            prompt: 'ما هو الحرف المنطوق؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ب', 'ت', 'ث'],
            correctAnswer: 'ث',
            ttsText: 'ث . ث . ث',
          ),
        ],
        // Category 2: Similar Letters (د/ض/ذ)
        [
          Exercise(
            id: 'aud_2_2_a',
            skillId: 'aud_2',
            prompt: 'ميز الحرف الصحيح:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['د', 'ض', 'ذ'],
            correctAnswer: 'د',
            ttsText: 'د . د . د',
          ),
          Exercise(
            id: 'aud_2_2_b',
            skillId: 'aud_2',
            prompt: 'أي صوت هذا؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['د', 'ض', 'ذ'],
            correctAnswer: 'ض',
            ttsText: 'ض . ض . ض',
          ),
          Exercise(
            id: 'aud_2_2_c',
            skillId: 'aud_2',
            prompt: 'اسمع جيداً واختر الحرف:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['د', 'ض', 'ذ'],
            correctAnswer: 'ذ',
            ttsText: 'ذ . ذ . ذ',
          ),
        ],
        // Category 3: Syllables (با/بو/بي)
        [
          Exercise(
            id: 'aud_2_3_a',
            skillId: 'aud_2',
            prompt: 'أي مقطع سمعت في كلمة (باب)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['با', 'بو', 'بي'],
            correctAnswer: 'با',
            ttsText: 'باب',
          ),
          Exercise(
            id: 'aud_2_3_b',
            skillId: 'aud_2',
            prompt: 'ما هو المقطع الموجود في (بوم)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['با', 'بو', 'بي'],
            correctAnswer: 'بو',
            ttsText: 'بوم',
          ),
          Exercise(
            id: 'aud_2_3_c',
            skillId: 'aud_2',
            prompt: 'أي مقطع سمعت في (كبير)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['با', 'بو', 'بي'],
            correctAnswer: 'بي',
            ttsText: 'كبير',
          ),
        ],
        // Category 4: Syllables (سا/سو/سي)
        [
          Exercise(
            id: 'aud_2_4_a',
            skillId: 'aud_2',
            prompt: 'ميز المقطع في كلمة (ساعة):',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['سا', 'سو', 'سي'],
            correctAnswer: 'سا',
            ttsText: 'ساعة',
          ),
          Exercise(
            id: 'aud_2_4_b',
            skillId: 'aud_2',
            prompt: 'ما هو المقطع في كلمة (سوق)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['سا', 'سو', 'سي'],
            correctAnswer: 'سو',
            ttsText: 'سوق',
          ),
          Exercise(
            id: 'aud_2_4_c',
            skillId: 'aud_2',
            prompt: 'أي مقطع سمعت في (سيرك)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['سا', 'سو', 'سي'],
            correctAnswer: 'سي',
            ttsText: 'سيرك',
          ),
        ],
        // Category 5: Position of 'م'
        [
          Exercise(
            id: 'aud_2_5_a',
            skillId: 'aud_2',
            prompt: 'أين سمعت حرف (م) في كلمة (مكتب)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['أول', 'وسط', 'آخر'],
            correctAnswer: 'أول',
            ttsText: 'مكتب',
          ),
          Exercise(
            id: 'aud_2_5_b',
            skillId: 'aud_2',
            prompt: 'أين يقع حرف (م) في (سمكة)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['أول', 'وسط', 'آخر'],
            correctAnswer: 'وسط',
            ttsText: 'سمكة',
          ),
          Exercise(
            id: 'aud_2_5_c',
            skillId: 'aud_2',
            prompt: 'أين سمعت حرف (م) في كلمة (قلم)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['أول', 'وسط', 'آخر'],
            correctAnswer: 'آخر',
            ttsText: 'قلم',
          ),
        ],
        // Category 6: Position of 'س'
        [
          Exercise(
            id: 'aud_2_6_a',
            skillId: 'aud_2',
            prompt: 'أين سمعت حرف (س) في كلمة (سيارة)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['أول', 'وسط', 'آخر'],
            correctAnswer: 'أول',
            ttsText: 'سيارة',
          ),
          Exercise(
            id: 'aud_2_6_b',
            skillId: 'aud_2',
            prompt: 'أين يقع حرف (س) في (مسجد)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['أول', 'وسط', 'آخر'],
            correctAnswer: 'وسط',
            ttsText: 'مسجد',
          ),
          Exercise(
            id: 'aud_2_6_c',
            skillId: 'aud_2',
            prompt: 'أين سمعت حرف (س) في كلمة (فأس)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['أول', 'وسط', 'آخر'],
            correctAnswer: 'آخر',
            ttsText: 'فأس',
          ),
        ],
      ];

      // Pick one random exercise from each pool
      return pools.map((pool) => pool[random.nextInt(pool.length)]).toList();
    }

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
