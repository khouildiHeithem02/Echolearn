import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/exercise_model.dart';
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

    if (skillId == 'aud_3') {
      final random = Random();
      
      final pools = [
        // Category 1: Identifying Continuous Sound (True/False)
        [
          Exercise(
            id: 'aud_3_1_a',
            skillId: 'aud_3',
            prompt: 'هل هذا الصوت يستمر ولا ينقطع؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'س . س . س',
          ),
          Exercise(
            id: 'aud_3_1_b',
            skillId: 'aud_3',
            prompt: 'هل يمكن مد هذا الصوت لفترة طويلة؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'ش . ش . ش',
          ),
          Exercise(
            id: 'aud_3_1_c',
            skillId: 'aud_3',
            prompt: 'هل تلاحظ أن هذا الصوت متصل ومستمر؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'م . م . م',
          ),
        ],
        // Category 2: Identifying Interrupted Sound (True/False)
        [
          Exercise(
            id: 'aud_3_2_a',
            skillId: 'aud_3',
            prompt: 'هل ينقطع هذا الصوت فجأة؟ (متقطع)',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'ب . ب . ب',
          ),
          Exercise(
            id: 'aud_3_2_b',
            skillId: 'aud_3',
            prompt: 'هل هذا الصوت قصير ويتوقف بسرعة؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'ط . ط . ط',
          ),
          Exercise(
            id: 'aud_3_2_c',
            skillId: 'aud_3',
            prompt: 'هل تحس بانحباس الصوت هنا؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'ق . ق . ق',
          ),
        ],
        // Category 3: Choosing the Continuous Sound (Multiple Choice)
        [
          Exercise(
            id: 'aud_3_3_a',
            skillId: 'aud_3',
            prompt: 'أي من هذه الأصوات يمكن أن يستمر طويلاً؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ب', 'س', 'ت'],
            correctAnswer: 'س',
            ttsText: 'ب... س... ت...',
          ),
          Exercise(
            id: 'aud_3_3_b',
            skillId: 'aud_3',
            prompt: 'اختر الصوت المستمر:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['د', 'ك', 'م'],
            correctAnswer: 'م',
            ttsText: 'د... ك... م...',
          ),
          Exercise(
            id: 'aud_3_3_c',
            skillId: 'aud_3',
            prompt: 'ما هو الصوت الذي لا ينقطع فوراً؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ج', 'ش', 'ق'],
            correctAnswer: 'ش',
            ttsText: 'ج... ش... ق...',
          ),
        ],
        // Category 4: Choosing the Interrupted Sound (Multiple Choice)
        [
          Exercise(
            id: 'aud_3_4_a',
            skillId: 'aud_3',
            prompt: 'أي من هذه الأصوات ينقطع بسرعة (متقطع)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ف', 'ط', 'ل'],
            correctAnswer: 'ط',
            ttsText: 'ف... ط... ل...',
          ),
          Exercise(
            id: 'aud_3_4_b',
            skillId: 'aud_3',
            prompt: 'اختر الصوت المتقطع (الشديد):',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ر', 'ن', 'ب'],
            correctAnswer: 'ب',
            ttsText: 'ر... ن... ب...',
          ),
          Exercise(
            id: 'aud_3_4_c',
            skillId: 'aud_3',
            prompt: 'ما هو الصوت الذي يتوقف فجأة؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ز', 'ح', 'د'],
            correctAnswer: 'د',
            ttsText: 'ز... ح... د...',
          ),
        ],
        // Category 5: Sounds in Words
        [
          Exercise(
            id: 'aud_3_5_a',
            skillId: 'aud_3',
            prompt: 'ما نوع الصوت الأول في كلمة (سيارة)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مستمر', 'متقطع'],
            correctAnswer: 'مستمر',
            ttsText: 'سيارة',
          ),
          Exercise(
            id: 'aud_3_5_b',
            skillId: 'aud_3',
            prompt: 'ما نوع الصوت الأول في كلمة (كتاب)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مستمر', 'متقطع'],
            correctAnswer: 'متقطع',
            ttsText: 'كتاب',
          ),
          Exercise(
            id: 'aud_3_5_c',
            skillId: 'aud_3',
            prompt: 'ما نوع الصوت الأول في كلمة (نور)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مستمر', 'متقطع'],
            correctAnswer: 'مستمر',
            ttsText: 'نور',
          ),
        ],
        // Category 6: Comparisons
        [
          Exercise(
            id: 'aud_3_6_a',
            skillId: 'aud_3',
            prompt: 'استمع: (ف... ت...). أيهما الصوت المتقطع؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ف', 'ت'],
            correctAnswer: 'ت',
            ttsText: 'ف... ت...',
          ),
          Exercise(
            id: 'aud_3_6_b',
            skillId: 'aud_3',
            prompt: 'استمع: (ك... ر...). أيهما الصوت المستمر؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ك', 'ر'],
            correctAnswer: 'ر',
            ttsText: 'ك... ر...',
          ),
          Exercise(
            id: 'aud_3_6_c',
            skillId: 'aud_3',
            prompt: 'استمع: (ش... ج...). أيهما الصوت المتقطع؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ش', 'ج'],
            correctAnswer: 'ج',
            ttsText: 'ش... ج...',
          ),
        ],
      ];

      // Pick one random exercise from each pool
      return pools.map((pool) => pool[random.nextInt(pool.length)]).toList();
    }

    if (skillId == 'aud_4') {
      final random = Random();
      
      final pools = [
        // Category 1: Minimal Pairs (باب/تاب/ناب)
        [
          Exercise(
            id: 'aud_4_1_a',
            skillId: 'aud_4',
            prompt: 'استمع للكلمة واختر ما يطابقها:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['باب', 'تاب', 'ناب'],
            correctAnswer: 'تاب',
            ttsText: 'تاب',
          ),
          Exercise(
            id: 'aud_4_1_b',
            skillId: 'aud_4',
            prompt: 'أي كلمة سمعت للتو؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['باب', 'تاب', 'ناب'],
            correctAnswer: 'باب',
            ttsText: 'باب',
          ),
          Exercise(
            id: 'aud_4_1_c',
            skillId: 'aud_4',
            prompt: 'ما هي الكلمة المنطوقة؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['باب', 'تاب', 'ناب'],
            correctAnswer: 'ناب',
            ttsText: 'ناب',
          ),
        ],
        // Category 2: Minimal Pairs (قلم/علم/ألم)
        [
          Exercise(
            id: 'aud_4_2_a',
            skillId: 'aud_4',
            prompt: 'اختر الكلمة التي سمعتها:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['قلم', 'علم', 'ألم'],
            correctAnswer: 'قلم',
            ttsText: 'قلم',
          ),
          Exercise(
            id: 'aud_4_2_b',
            skillId: 'aud_4',
            prompt: 'ما الكلمة التي قيلت؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['قلم', 'علم', 'ألم'],
            correctAnswer: 'علم',
            ttsText: 'علم',
          ),
          Exercise(
            id: 'aud_4_2_c',
            skillId: 'aud_4',
            prompt: 'استمع جيداً واختر الكلمة:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['قلم', 'علم', 'ألم'],
            correctAnswer: 'ألم',
            ttsText: 'ألم',
          ),
        ],
        // Category 3: Minimal Pairs (تين/طين/سين)
        [
          Exercise(
            id: 'aud_4_3_a',
            skillId: 'aud_4',
            prompt: 'الكلمة المسموعة هي:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['تين', 'طين', 'سين'],
            correctAnswer: 'طين',
            ttsText: 'طين',
          ),
          Exercise(
            id: 'aud_4_3_b',
            skillId: 'aud_4',
            prompt: 'اختر الكلمة التي سمعتها:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['تين', 'طين', 'سين'],
            correctAnswer: 'تين',
            ttsText: 'تين',
          ),
          Exercise(
            id: 'aud_4_3_c',
            skillId: 'aud_4',
            prompt: 'أي من هذه الكلمات تم نطقها؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['تين', 'طين', 'سين'],
            correctAnswer: 'سين',
            ttsText: 'سين',
          ),
        ],
        // Category 4: Same or Different (True/False)
        [
          Exercise(
            id: 'aud_4_4_a',
            skillId: 'aud_4',
            prompt: 'هل الكلمتان اللتان سمعتهما متطابقتان؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'لا',
            ttsText: 'قلم . علم',
          ),
          Exercise(
            id: 'aud_4_4_b',
            skillId: 'aud_4',
            prompt: 'هل نطقت نفس الكلمة مرتين؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'باب . باب',
          ),
          Exercise(
            id: 'aud_4_4_c',
            skillId: 'aud_4',
            prompt: 'هل الكلمتان متشابهتان تماماً؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'لا',
            ttsText: 'تين . طين',
          ),
        ],
        // Category 5: Minimal Pairs - Last letter (فاس/فأر/فاز)
        [
          Exercise(
            id: 'aud_4_5_a',
            skillId: 'aud_4',
            prompt: 'استمع للكلمة واخترها:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['فاس', 'فأر', 'فاز'],
            correctAnswer: 'فاس',
            ttsText: 'فاس',
          ),
          Exercise(
            id: 'aud_4_5_b',
            skillId: 'aud_4',
            prompt: 'أي كلمة سمعت؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['فاس', 'فأر', 'فاز'],
            correctAnswer: 'فاز',
            ttsText: 'فاز',
          ),
          Exercise(
            id: 'aud_4_5_c',
            skillId: 'aud_4',
            prompt: 'ما هي الكلمة الصحيحة؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['فاس', 'فأر', 'فاز'],
            correctAnswer: 'فأر',
            ttsText: 'فأر',
          ),
        ],
        // Category 6: Minimal Pairs - Middle letter (سار/سور/سير)
        [
          Exercise(
            id: 'aud_4_6_a',
            skillId: 'aud_4',
            prompt: 'ما الكلمة التي سمعتها؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['سار', 'سور', 'سير'],
            correctAnswer: 'سور',
            ttsText: 'سور',
          ),
          Exercise(
            id: 'aud_4_6_b',
            skillId: 'aud_4',
            prompt: 'استمع واختر الكلمة المطابقة:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['سار', 'سور', 'سير'],
            correctAnswer: 'سير',
            ttsText: 'سير',
          ),
          Exercise(
            id: 'aud_4_6_c',
            skillId: 'aud_4',
            prompt: 'الكلمة المسموعة هي:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['سار', 'سور', 'سير'],
            correctAnswer: 'سار',
            ttsText: 'سار',
          ),
        ],
      ];

      // Pick one random exercise from each pool
      return pools.map((pool) => pool[random.nextInt(pool.length)]).toList();
    }

    if (skillId == 'aud_5') {
      final random = Random();
      
      final pools = [
        // Category 1: Voweled Letters (Fatha, Damma, Kasra)
        [
          Exercise(
            id: 'aud_5_1_a',
            skillId: 'aud_5',
            prompt: 'أي حرف يطابق الصوت المسموع؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['بَ', 'بُ', 'بِ'],
            correctAnswer: 'بَ',
            ttsText: 'بَ',
          ),
          Exercise(
            id: 'aud_5_1_b',
            skillId: 'aud_5',
            prompt: 'اختر الحرف المطابق للصوت:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['تَ', 'تُ', 'تِ'],
            correctAnswer: 'تُ',
            ttsText: 'تُ',
          ),
          Exercise(
            id: 'aud_5_1_c',
            skillId: 'aud_5',
            prompt: 'استمع جيداً واختر الحرف:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['سَ', 'سُ', 'سِ'],
            correctAnswer: 'سِ',
            ttsText: 'سِ',
          ),
        ],
        // Category 2: Long Vowels (Madd)
        [
          Exercise(
            id: 'aud_5_2_a',
            skillId: 'aud_5',
            prompt: 'ما المقطع المطابق لهذا الصوت؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['بَا', 'بُو', 'بِي'],
            correctAnswer: 'بَا',
            ttsText: 'بَا',
          ),
          Exercise(
            id: 'aud_5_2_b',
            skillId: 'aud_5',
            prompt: 'أي مقطع سمعته للتو؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['سَا', 'سُو', 'سِي'],
            correctAnswer: 'سُو',
            ttsText: 'سُو',
          ),
          Exercise(
            id: 'aud_5_2_c',
            skillId: 'aud_5',
            prompt: 'استمع واختر المقطع الصحيح:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مَا', 'مُو', 'مِي'],
            correctAnswer: 'مِي',
            ttsText: 'مِي',
          ),
        ],
        // Category 3: Sound to Word (Short vs Long)
        [
          Exercise(
            id: 'aud_5_3_a',
            skillId: 'aud_5',
            prompt: 'أي كلمة سمعتها؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['قَلَمٌ', 'قَالَمٌ'],
            correctAnswer: 'قَلَمٌ',
            ttsText: 'قَلَمٌ',
          ),
          Exercise(
            id: 'aud_5_3_b',
            skillId: 'aud_5',
            prompt: 'الكلمة المطابقة للصوت هي:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['نَامَ', 'نَمَ'],
            correctAnswer: 'نَامَ',
            ttsText: 'نَامَ',
          ),
          Exercise(
            id: 'aud_5_3_c',
            skillId: 'aud_5',
            prompt: 'اختر ما سمعته:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['فِيلٌ', 'فِلٌ'],
            correctAnswer: 'فِيلٌ',
            ttsText: 'فِيلٌ',
          ),
        ],
        // Category 4: Sounding Word to Starting Letter
        [
          Exercise(
            id: 'aud_5_4_a',
            skillId: 'aud_5',
            prompt: 'الكلمة التي سمعتها تبدأ بحرف:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['س', 'ص', 'ث'],
            correctAnswer: 'ص',
            ttsText: 'صُورَةٌ',
          ),
          Exercise(
            id: 'aud_5_4_b',
            skillId: 'aud_5',
            prompt: 'ما الحرف الأول للكلمة المسموعة؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ت', 'ط', 'د'],
            correctAnswer: 'ط',
            ttsText: 'طَيَّارَةٌ',
          ),
          Exercise(
            id: 'aud_5_4_c',
            skillId: 'aud_5',
            prompt: 'الحرف الأول للصوت المسموع هو:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ز', 'ذ', 'ظ'],
            correctAnswer: 'ظ',
            ttsText: 'ظِلٌّ',
          ),
        ],
        // Category 5: True/False Word Match
        [
          Exercise(
            id: 'aud_5_5_a',
            skillId: 'aud_5',
            prompt: 'هل يتطابق هذا الصوت مع الصورة؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'كَلْبٌ',
            imageAsset: 'assets/images/dog.png',
          ),
          Exercise(
            id: 'aud_5_5_b',
            skillId: 'aud_5',
            prompt: 'هل هذا هو صوت الحيوان في الصورة؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'لا',
            ttsText: 'بَطَّةٌ',
            imageAsset: 'assets/images/cat.png',
          ),
          Exercise(
            id: 'aud_5_5_c',
            skillId: 'aud_5',
            prompt: 'هل الصوت المسموع يطابق الصورة؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'عُصْفُورٌ',
            imageAsset: 'assets/images/bird.png',
          ),
        ],
        // Category 6: True/False Letter Match
        [
          Exercise(
            id: 'aud_5_6_a',
            skillId: 'aud_5',
            prompt: 'هل الصورة تعبر عن الصوت المسموع؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'لا',
            ttsText: 'كَلْبٌ',
            imageAsset: 'assets/images/bird.png',
          ),
          Exercise(
            id: 'aud_5_6_b',
            skillId: 'aud_5',
            prompt: 'هل يتطابق الصوت مع الصورة؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'قِطَّةٌ',
            imageAsset: 'assets/images/cat.png',
          ),
          Exercise(
            id: 'aud_5_6_c',
            skillId: 'aud_5',
            prompt: 'استمع وانظر، هل هما متطابقان؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'لا',
            ttsText: 'عُصْفُورٌ',
            imageAsset: 'assets/images/dog.png',
          ),
        ],
      ];

      // Pick one random exercise from each pool
      return pools.map((pool) => pool[random.nextInt(pool.length)]).toList();
    }

    if (skillId == 'aud_6') {
      final random = Random();
      
      final pools = [
        // Category 1: Question vs Statement (جملة استفهامية vs خبرية)
        [
          Exercise(
            id: 'aud_6_1_a',
            skillId: 'aud_6',
            prompt: 'هل هذه جملة (خبرية) أم (استفهامية)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['خبرية', 'استفهامية'],
            correctAnswer: 'استفهامية',
            ttsText: 'هَلْ ذَهَبْتَ إِلَى المَدْرَسَةِ؟',
          ),
          Exercise(
            id: 'aud_6_1_b',
            skillId: 'aud_6',
            prompt: 'ما نوع هذه الجملة؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['خبرية', 'استفهامية'],
            correctAnswer: 'خبرية',
            ttsText: 'أَنَا ذَهَبْتُ إِلَى المَدْرَسَةِ اليَوْمَ.',
          ),
          Exercise(
            id: 'aud_6_1_c',
            skillId: 'aud_6',
            prompt: 'استمع جيداً، هل هذا سؤال؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['سؤال', 'جملة عادية'],
            correctAnswer: 'سؤال',
            ttsText: 'مَتَى سَنَأْكُلُ الغَدَاءَ؟',
          ),
        ],
        // Category 2: Exclamatory vs Normal (جملة تعجبية vs خبرية)
        [
          Exercise(
            id: 'aud_6_2_a',
            skillId: 'aud_6',
            prompt: 'هل هذه جملة (تعجبية) أم (خبرية)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['تعجبية', 'خبرية'],
            correctAnswer: 'تعجبية',
            ttsText: 'مَا أَجْمَلَ السَّمَاءَ اليَوْمَ!',
          ),
          Exercise(
            id: 'aud_6_2_b',
            skillId: 'aud_6',
            prompt: 'ما نوع هذا التعبير الصوتي؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['تعجب', 'إخبار'],
            correctAnswer: 'تعجب',
            ttsText: 'يَا لَهُ مِنْ طَعَامٍ لَذِيذٍ!',
          ),
          Exercise(
            id: 'aud_6_2_c',
            skillId: 'aud_6',
            prompt: 'هل الجملة تدل على (التعجب) أم (وصف عادي)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['تعجب', 'وصف عادي'],
            correctAnswer: 'وصف عادي',
            ttsText: 'السَّمَاءُ لَوْنُهَا أَزْرَقُ.',
          ),
        ],
        // Category 3: Emotion in Tone (الفرح vs الحزن)
        [
          Exercise(
            id: 'aud_6_3_a',
            skillId: 'aud_6',
            prompt: 'ما هي المشاعر التي تسمعها في نبرة الصوت؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['فرح', 'حزن', 'غضب'],
            correctAnswer: 'فرح',
            ttsText: 'رَائِع! لَقَدْ نَجَحْتُ فِي الاخْتِبَارِ!',
          ),
          Exercise(
            id: 'aud_6_3_b',
            skillId: 'aud_6',
            prompt: 'هل يبدو المتحدث (حزيناً) أم (سعيداً)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['سعيد', 'حزين'],
            correctAnswer: 'حزين',
            ttsText: 'أَنَا أَشْعُرُ بِالوَحْدَةِ بَعْدَ سَفَرِ صَدِيقِي.',
          ),
          Exercise(
            id: 'aud_6_3_c',
            skillId: 'aud_6',
            prompt: 'ميز نبرة الصوت:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['هادئة', 'غاضبة'],
            correctAnswer: 'غاضبة',
            ttsText: 'لا تَفْعَلْ ذَلِكَ مَرَّةً أُخْرَى!',
          ),
        ],
        // Category 4: Emphasis (التوكيد)
        [
          Exercise(
            id: 'aud_6_4_a',
            skillId: 'aud_6',
            prompt: 'هل الجملة تحتوي على نبرة توكيد قوية؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'إِنَّ الصِّدْقَ خُلُقٌ عَظِيمٌ.',
          ),
          Exercise(
            id: 'aud_6_4_b',
            skillId: 'aud_6',
            prompt: 'هل هذه الجملة تدل على (الشك) أم (التأكيد)؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['تأكيد', 'شك'],
            correctAnswer: 'تأكيد',
            ttsText: 'قَدْ أَفْلَحَ المُؤْمِنُونَ.',
          ),
        ],
        // Category 5: Rhythm (الإيقاع)
        [
          Exercise(
            id: 'aud_6_5_a',
            skillId: 'aud_6',
            prompt: 'هل إيقاع الكلمات متناسق وموزون؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'كِتَابِي كِتَابِي .. هُوَ لِي خَيْرُ صَحَابِ',
          ),
          Exercise(
            id: 'aud_6_5_b',
            skillId: 'aud_6',
            prompt: 'هل هذا إيقاع سريع أم بطيء؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['سريع', 'بطيء'],
            correctAnswer: 'بطيء',
            ttsText: 'فِي .. هُدُوءِ .. اللَّيْلِ .. نَنَامُ .. بِأَمَانٍ.',
          ),
        ],
        // Category 6: Mixed Tone Discrimination
        [
          Exercise(
            id: 'aud_6_6_a',
            skillId: 'aud_6',
            prompt: 'هل هذه الجملة تطلب معلومة (سؤال)؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'كَمْ السَّاعَةُ الآن؟',
          ),
          Exercise(
            id: 'aud_6_6_b',
            skillId: 'aud_6',
            prompt: 'هل هذه جملة إخبارية بسيطة؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'أَنَا أُحِبُّ القِرَاءَةَ.',
          ),
        ],
      ];

      // Pick one random exercise from each pool
      return pools.map((pool) => pool[random.nextInt(pool.length)]).toList();
    }

    if (skillId == 'aud_7') {
      final random = Random();
      
      final pools = [
        // Category 1: 3-Number Sequence (تسلسل أرقام ثلاثي)
        [
          Exercise(
            id: 'aud_7_1_a',
            skillId: 'aud_7',
            prompt: 'ما هو ترتيب الأرقام الذي سمعته؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['← 1 - 3 - 5', '← 5 - 3 - 1', '← 3 - 5 - 1'],
            correctAnswer: '← 1 - 3 - 5',
            ttsText: 'وَاحِد .. ثَلَاثَة .. خَمْسَة',
          ),
          Exercise(
            id: 'aud_7_1_b',
            skillId: 'aud_7',
            prompt: 'اختر التسلسل الصحيح للأرقام:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['← 4 - 2 - 7', '← 7 - 2 - 4', '← 2 - 4 - 7'],
            correctAnswer: '← 4 - 2 - 7',
            ttsText: 'أَرْبَعَة .. اثْنَان .. سَبْعَة',
          ),
        ],
        // Category 2: 4-Number Sequence (تسلسل أرقام رباعي)
        [
          Exercise(
            id: 'aud_7_2_a',
            skillId: 'aud_7',
            prompt: 'أعد ترتيب الأرقام التي سمعتها:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['← 7 - 5 - 3 - 1', '← 1 - 3 - 5 - 7', '← 3 - 5 - 7 - 1'],
            correctAnswer: '← 7 - 5 - 3 - 1',
            ttsText: 'سَبْعَة .. خَمْسَة .. ثَلَاثَة .. وَاحِد',
          ),
          Exercise(
            id: 'aud_7_2_b',
            skillId: 'aud_7',
            prompt: 'ما هي الأرقام بالترتيب؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['← 2 - 8 - 6 - 4', '← 4 - 6 - 8 - 2', '← 8 - 2 - 4 - 6'],
            correctAnswer: '← 2 - 8 - 6 - 4',
            ttsText: 'اثْنَان .. ثَمَانِيَة .. سِتَّة .. أَرْبَعَة',
          ),
        ],
        // Category 3: 2-Word Sequence (تسلسل كلمات ثنائي)
        [
          Exercise(
            id: 'aud_7_3_a',
            skillId: 'aud_7',
            prompt: 'ما هما الكلمتان اللتان سمعتهما بالترتيب؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['← تَعَلَّم - عَلِمَ', '← عَلِمَ - تَعَلَّم', '← تَعَلَّم - تَعَلَّم'],
            correctAnswer: '← تَعَلَّم - عَلِمَ',
            ttsText: 'تَعَلَّم .. عَلِمَ',
          ),
          Exercise(
            id: 'aud_7_3_b',
            skillId: 'aud_7',
            prompt: 'اختر الكلمات بالترتيب الصحيح:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['← قَلَم - كِتَاب', '← كِتَاب - قَلَم', '← كِتَاب - كِتَاب'],
            correctAnswer: '← قَلَم - كِتَاب',
            ttsText: 'قَلَم .. كِتَاب',
          ),
        ],
        // Category 4: 3-Word Sequence (تسلسل كلمات ثلاثي)
        [
          Exercise(
            id: 'aud_7_4_a',
            skillId: 'aud_7',
            prompt: 'ما هو ترتيب الكلمات الثلاث؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['← شَمْس - قَمَر - نُجُوم', '← نُجُوم - قَمَر - شَمْس', '← قَمَر - نُجُوم - شَمْس'],
            correctAnswer: '← شَمْس - قَمَر - نُجُوم',
            ttsText: 'شَمْس .. قَمَر .. نُجُوم',
          ),
          Exercise(
            id: 'aud_7_4_b',
            skillId: 'aud_7',
            prompt: 'اختر ترتيب الفواكه الذي سمعته:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['← تُفَّاح - مَوْز - عِنَب', '← مَوْز - تُفَّاح - عِنَب', '← عِنَب - مَوْز - تُفَّاح'],
            correctAnswer: '← تُفَّاح - مَوْز - عِنَب',
            ttsText: 'تُفَّاح .. مَوْز .. عِنَب',
          ),
        ],
        // Category 5: 2-Letter Sequence (تسلسل حروف ثنائي)
        [
          Exercise(
            id: 'aud_7_5_a',
            skillId: 'aud_7',
            prompt: 'ما هما الحرفان بالترتيب؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['← أ - ب', '← ب - أ', '← ت - أ'],
            correctAnswer: '← أ - ب',
            ttsText: 'أَلِف .. بَاء',
          ),
          Exercise(
            id: 'aud_7_5_b',
            skillId: 'aud_7',
            prompt: 'اسمع جيداً واختر الحروف بالترتيب:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['← س - ص', '← ص - س', '← س - ش'],
            correctAnswer: '← س - ص',
            ttsText: 'سِين .. صَاد',
          ),
        ],
        // Category 6: Reverse Memory (2 items) (ذاكرة عكسية - عنصرين)
        [
          Exercise(
            id: 'aud_7_6_a',
            skillId: 'aud_7',
            prompt: 'ما هو "عكس" ترتيب الأرقام التي سمعتها؟ (من الآخر للأول)',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['1 - 9 →', '9 - 1 →', '1 - 1 →'],
            correctAnswer: '1 - 9 →',
            ttsText: 'وَاحِد .. تِسْعَة',
          ),
          Exercise(
            id: 'aud_7_6_b',
            skillId: 'aud_7',
            prompt: 'أعد الكلمات بالعكس:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['جَبَل - بَحْر →', 'بَحْر - جَبَل →', 'جَبَل - جَبَل →'],
            correctAnswer: 'جَبَل - بَحْر →',
            ttsText: 'جَبَل .. بَحْر',
          ),
        ],
      ];

      // Pick one random exercise from each pool
      return pools.map((pool) => pool[random.nextInt(pool.length)]).toList();
    }

    if (skillId == 'aud_8') {
      final random = Random();
      
      final pools = [
        // Category 1: Basic Words - Animals
        [
          Exercise(
            id: 'aud_8_1_a',
            skillId: 'aud_8',
            prompt: 'قل كلمة: كَلْب',
            type: ExerciseType.speak,
            difficulty: difficulty,
            correctAnswer: 'كلب',
            ttsText: 'كَلْب',
          ),
          Exercise(
            id: 'aud_8_1_b',
            skillId: 'aud_8',
            prompt: 'قل كلمة: قِطَّة',
            type: ExerciseType.speak,
            difficulty: difficulty,
            correctAnswer: 'قطة',
            ttsText: 'قِطَّة',
          ),
        ],
        // Category 2: Basic Words - Fruits
        [
          Exercise(
            id: 'aud_8_2_a',
            skillId: 'aud_8',
            prompt: 'انطق بوضوح: تُفَّاحَة',
            type: ExerciseType.speak,
            difficulty: difficulty,
            correctAnswer: 'تفاحة',
            ttsText: 'تُفَّاحَة',
          ),
          Exercise(
            id: 'aud_8_2_b',
            skillId: 'aud_8',
            prompt: 'انطق بوضوح: مَوْزَة',
            type: ExerciseType.speak,
            difficulty: difficulty,
            correctAnswer: 'موزة',
            ttsText: 'مَوْزَة',
          ),
        ],
        // Category 3: School Items
        [
          Exercise(
            id: 'aud_8_3_a',
            skillId: 'aud_8',
            prompt: 'قل: قَلَم',
            type: ExerciseType.speak,
            difficulty: difficulty,
            correctAnswer: 'قلم',
            ttsText: 'قَلَم',
          ),
          Exercise(
            id: 'aud_8_3_b',
            skillId: 'aud_8',
            prompt: 'قل: كِتَاب',
            type: ExerciseType.speak,
            difficulty: difficulty,
            correctAnswer: 'كتاب',
            ttsText: 'كِتَاب',
          ),
        ],
        // Category 4: Family
        [
          Exercise(
            id: 'aud_8_4_a',
            skillId: 'aud_8',
            prompt: 'انطق كلمة: بَابَا',
            type: ExerciseType.speak,
            difficulty: difficulty,
            correctAnswer: 'بابا',
            ttsText: 'بَابَا',
          ),
          Exercise(
            id: 'aud_8_4_b',
            skillId: 'aud_8',
            prompt: 'انطق كلمة: مَامَا',
            type: ExerciseType.speak,
            difficulty: difficulty,
            correctAnswer: 'ماما',
            ttsText: 'مَامَا',
          ),
        ],
        // Category 5: Nature
        [
          Exercise(
            id: 'aud_8_5_a',
            skillId: 'aud_8',
            prompt: 'قل: شَمْس',
            type: ExerciseType.speak,
            difficulty: difficulty,
            correctAnswer: 'شمس',
            ttsText: 'شَمْس',
          ),
          Exercise(
            id: 'aud_8_5_b',
            skillId: 'aud_8',
            prompt: 'قل: قَمَر',
            type: ExerciseType.speak,
            difficulty: difficulty,
            correctAnswer: 'قمر',
            ttsText: 'قَمَر',
          ),
        ],
      ];

      // Pick one random exercise from each pool
      return pools.map((pool) => pool[random.nextInt(pool.length)]).toList();
    }

    if (skillId == 'aud_9') {
      final random = Random();
      
      final pools = [
        // Category 1: Animals - Dog (صوت حقيقي)
        [
          Exercise(
            id: 'aud_9_1_a',
            skillId: 'aud_9',
            prompt: 'اسمع جيداً... ما هذا الحيوان؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['قطة', 'كلب', 'حصان'],
            correctAnswer: 'كلب',
            ttsText: 'هاو هاو',
            audioAsset: 'audio/dog.ogg',
          ),
          Exercise(
            id: 'aud_9_1_b',
            skillId: 'aud_9',
            prompt: 'هذا الصوت يعود لـ:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['قطة', 'أسد', 'كلب'],
            correctAnswer: 'كلب',
            ttsText: 'هاو هاو',
            audioAsset: 'audio/dog.ogg',
          ),
        ],
        // Category 2: Birds (صوت حقيقي)
        [
          Exercise(
            id: 'aud_9_2_a',
            skillId: 'aud_9',
            prompt: 'اسمع هذا الصوت... من يغرد هكذا؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['دجاجة', 'عصفور', 'بطة'],
            correctAnswer: 'عصفور',
            ttsText: 'زقزقة الطيور',
            audioAsset: 'audio/bird.ogg',
          ),
          Exercise(
            id: 'aud_9_2_b',
            skillId: 'aud_9',
            prompt: 'هذا صوت طائر من نوع:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['غراب', 'حمامة', 'عصفور'],
            correctAnswer: 'عصفور',
            ttsText: 'زقزقة الطيور',
            audioAsset: 'audio/bird.ogg',
          ),
        ],
        // Category 3: Transportation - Train (صوت حقيقي)
        [
          Exercise(
            id: 'aud_9_3_a',
            skillId: 'aud_9',
            prompt: 'ما هي وسيلة النقل صاحبة هذا الصوت؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['سيارة', 'طائرة', 'قطار'],
            correctAnswer: 'قطار',
            ttsText: 'صوت قطار',
            audioAsset: 'audio/train.ogg',
          ),
          Exercise(
            id: 'aud_9_3_b',
            skillId: 'aud_9',
            prompt: 'اسمع واختر وسيلة النقل الصحيحة:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['دراجة نارية', 'قطار', 'سفينة'],
            correctAnswer: 'قطار',
            ttsText: 'صوت قطار',
            audioAsset: 'audio/train.ogg',
          ),
        ],
        // Category 4: Nature - Rain (صوت حقيقي)
        [
          Exercise(
            id: 'aud_9_4_a',
            skillId: 'aud_9',
            prompt: 'ما هذا الصوت الطبيعي؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['رياح', 'مطر', 'رعد'],
            correctAnswer: 'مطر',
            ttsText: 'صوت مطر',
            audioAsset: 'audio/rain.ogg',
          ),
          Exercise(
            id: 'aud_9_4_b',
            skillId: 'aud_9',
            prompt: 'هذا صوت من أصوات الطبيعة، اختر الصحيح:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['حريق', 'مطر', 'عاصفة رملية'],
            correctAnswer: 'مطر',
            ttsText: 'صوت مطر',
            audioAsset: 'audio/rain.ogg',
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