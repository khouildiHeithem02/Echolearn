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
        // Category 1: Voiced Sounds (المجهور - اهتزاز الأوتار)
        [
          Exercise(
            id: 'aud_1_1_a',
            skillId: 'aud_1',
            prompt: 'هل تشعر بابتزاز (طنين) قوي في الحنجرة مع هذا الصوت؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'بااااء',
          ),
          Exercise(
            id: 'aud_1_1_b',
            skillId: 'aud_1',
            prompt: 'هل هذا الصوت مجهور وله رنين قوي؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'داااال',
          ),
          Exercise(
            id: 'aud_1_1_c',
            skillId: 'aud_1',
            prompt: 'اسمع جيداً... هل هذا الصوت يحدث اهتزازاً؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'زااااي',
          ),
        ],
        // Category 2: Voiceless Sounds (المهموس - تدفق الهواء)
        [
          Exercise(
            id: 'aud_1_2_a',
            skillId: 'aud_1',
            prompt: 'هل تسمع هواءً كثيراً يخرج مع هذا الصوت؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'سسسسسس',
          ),
          Exercise(
            id: 'aud_1_2_b',
            skillId: 'aud_1',
            prompt: 'هل هذا الصوت رقيق مثل الهمس؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'فففففف',
          ),
          Exercise(
            id: 'aud_1_2_c',
            skillId: 'aud_1',
            prompt: 'هل يخرج الهواء دون اهتزاز في الحنجرة؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'هااااء',
          ),
        ],
        // Category 3: Intensity/Stops (الشدة - انقطاع الصوت)
        [
          Exercise(
            id: 'aud_1_3_a',
            skillId: 'aud_1',
            prompt: 'اختر الصوت الذي ينقطع فجأة ولا يمكن مده (شديد):',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['س', 'بَ', 'ر'],
            correctAnswer: 'بَ',
            ttsText: 'س... بَ... ر...',
          ),
          Exercise(
            id: 'aud_1_3_b',
            skillId: 'aud_1',
            prompt: 'أي صوت يتوقف فيه النفس تماماً عند النطق؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ل', 'قَ', 'ف'],
            correctAnswer: 'قَ',
            ttsText: 'ل... قَ... ف...',
          ),
          Exercise(
            id: 'aud_1_3_c',
            skillId: 'aud_1',
            prompt: 'ما هو الصوت القوي الذي ينحبس خلفه الهواء؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['م', 'تَ', 'و'],
            correctAnswer: 'تَ',
            ttsText: 'م... تَ... و...',
          ),
        ],
        // Category 4: Flow/Resonance (الرخاوة والتردد)
        [
          Exercise(
            id: 'aud_1_4_a',
            skillId: 'aud_1',
            prompt: 'أي صوت يمكننا مده والاستمرار في نطقة؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['طَ', 'شششش', 'كَ'],
            correctAnswer: 'شششش',
            ttsText: 'طَ... شششش... كَ...',
          ),
          Exercise(
            id: 'aud_1_4_b',
            skillId: 'aud_1',
            prompt: 'اختر الصوت الذي يجري فيه النفس بسهولة:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['حححح', 'دَ', 'بَ'],
            correctAnswer: 'حححح',
            ttsText: 'حححح... دَ... بَ...',
          ),
          Exercise(
            id: 'aud_1_4_c',
            skillId: 'aud_1',
            prompt: 'ما هو الصوت الذي له تردد أو جريان؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['غغغغ', 'تَ', 'قَ'],
            correctAnswer: 'غغغغ',
            ttsText: 'غغغغ... تَ... قَ...',
          ),
        ],
        // Category 5: Articulation 1 (الشفتان والحلق)
        [
          Exercise(
            id: 'aud_1_5_a',
            skillId: 'aud_1',
            prompt: 'أي صوت يخرج باستخدام الشفتين فقط؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ن', 'ل', 'م'],
            correctAnswer: 'م',
            ttsText: 'ن... ل... م...',
          ),
          Exercise(
            id: 'aud_1_5_b',
            skillId: 'aud_1',
            prompt: 'أي صوت يخرج من أعمق نقطة في الحلق؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ب', 'س', 'ء'],
            correctAnswer: 'ء',
            ttsText: 'ب... س... ء...',
          ),
          Exercise(
            id: 'aud_1_5_c',
            skillId: 'aud_1',
            prompt: 'اختر الصوت الذي نستخدم فيه الشفتين بقوة:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ح', 'ب', 'خ'],
            correctAnswer: 'ب',
            ttsText: 'ح... ب... خ...',
          ),
        ],
        // Category 6: Articulation 2 (اللسان والأسنان)
        [
          Exercise(
            id: 'aud_1_6_a',
            skillId: 'aud_1',
            prompt: 'أي صوت نستخدم فيه طرف اللسان مع الأسنان؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ث', 'ك', 'ع'],
            correctAnswer: 'ث',
            ttsText: 'ث... ك... ع...',
          ),
          Exercise(
            id: 'aud_1_6_b',
            skillId: 'aud_1',
            prompt: 'اختر الصوت الذي يخرج من طرف اللسان:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['د', 'خ', 'و'],
            correctAnswer: 'د',
            ttsText: 'د... خ... و...',
          ),
          Exercise(
            id: 'aud_1_6_c',
            skillId: 'aud_1',
            prompt: 'ما هو الصوت الذي يلامس فيه اللسان سقف الفم؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ل', 'ف', 'هـ'],
            correctAnswer: 'ل',
            ttsText: 'ل... ف... هـ...',
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
        // Category 1: Continuous vs Interrupted (Letters/Sounds)
        [
          Exercise(
            id: 'aud_3_1_a',
            skillId: 'aud_3',
            prompt: 'استمع جيداً... هل هذا الصوت مستمر أم متقطع؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مستمر\n━━━━', 'متقطع\n- - - -'],
            correctAnswer: 'مستمر\n━━━━',
            ttsText: 'بااااء',
          ),
          Exercise(
            id: 'aud_3_1_b',
            skillId: 'aud_3',
            prompt: 'ما نوع هذا الصوت؟ هل ينقطع بسرعة؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مستمر\n━━━━', 'متقطع\n- - - -'],
            correctAnswer: 'متقطع\n- - - -',
            ttsText: 'تَ',
          ),
          Exercise(
            id: 'aud_3_1_c',
            skillId: 'aud_3',
            prompt: 'هل هذا الصوت طويل ومتصل أم قصير ومتقطع؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مستمر\n━━━━', 'متقطع\n- - - -'],
            correctAnswer: 'متقطع\n- - - -',
            ttsText: 'ثَ',
          ),
        ],
        // Category 2: Continuous vs Interrupted (More Letters/Sounds)
        [
          Exercise(
            id: 'aud_3_2_a',
            skillId: 'aud_3',
            prompt: 'اسمع هذا الصوت... كيف يبدو؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مستمر\n━━━━', 'متقطع\n- - - -'],
            correctAnswer: 'متقطع\n- - - -',
            ttsText: 'بَ',
          ),
          Exercise(
            id: 'aud_3_2_b',
            skillId: 'aud_3',
            prompt: 'هل هذا الصوت يتدفق كالهواء أم يتوقف؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مستمر\n━━━━', 'متقطع\n- - - -'],
            correctAnswer: 'مستمر\n━━━━',
            ttsText: 'وااااو',
          ),
          Exercise(
            id: 'aud_3_2_c',
            skillId: 'aud_3',
            prompt: 'هل تحس بانقطاع الصوت هنا؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مستمر\n━━━━', 'متقطع\n- - - -'],
            correctAnswer: 'مستمر\n━━━━',
            ttsText: 'يااااء',
          ),
        ],
        // Category 3: One vs Two Syllables (Vowels/Letters)
        [
          Exercise(
            id: 'aud_3_3_a',
            skillId: 'aud_3',
            prompt: 'كم مقطعاً مستمراً سمعت؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مقطع واحد\n━━━━', 'مقطعين\n━━  ━━'],
            correctAnswer: 'مقطع واحد\n━━━━',
            ttsText: 'بااااء',
          ),
          Exercise(
            id: 'aud_3_3_b',
            skillId: 'aud_3',
            prompt: 'هل انقطع الصوت ثم عاد؟ (مقطعين)',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مقطع واحد\n━━━━', 'مقطعين\n━━  ━━'],
            correctAnswer: 'مقطعين\n━━  ━━',
            ttsText: 'واو . واو',
          ),
          Exercise(
            id: 'aud_3_3_c',
            skillId: 'aud_3',
            prompt: 'عد المقاطع الصوتية المستمرة:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مقطع واحد\n━━━━', 'مقطعين\n━━  ━━'],
            correctAnswer: 'مقطع واحد\n━━━━',
            ttsText: 'وااااو',
          ),
        ],
        // Category 4: Two vs Three Syllables (Vowels/Letters)
        [
          Exercise(
            id: 'aud_3_4_a',
            skillId: 'aud_3',
            prompt: 'ركز جيداً... كم مرة سمعت هذا الصوت المستمر؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مقطعين\n━━  ━━', 'ثلاث مقاطع\n━━  ━━  ━━'],
            correctAnswer: 'ثلاث مقاطع\n━━  ━━  ━━',
            ttsText: 'باء . باء . باء',
          ),
          Exercise(
            id: 'aud_3_4_b',
            skillId: 'aud_3',
            prompt: 'استمع وعد المقاطع:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مقطعين\n━━  ━━', 'ثلاث مقاطع\n━━  ━━  ━━'],
            correctAnswer: 'مقطعين\n━━  ━━',
            ttsText: 'واو . واو',
          ),
          Exercise(
            id: 'aud_3_4_c',
            skillId: 'aud_3',
            prompt: 'هل سمعت الصوت ثلاث مرات؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مقطعين\n━━  ━━', 'ثلاث مقاطع\n━━  ━━  ━━'],
            correctAnswer: 'ثلاث مقاطع\n━━  ━━  ━━',
            ttsText: 'ياء . ياء . ياء',
          ),
        ],
        // Category 5: One vs Two Syllables (Words)
        [
          Exercise(
            id: 'aud_3_5_a',
            skillId: 'aud_3',
            prompt: 'استمع للكلمة، كم مقطعاً فيها؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مقطع واحد\n━━━━', 'مقطعين\n━━  ━━'],
            correctAnswer: 'مقطع واحد\n━━━━',
            ttsText: 'فَأس',
          ),
          Exercise(
            id: 'aud_3_5_b',
            skillId: 'aud_3',
            prompt: 'هل هذه الكلمة من مقطع أم مقطعين؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مقطع واحد\n━━━━', 'مقطعين\n━━  ━━'],
            correctAnswer: 'مقطعين\n━━  ━━',
            ttsText: 'كِ . تَاب',
          ),
          Exercise(
            id: 'aud_3_5_c',
            skillId: 'aud_3',
            prompt: 'هل قيلت الكلمة مرة واحدة أم على دفعتين؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مقطع واحد\n━━━━', 'مقطعين\n━━  ━━'],
            correctAnswer: 'مقطع واحد\n━━━━',
            ttsText: 'مَاء',
          ),
        ],
        // Category 6: Two vs Three Syllables (Words)
        [
          Exercise(
            id: 'aud_3_6_a',
            skillId: 'aud_3',
            prompt: 'استمع للكلمة، هل تتكون من مقطعين أم ثلاثة؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مقطعين\n━━  ━━', 'ثلاث مقاطع\n━━  ━━  ━━'],
            correctAnswer: 'ثلاث مقاطع\n━━  ━━  ━━',
            ttsText: 'سَيـ . يَا . رَة',
          ),
          Exercise(
            id: 'aud_3_6_b',
            skillId: 'aud_3',
            prompt: 'كم دفعة أو مقطعاً في هذه الكلمة؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مقطعين\n━━  ━━', 'ثلاث مقاطع\n━━  ━━  ━━'],
            correctAnswer: 'مقطعين\n━━  ━━',
            ttsText: 'شَ . جَر',
          ),
          Exercise(
            id: 'aud_3_6_c',
            skillId: 'aud_3',
            prompt: 'ركز على تقطيع الكلمة:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مقطعين\n━━  ━━', 'ثلاث مقاطع\n━━  ━━  ━━'],
            correctAnswer: 'ثلاث مقاطع\n━━  ━━  ━━',
            ttsText: 'طَا . وِ . لَة',
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
        // Category 5: Animal Sound-Image Match (Using Real Assets)
        [
          Exercise(
            id: 'aud_5_5_a',
            skillId: 'aud_5',
            prompt: 'هل هذا الصوت يطابق الحيوان في الصورة؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'اسمع صوت الكلب، هل هو كلب؟',
            audioAsset: 'audio/dog.mp3',
            imageAsset: 'assets/images/dog.png',
          ),
          Exercise(
            id: 'aud_5_5_b',
            skillId: 'aud_5',
            prompt: 'هل هذا هو صوت القطة الموضح في الصورة؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'لا',
            ttsText: 'اسمع هذا الصوت، هل هو لقطة؟',
            audioAsset: 'audio/Duck quack.mp3',
            imageAsset: 'assets/images/cat.png',
          ),
          Exercise(
            id: 'aud_5_5_c',
            skillId: 'aud_5',
            prompt: 'هل يتوافق صوت العصفور مع صورته؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'زقزقة العصفور، هل تطابق الصورة؟',
            audioAsset: 'audio/bird.mp3',
            imageAsset: 'assets/images/bird.png',
          ),
        ],
        // Category 6: Advanced Identification (Animals & Objects)
        [
          Exercise(
            id: 'aud_5_6_a',
            skillId: 'aud_5',
            prompt: 'انظر للصورة، هل سمعت صوت البقرة أم البطة؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['بقرة', 'بطة', 'قطة'],
            correctAnswer: 'بقرة',
            ttsText: 'اسمع جيداً، أي حيوان هذا؟',
            audioAsset: 'audio/cow.mp3',
            imageAsset: 'assets/images/cow.png',
          ),
          Exercise(
            id: 'aud_5_6_b',
            skillId: 'aud_5',
            prompt: 'ما هو الحيوان الذي أصدر هذا الصوت؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['خروف', 'حصان', 'دجاجة'],
            correctAnswer: 'خروف',
            ttsText: 'ما هذا الصوت؟',
            audioAsset: 'audio/sheep.mp3',
            imageAsset: 'assets/images/dog.png', 
          ),
          Exercise(
            id: 'aud_5_6_c',
            skillId: 'aud_5',
            prompt: 'هل الصوت المسموع هو للسيارة أم للقطار؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['سيارة', 'قطار', 'دراجة'],
            correctAnswer: 'قطار',
            ttsText: 'اسمع وسيلة النقل هذه:',
            audioAsset: 'audio/toy train.mp3',
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
          Exercise(
            id: 'aud_6_4_c',
            skillId: 'aud_6',
            prompt: 'هل سمعت قوة وتأكيد في النطق؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'وَاللهِ لَقَدْ اجْتَهَدْتُ كَثِيراً!',
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
          Exercise(
            id: 'aud_6_5_c',
            skillId: 'aud_6',
            prompt: 'هل تلاحظ وجود نغمة موسيقية في الكلام؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'نعم',
            ttsText: 'مَدْرَسَتِي الحَبِيبَة .. مَنْبَعُ العِلْمِ القَرِيبَة',
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
          Exercise(
            id: 'aud_6_6_c',
            skillId: 'aud_6',
            prompt: 'هل يبدو المتحدث غاضباً؟',
            type: ExerciseType.trueFalse,
            difficulty: difficulty,
            correctAnswer: 'لا',
            ttsText: 'مَرْحَبًا بِكُمْ جَمِيعًا فِي بَيْتِنَا.',
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
          Exercise(
            id: 'aud_7_1_c',
            skillId: 'aud_7',
            prompt: 'عد الأرقام بالترتيب الذي سمعته:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['← 9 - 6 - 2', '← 2 - 6 - 9', '← 6 - 9 - 2'],
            correctAnswer: '← 9 - 6 - 2',
            ttsText: 'تِسْعَة .. سِتَّة .. اثْنَان',
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
          Exercise(
            id: 'aud_7_2_c',
            skillId: 'aud_7',
            prompt: 'اختر التسلسل الرباعي الصحيح:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['← 3 - 9 - 1 - 5', '← 5 - 1 - 9 - 3', '← 1 - 3 - 5 - 9'],
            correctAnswer: '← 3 - 9 - 1 - 5',
            ttsText: 'ثَلَاثَة .. تِسْعَة .. وَاحِد .. خَمْسَة',
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
          Exercise(
            id: 'aud_7_3_c',
            skillId: 'aud_7',
            prompt: 'ما هما الكلمتان اللتان نطقتهما؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['← بَاب - نَافِذَة', '← نَافِذَة - بَاب', '← بَاب - بَاب'],
            correctAnswer: '← بَاب - نَافِذَة',
            ttsText: 'بَاب .. نَافِذَة',
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
          Exercise(
            id: 'aud_7_4_c',
            skillId: 'aud_7',
            prompt: 'رتب الكلمات التالية كما سمعتها:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['← أَسَد - نِمْر - فِيل', '← فِيل - نِمْر - أَسَد', '← نِمْر - أَسَد - فِيل'],
            correctAnswer: '← أَسَد - نِمْر - فِيل',
            ttsText: 'أَسَد .. نِمْر .. فِيل',
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
          Exercise(
            id: 'aud_7_5_c',
            skillId: 'aud_7',
            prompt: 'أي حرفين سمعتهما بالترتيب؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['← ك - ل', '← ل - ك', '← ك - م'],
            correctAnswer: '← ك - ل',
            ttsText: 'كَاف .. لَام',
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
            options: ['← 9 - 1', '← 1 - 9', '← 1 - 1'],
            correctAnswer: '← 9 - 1',
            ttsText: 'وَاحِد .. تِسْعَة',
          ),
          Exercise(
            id: 'aud_7_6_b',
            skillId: 'aud_7',
            prompt: 'أعد الكلمات بالعكس:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['← بَحْر - جَبَل', '← جَبَل - بَحْر', '← جَبَل - جَبَل'],
            correctAnswer: '← بَحْر - جَبَل',
            ttsText: 'جَبَل .. بَحْر',
          ),
          Exercise(
            id: 'aud_7_6_c',
            skillId: 'aud_7',
            prompt: 'ما هو الترتيب المعكوس لهذه الحروف؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['← ن - م', '← م - ن', '← م - م'],
            correctAnswer: '← ن - م',
            ttsText: 'مِيم .. نُون',
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
          Exercise(
            id: 'aud_8_1_c',
            skillId: 'aud_8',
            prompt: 'انطق كلمة: أَسَد',
            type: ExerciseType.speak,
            difficulty: difficulty,
            correctAnswer: 'اسد',
            ttsText: 'أَسَد',
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
          Exercise(
            id: 'aud_8_2_c',
            skillId: 'aud_8',
            prompt: 'قل بوضوح: عِنَب',
            type: ExerciseType.speak,
            difficulty: difficulty,
            correctAnswer: 'عنب',
            ttsText: 'عِنَب',
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
          Exercise(
            id: 'aud_8_3_c',
            skillId: 'aud_8',
            prompt: 'انطق: مِحْفَظَة',
            type: ExerciseType.speak,
            difficulty: difficulty,
            correctAnswer: 'محفظة',
            ttsText: 'مِحْفَظَة',
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
          Exercise(
            id: 'aud_8_4_c',
            skillId: 'aud_8',
            prompt: 'قل بوضوح: جَدُّو',
            type: ExerciseType.speak,
            difficulty: difficulty,
            correctAnswer: 'جدو',
            ttsText: 'جَدُّو',
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
          Exercise(
            id: 'aud_8_5_c',
            skillId: 'aud_8',
            prompt: 'انطق: سَمَاء',
            type: ExerciseType.speak,
            difficulty: difficulty,
            correctAnswer: 'سماء',
            ttsText: 'سَمَاء',
          ),
        ],
        // Category 6: Household Items
        [
          Exercise(
            id: 'aud_8_6_a',
            skillId: 'aud_8',
            prompt: 'انطق: كُرْسِي',
            type: ExerciseType.speak,
            difficulty: difficulty,
            correctAnswer: 'كرسي',
            ttsText: 'كُرْسِي',
          ),
          Exercise(
            id: 'aud_8_6_b',
            skillId: 'aud_8',
            prompt: 'قل: طَاوِلَة',
            type: ExerciseType.speak,
            difficulty: difficulty,
            correctAnswer: 'طاولة',
            ttsText: 'طَاوِلَة',
          ),
          Exercise(
            id: 'aud_8_6_c',
            skillId: 'aud_8',
            prompt: 'قل بوضوح: بَاب',
            type: ExerciseType.speak,
            difficulty: difficulty,
            correctAnswer: 'باب',
            ttsText: 'بَاب',
          ),
        ],
      ];

      // Pick one random exercise from each pool
      return pools.map((pool) => pool[random.nextInt(pool.length)]).toList();
    }

    if (skillId == 'aud_9') {
      final random = Random();
      
      final pools = [
        // Category 1: Animals (Gentle)
        [
          Exercise(
            id: 'aud_9_1_a',
            skillId: 'aud_9',
            prompt: 'يا بطل، اسمع هذا الصوت اللطيف... من هو هذا الحيوان الأليف؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['القطة الصغيرة', 'الكلب الصغير', 'البقرة'],
            correctAnswer: 'القطة الصغيرة',
            ttsText: 'مياو مياو... أنا قطة صغيرة ولطيفة',
            audioAsset: 'audio/cat.mp3',
            isGentle: true,
          ),
          Exercise(
            id: 'aud_9_1_b',
            skillId: 'aud_9',
            prompt: 'هذا الصوت الجميل يعود لصديقنا:',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['القطة', 'الأسد', 'الكلب الصغير'],
            correctAnswer: 'الكلب الصغير',
            ttsText: 'هوهو هوهو... أنا كلب صغير أطير من الفرح',
            audioAsset: 'audio/dog.mp3',
            isGentle: true,
          ),
          Exercise(
            id: 'aud_9_1_c',
            skillId: 'aud_9',
            prompt: 'اسمع صوت المزرعة الهادئ... من هذا الحيوان؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['البقرة', 'الحصان', 'الدجاجة'],
            correctAnswer: 'البقرة',
            ttsText: 'مووو مووو... أنا البقرة الحلوب أعطيكم الحليب',
            audioAsset: 'audio/cow.mp3',
            isGentle: true,
          ),
        ],
        // Category 2: Birds (Gentle)
        [
          Exercise(
            id: 'aud_9_2_a',
            skillId: 'aud_9',
            prompt: 'صوت جميل في الصباح... من يغني هكذا؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['الدجاجة', 'العصفور', 'البطة'],
            correctAnswer: 'العصفور',
            ttsText: 'زقزق زقزق... أنا العصفور أطير في السماء الزرقاء',
            audioAsset: 'audio/bird.mp3',
            isGentle: true,
          ),
          Exercise(
            id: 'aud_9_2_b',
            skillId: 'aud_9',
            prompt: 'من يغني بصوت عذب؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['الغراب', 'العصفور', 'الحمامة'],
            correctAnswer: 'العصفور',
            ttsText: 'أنا العصفور الجميل، أحب الغناء',
            audioAsset: 'audio/bird.mp3',
            isGentle: true,
          ),
          Exercise(
            id: 'aud_9_2_c',
            skillId: 'aud_9',
            prompt: 'ما هذا الصوت الرقيق؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['الببغاء', 'العصفور', 'النعامة'],
            correctAnswer: 'العصفور',
            ttsText: 'استمع للحن العصفور الشجي',
            audioAsset: 'audio/bird.mp3',
            isGentle: true,
          ),
        ],
        // Category 3: Transportation (Gentle)
        [
          Exercise(
            id: 'aud_9_3_a',
            skillId: 'aud_9',
            prompt: 'اسمع صوت هذا المحرك الصغير... ما هي وسيلة النقل هذه؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['السيارة', 'القطار', 'الطائرة'],
            correctAnswer: 'السيارة',
            ttsText: 'بيب بيب... أنا سيارة صغيرة حمراء أتجول في المدينة',
            audioAsset: 'audio/car.mp3',
            isGentle: true,
          ),
          Exercise(
            id: 'aud_9_3_b',
            skillId: 'aud_9',
            prompt: 'وسيلة نقل تمشي على السكة الطويلة... هل عرفتها؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['الدراجة', 'السفينة', 'القطار'],
            correctAnswer: 'القطار',
            ttsText: 'توت توت... تشك تشك تشك... أنا القطار السريع',
            audioAsset: 'audio/toy train.mp3',
            isGentle: true,
          ),
          Exercise(
            id: 'aud_9_3_c',
            skillId: 'aud_9',
            prompt: 'صوت جرس لطيف، هل هو صوت دراجتي؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['دراجة هوائية', 'سيارة إطفاء', 'قطار'],
            correctAnswer: 'دراجة هوائية',
            ttsText: 'ترن ترن... أفسحوا الطريق لدراجتي الجميلة',
            audioAsset: 'audio/bike bell.mp3',
            isGentle: true,
          ),
        ],
        // Category 4: Nature (Gentle)
        [
          Exercise(
            id: 'aud_9_4_a',
            skillId: 'aud_9',
            prompt: 'صوت هادئ ومريح... هل هو صوت الطبيعة؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['رياح قوية', 'قطرات المطر', 'رعد'],
            correctAnswer: 'قطرات المطر',
            ttsText: 'تك تك تك... قطرات المطر الخفيفة تسقي الزهور',
            audioAsset: 'audio/rain.mp3',
            isGentle: true,
          ),
          Exercise(
            id: 'aud_9_4_b',
            skillId: 'aud_9',
            prompt: 'اسمع صوت تدفق الماء الجميل، هل هذا نهر؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['أمواج البحر', 'رعد', 'جدول ماء صغير'],
            correctAnswer: 'جدول ماء صغير',
            ttsText: 'صوت جريان الماء العذب في جدول صغير بين الأشجار',
            audioAsset: 'audio/Water stream.mp3',
            isGentle: true,
          ),
          Exercise(
            id: 'aud_9_4_c',
            skillId: 'aud_9',
            prompt: 'صوت قوي يحرك أوراق الشجر... ما هذا الصوت؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['الرياح', 'رعد', 'مطر'],
            correctAnswer: 'الرياح',
            ttsText: 'فيييووو... أنا الرياح الباردة أطير الأوراق',
            audioAsset: 'audio/wind.mp3',
            isGentle: true,
          ),
        ],
        // Category 5: Farm Sounds
        [
          Exercise(
            id: 'aud_9_5_a',
            skillId: 'aud_9',
            prompt: 'ما هو هذا الحيوان الذي يثغو؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['خروف', 'ماعز', 'حمار'],
            correctAnswer: 'خروف',
            ttsText: 'مااااا مااااا... أنا الخروف الصغير',
            audioAsset: 'audio/sheep.mp3',
            isGentle: true,
          ),
          Exercise(
            id: 'aud_9_5_b',
            skillId: 'aud_9',
            prompt: 'صوت نهيق... هل عرفته؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['حمار', 'حصان', 'جمل'],
            correctAnswer: 'حمار',
            ttsText: 'أنا الحمار الصبور، أساعد الفلاح',
            audioAsset: 'audio/donkey.mp3',
            isGentle: true,
          ),
          Exercise(
            id: 'aud_9_5_c',
            skillId: 'aud_9',
            prompt: 'صهيل جميل... لمن هذا الصوت؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['حصان', 'بغل', 'غزال'],
            correctAnswer: 'حصان',
            ttsText: 'أنا الحصان القوي، أجري بسرعة',
            audioAsset: 'audio/horse.mp3',
            isGentle: true,
          ),
        ],
        // Category 6: Household Sounds (Gentle)
        [
          Exercise(
            id: 'aud_9_6_a',
            skillId: 'aud_9',
            prompt: 'صوت تكتكة... ماذا تكون؟',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['ساعة', 'مطرقة', 'منبه'],
            correctAnswer: 'ساعة',
            ttsText: 'تيك توك تيك توك... أنا الساعة أنظم الوقت',
            audioAsset: 'audio/clock ticking.mp3',
            isGentle: true,
          ),
          Exercise(
            id: 'aud_9_6_b',
            skillId: 'aud_9',
            prompt: 'صوت طرق على الخشب...',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['طرق باب', 'نقر عصفور', 'صوت خطى'],
            correctAnswer: 'طرق باب',
            ttsText: 'طق طق طق... من يطرق الباب؟',
            audioAsset: 'audio/knocking door.mp3',
            isGentle: true,
          ),
          Exercise(
            id: 'aud_9_6_c',
            skillId: 'aud_9',
            prompt: 'صوت مكنسة كهربائية هادئ...',
            type: ExerciseType.multipleChoice,
            difficulty: difficulty,
            options: ['مكنسة', 'مجفف شعر', 'خلاط'],
            correctAnswer: 'مكنسة',
            ttsText: 'وززززززز... أنا المكنسة أنظف الأرض',
            audioAsset: 'audio/vacuum cleaner.mp3',
            isGentle: true,
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