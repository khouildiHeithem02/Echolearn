import 'dart:math';
import 'package:echolearn/models/exercise_model.dart';
import 'package:flutter/material.dart';
import '../models/skill_category.dart';
import '../models/user_progress.dart';
import 'database_helper.dart';

class ExerciseProvider with ChangeNotifier {
  List<Exercise> _exercises = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isCompleted = false;
  bool _isLoading = false;
  List<bool> _userResults = [];

  List<Exercise> get exercises => _exercises;
  int get currentIndex => _currentIndex;
  int get score => _score;
  bool get isCompleted => _isCompleted;
  bool get isLoading => _isLoading;
  List<bool> get userResults => _userResults;
  int get scorePercentage => _exercises.isEmpty ? 0 : (_score / _exercises.length * 100).round();
  Exercise? get currentExercise => (_currentIndex < _exercises.length) ? _exercises[_currentIndex] : null;

  void loadExercises(String skillId, Difficulty difficulty) {
    _isLoading = true;
    notifyListeners();
    
    _exercises = _getMockExercises(skillId, difficulty);
    _currentIndex = 0;
    _score = 0;
    _isCompleted = false;
    _userResults = [];
    _isLoading = false;
    notifyListeners();
  }

  void submitAnswer(String answer) {
    if (_isCompleted) return;

    final correct = _exercises[_currentIndex].correctAnswer;
    
    String normalize(String s) {
      return s.trim()
          .replaceAll(RegExp(r'[^\u0621-\u064A0-9]'), '')
          .replaceAll('أ', 'ا')
          .replaceAll('إ', 'ا')
          .replaceAll('آ', 'ا')
          .replaceAll('ة', 'ه')
          .replaceAll('ى', 'ي');
    }

    bool isCorrect = normalize(answer) == normalize(correct);
    _userResults.add(isCorrect);
    if (isCorrect) {
      _score++;
    }

    _currentIndex++;
    if (_currentIndex >= _exercises.length) {
      _isCompleted = true;
      _saveProgress();
    }
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    final finalScore = (_score / _exercises.length * 100).round();
    final progress = UserProgress(
      skillId: _exercises.first.skillId,
      difficulty: _exercises.first.difficulty,
      score: finalScore,
      isCompleted: true,
    );
    
    await DatabaseHelper.instance.saveProgress(progress);
  }

  List<Exercise> _getMockExercises(String skillId, Difficulty difficulty) {
    final random = Random();

    // Helper to create 10 pools of 3 exercises each
    List<Exercise> createStage(String id, List<List<Exercise>> sourcePools) {
      return sourcePools.map((pool) => pool[random.nextInt(pool.length)]).toList();
    }

    if (skillId == 'aud_1') {
      final pools = [
        [
          Exercise(id: 'aud_1_1_a', skillId: 'aud_1', prompt: 'هل في هزة قوية في رقبتك؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'بااااء'),
          Exercise(id: 'aud_1_1_b', skillId: 'aud_1', prompt: 'هل رقبتك تهتز الآن؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'داااااد'),
          Exercise(id: 'aud_1_1_c', skillId: 'aud_1', prompt: 'هل الصوت قوي جداً؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'ماااااام'),
        ],
        [
          Exercise(id: 'aud_1_2_a', skillId: 'aud_1', prompt: 'هل في هواء كثير يخرج من فمك؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'سسسسسس'),
          Exercise(id: 'aud_1_2_b', skillId: 'aud_1', prompt: 'هل هذا صوت مثل الثعبان؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'شششششش'),
          Exercise(id: 'aud_1_2_c', skillId: 'aud_1', prompt: 'هل تشعر بهواء بارد؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'فففففف'),
        ],
        [
          Exercise(id: 'aud_1_3_a', skillId: 'aud_1', prompt: 'اختر الصوت الذي ينقطع فجأة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['س', 'بَ', 'ر'], correctAnswer: 'بَ', ttsText: 'س... بَ... ر...'),
          Exercise(id: 'aud_1_3_b', skillId: 'aud_1', prompt: 'أي صوت يتوقف بسرعة؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ك', 'ط', 'م'], correctAnswer: 'ط', ttsText: 'ك... ط... م...'),
          Exercise(id: 'aud_1_3_c', skillId: 'aud_1', prompt: 'ميز الصوت القصير والمفاجئ:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ت', 'ل', 'ن'], correctAnswer: 'ت', ttsText: 'ت... ل... ن...'),
        ],
        [
          Exercise(id: 'aud_1_4_a', skillId: 'aud_1', prompt: 'أي صوت يمكننا مده؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['طَ', 'شششش', 'كَ'], correctAnswer: 'شششش', ttsText: 'طَ... شششش... كَ...'),
          Exercise(id: 'aud_1_4_b', skillId: 'aud_1', prompt: 'اختر الصوت الطويل جداً:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ززززز', 'ب', 'د'], correctAnswer: 'ززززز', ttsText: 'ززززز... ب... د...'),
          Exercise(id: 'aud_1_4_c', skillId: 'aud_1', prompt: 'أي واحد صوته طويل؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['وووو', 'ق', 'ج'], correctAnswer: 'وووو', ttsText: 'وووو... ق... ج...'),
        ],
        [
          Exercise(id: 'aud_1_5_a', skillId: 'aud_1', prompt: 'أي صوت يخرج باستخدام الشفتين؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ن', 'ل', 'م'], correctAnswer: 'م', ttsText: 'ن... ل... م...'),
          Exercise(id: 'aud_1_5_b', skillId: 'aud_1', prompt: 'ميز صوت الشفتين:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ب', 'س', 'ك'], correctAnswer: 'ب', ttsText: 'ب... س... ك...'),
          Exercise(id: 'aud_1_5_c', skillId: 'aud_1', prompt: 'أي حرف نغلق فيه فمنا؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ف', 'م', 'ل'], correctAnswer: 'م', ttsText: 'ف... م... ل...'),
        ],
        [
          Exercise(id: 'aud_1_6_a', skillId: 'aud_1', prompt: 'أي صوت نستخدم فيه طرف اللسان؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ث', 'ك', 'ع'], correctAnswer: 'ث', ttsText: 'ث... ك... ع...'),
          Exercise(id: 'aud_1_6_b', skillId: 'aud_1', prompt: 'اختر صوت اللسان:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ل', 'م', 'ب'], correctAnswer: 'ل', ttsText: 'ل... م... ب...'),
          Exercise(id: 'aud_1_6_c', skillId: 'aud_1', prompt: 'أي حرف يلمس فيه لسانك أسنانك؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ت', 'هـ', 'غ'], correctAnswer: 'ت', ttsText: 'ت... هـ... غ...'),
        ],
        [
          Exercise(id: 'aud_1_7_a', skillId: 'aud_1', prompt: 'هذا الصوت قوي وواضح؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'أنا هناااااااا'),
          Exercise(id: 'aud_1_7_b', skillId: 'aud_1', prompt: 'هل الصوت مرتفع؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'افتح البااااااب'),
          Exercise(id: 'aud_1_7_c', skillId: 'aud_1', prompt: 'هل تسمعني بوضوح؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'يا بطللللللل'),
        ],
        [
          Exercise(id: 'aud_1_8_a', skillId: 'aud_1', prompt: 'هذا همس خفيف... سمعته؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'أنا أحبك', isGentle: true),
          Exercise(id: 'aud_1_8_b', skillId: 'aud_1', prompt: 'هل هذا صوت هادئ؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'تصبح على خير', isGentle: true),
          Exercise(id: 'aud_1_8_c', skillId: 'aud_1', prompt: 'هل تسمع الهمس؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'يا شاطر', isGentle: true),
        ],
        [
          Exercise(id: 'aud_1_9_a', skillId: 'aud_1', prompt: 'هذا صوت حاد مثل العصفور؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'توي توي توي'),
          Exercise(id: 'aud_1_9_b', skillId: 'aud_1', prompt: 'هل الصوت رفيع جداً؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'بي بي بي'),
          Exercise(id: 'aud_1_9_c', skillId: 'aud_1', prompt: 'هل هذا صوت نحيف؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'كي كي كي'),
        ],
        [
          Exercise(id: 'aud_1_10_a', skillId: 'aud_1', prompt: 'هذا صوت عميق؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'اوووووووه'),
          Exercise(id: 'aud_1_10_b', skillId: 'aud_1', prompt: 'هل الصوت غليظ؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'هوووووووم'),
          Exercise(id: 'aud_1_10_c', skillId: 'aud_1', prompt: 'هل هذا صوت ضخم؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'بوم بوم بوم'),
        ],
      ];
      return createStage(skillId, pools);
    }

    if (skillId == 'aud_2') {
      final pools = [
        [
          Exercise(id: 'aud_2_1_a', skillId: 'aud_2', prompt: 'وين حرف الـ (ب)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ب', 'ت', 'ث'], correctAnswer: 'ب', ttsText: 'ب . ب . ب'),
          Exercise(id: 'aud_2_1_b', skillId: 'aud_2', prompt: 'ميز حرف الـ (ب):', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ب', 'ن', 'ي'], correctAnswer: 'ب', ttsText: 'ب . ب . ب'),
          Exercise(id: 'aud_2_1_c', skillId: 'aud_2', prompt: 'اختر (ب) من فضلك:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ب', 'ل', 'ر'], correctAnswer: 'ب', ttsText: 'ب . ب . ب'),
        ],
        [
          Exercise(id: 'aud_2_2_a', skillId: 'aud_2', prompt: 'ميز الحرف الصحيح:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['د', 'ض', 'ذ'], correctAnswer: 'د', ttsText: 'د . د . د'),
          Exercise(id: 'aud_2_2_b', skillId: 'aud_2', prompt: 'وين حرف الـ (د)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['د', 'ت', 'ط'], correctAnswer: 'د', ttsText: 'د . د . د'),
          Exercise(id: 'aud_2_2_c', skillId: 'aud_2', prompt: 'اختر (د) يا بطل:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['د', 'ر', 'ز'], correctAnswer: 'د', ttsText: 'د . د . د'),
        ],
        [
          Exercise(id: 'aud_2_3_a', skillId: 'aud_2', prompt: 'أي مقطع سمعت في (باب)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['با', 'بو', 'بي'], correctAnswer: 'با', ttsText: 'باب'),
          Exercise(id: 'aud_2_3_b', skillId: 'aud_2', prompt: 'ميز مقطع (با) في الكلمة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['با', 'سا', 'ما'], correctAnswer: 'با', ttsText: 'باسم'),
          Exercise(id: 'aud_2_3_c', skillId: 'aud_2', prompt: 'شو أول مقطع في (بابا)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['با', 'تا', 'نا'], correctAnswer: 'با', ttsText: 'بابا'),
        ],
        [
          Exercise(id: 'aud_2_4_a', skillId: 'aud_2', prompt: 'ميز المقطع في (ساعة):', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['سا', 'سو', 'سي'], correctAnswer: 'سا', ttsText: 'ساعة'),
          Exercise(id: 'aud_2_4_b', skillId: 'aud_2', prompt: 'وين مقطع (سا)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['سا', 'شا', 'صا'], correctAnswer: 'سا', ttsText: 'سالم'),
          Exercise(id: 'aud_2_4_c', skillId: 'aud_2', prompt: 'اختر المقطع الصحيح لـ (ساري):', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['سا', 'لا', 'كا'], correctAnswer: 'سا', ttsText: 'ساري'),
        ],
        [
          Exercise(id: 'aud_2_5_a', skillId: 'aud_2', prompt: 'أين حرف (م) في (مكتب)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['أول', 'وسط', 'آخر'], correctAnswer: 'أول', ttsText: 'مكتب'),
          Exercise(id: 'aud_2_5_b', skillId: 'aud_2', prompt: 'وين مكان (م) في (ملح)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['أول', 'وسط', 'آخر'], correctAnswer: 'أول', ttsText: 'ملح'),
          Exercise(id: 'aud_2_5_c', skillId: 'aud_2', prompt: 'حرف (م) في (موز) بأي مكان؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['أول', 'وسط', 'آخر'], correctAnswer: 'أول', ttsText: 'موز'),
        ],
        [
          Exercise(id: 'aud_2_6_a', skillId: 'aud_2', prompt: 'أين حرف (س) في (سيارة)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['أول', 'وسط', 'آخر'], correctAnswer: 'أول', ttsText: 'سيارة'),
          Exercise(id: 'aud_2_6_b', skillId: 'aud_2', prompt: 'وين مكان (س) في (سمك)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['أول', 'وسط', 'آخر'], correctAnswer: 'أول', ttsText: 'سمك'),
          Exercise(id: 'aud_2_6_c', skillId: 'aud_2', prompt: 'حرف (س) في (سوق) وين؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['أول', 'وسط', 'آخر'], correctAnswer: 'أول', ttsText: 'سوق'),
        ],
        [
          Exercise(id: 'aud_2_7_a', skillId: 'aud_2', prompt: 'هل هذا صوت طويل (مَد)؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'باااااا'),
          Exercise(id: 'aud_2_7_b', skillId: 'aud_2', prompt: 'هل الصوت ممدود؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'سوووووو'),
          Exercise(id: 'aud_2_7_c', skillId: 'aud_2', prompt: 'هل هذا مَد بالألف؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'ماااااا'),
        ],
        [
          Exercise(id: 'aud_2_8_a', skillId: 'aud_2', prompt: 'وين حرف الـ (ل)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ل', 'ر', 'ن'], correctAnswer: 'ل', ttsText: 'ل . ل . ل'),
          Exercise(id: 'aud_2_8_b', skillId: 'aud_2', prompt: 'ميز حرف الـ (ل):', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ل', 'ك', 'ف'], correctAnswer: 'ل', ttsText: 'ل . ل . ل'),
          Exercise(id: 'aud_2_8_c', skillId: 'aud_2', prompt: 'اختر (ل) يا شاطر:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ل', 'ع', 'غ'], correctAnswer: 'ل', ttsText: 'ل . ل . ل'),
        ],
        [
          Exercise(id: 'aud_2_9_a', skillId: 'aud_2', prompt: 'أي حركة سمعت (فَتْحة)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['بَ', 'بُ', 'بِ'], correctAnswer: 'بَ', ttsText: 'بَ'),
          Exercise(id: 'aud_2_9_b', skillId: 'aud_2', prompt: 'وين الفتحة؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['سَ', 'سُ', 'سِ'], correctAnswer: 'سَ', ttsText: 'سَ'),
          Exercise(id: 'aud_2_9_c', skillId: 'aud_2', prompt: 'اختر صوت الفتحة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['مَ', 'مُ', 'مِ'], correctAnswer: 'مَ', ttsText: 'مَ'),
        ],
        [
          Exercise(id: 'aud_2_10_a', skillId: 'aud_2', prompt: 'بأي حرف تبدأ (تفاحة)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ت', 'ب', 'ث'], correctAnswer: 'ت', ttsText: 'تفاحة'),
          Exercise(id: 'aud_2_10_b', skillId: 'aud_2', prompt: 'وين حرف البداية في (تمر)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ت', 'د', 'ن'], correctAnswer: 'ت', ttsText: 'تمر'),
          Exercise(id: 'aud_2_10_c', skillId: 'aud_2', prompt: 'اختر أول حرف في (تلفاز):', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ت', 'ك', 'ط'], correctAnswer: 'ت', ttsText: 'تلفاز'),
        ],
      ];
      return createStage(skillId, pools);
    }

    if (skillId == 'aud_3') {
      final pools = [
        [
          Exercise(id: 'aud_3_1_a', skillId: 'aud_3', prompt: 'كم مقطع سمعت في كلمة (بَاب)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['1', '2', '3'], correctAnswer: '1', ttsText: 'بَاب'),
          Exercise(id: 'aud_3_1_b', skillId: 'aud_3', prompt: 'مقطع واحد ولا اثنين في (فيل)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['1', '2', '3'], correctAnswer: '1', ttsText: 'فيل'),
          Exercise(id: 'aud_3_1_c', skillId: 'aud_3', prompt: 'كم مقطع في (توت)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['1', '2', '3'], correctAnswer: '1', ttsText: 'توت'),
        ],
        [
          Exercise(id: 'aud_3_2_a', skillId: 'aud_3', prompt: 'كم مقطع سمعت في كلمة (مكتبة)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['2', '3', '4'], correctAnswer: '3', ttsText: 'مكتبة'),
          Exercise(id: 'aud_3_2_b', skillId: 'aud_3', prompt: 'عد المقاطع في (مدرسة):', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['2', '3', '4'], correctAnswer: '3', ttsText: 'مدرسة'),
          Exercise(id: 'aud_3_2_c', skillId: 'aud_3', prompt: 'كم مقطع في (سيارة)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['2', '3', '4'], correctAnswer: '3', ttsText: 'سيارة'),
        ],
        [
          Exercise(id: 'aud_3_3_a', skillId: 'aud_3', prompt: 'أي كلمة هي الأقصر؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['أنا', 'مدرسة', 'تلفاز'], correctAnswer: 'أنا', ttsText: 'أنا ... مدرسة ... تلفاز'),
          Exercise(id: 'aud_3_3_b', skillId: 'aud_3', prompt: 'وين الكلمة القصيرة؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['هو', 'كمبيوتر', 'برتقالة'], correctAnswer: 'هو', ttsText: 'هو ... كمبيوتر ... برتقالة'),
          Exercise(id: 'aud_3_3_c', skillId: 'aud_3', prompt: 'اختر أقصر كلمة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['لا', 'حقيبة', 'طائرة'], correctAnswer: 'لا', ttsText: 'لا ... حقيبة ... طائرة'),
        ],
        [
          Exercise(id: 'aud_3_4_a', skillId: 'aud_3', prompt: 'أي كلمة هي الأطول؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['باب', 'قلم', 'برتقالة'], correctAnswer: 'برتقالة', ttsText: 'باب ... قلم ... برتقالة'),
          Exercise(id: 'aud_3_4_b', skillId: 'aud_3', prompt: 'وين الكلمة الطويلة؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['بيت', 'شمس', 'مستشفى'], correctAnswer: 'مستشفى', ttsText: 'بيت ... شمس ... مستشفى'),
          Exercise(id: 'aud_3_4_c', skillId: 'aud_3', prompt: 'اختر أطول كلمة سمعتها:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['يد', 'عين', 'استقلال'], correctAnswer: 'استقلال', ttsText: 'يد ... عين ... استقلال'),
        ],
        [
          Exercise(id: 'aud_3_5_a', skillId: 'aud_3', prompt: 'هل الكلمتان (كتاب) و (كتاب) متشابهتان؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'كتاب ... كتاب'),
          Exercise(id: 'aud_3_5_b', skillId: 'aud_3', prompt: 'هل هما نفس الكلمة (قلم .. قلم)؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'قلم ... قلم'),
          Exercise(id: 'aud_3_5_c', skillId: 'aud_3', prompt: 'متطابقتان (باب .. باب)؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'باب ... باب'),
        ],
        [
          Exercise(id: 'aud_3_6_a', skillId: 'aud_3', prompt: 'هل الكلمتان (شمس) و (قمر) متشابهتان؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'لا', ttsText: 'شمس ... قمر'),
          Exercise(id: 'aud_3_6_b', skillId: 'aud_3', prompt: 'مختلفتان (بنت .. ولد)؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'لا', ttsText: 'بنت ... ولد'),
          Exercise(id: 'aud_3_6_c', skillId: 'aud_3', prompt: 'هل هما نفس الشيء (أسد .. نمر)؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'لا', ttsText: 'أسد ... نمر'),
        ],
        [
          Exercise(id: 'aud_3_7_a', skillId: 'aud_3', prompt: 'ميز الكلمة المختلفة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['قطة', 'قطة', 'كلب'], correctAnswer: 'كلب', ttsText: 'قطة .. قطة .. كلب'),
          Exercise(id: 'aud_3_7_b', skillId: 'aud_3', prompt: 'وين الكلمة الغريبة؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['موز', 'تفاح', 'موز'], correctAnswer: 'تفاح', ttsText: 'موز .. تفاح .. موز'),
          Exercise(id: 'aud_3_7_c', skillId: 'aud_3', prompt: 'اختر المختلفة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['أحمر', 'أحمر', 'أخضر'], correctAnswer: 'أخضر', ttsText: 'أحمر .. أحمر .. أخضر'),
        ],
        [
          Exercise(id: 'aud_3_8_a', skillId: 'aud_3', prompt: 'أي كلمة تبدأ بنفس الصوت؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['بحر - باب', 'بحر - تمر'], correctAnswer: 'بحر - باب', ttsText: 'بحر - باب - تمر'),
          Exercise(id: 'aud_3_8_b', skillId: 'aud_3', prompt: 'مين يبدأ مثل (ساعة)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['سمك - شمس', 'سمك - رمل'], correctAnswer: 'سمك - شمس', ttsText: 'سمك - شمس - رمل'),
          Exercise(id: 'aud_3_8_c', skillId: 'aud_3', prompt: 'اختر الكلمات المتشابهة في البداية:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['قلم - قمر', 'قلم - علم'], correctAnswer: 'قلم - قمر', ttsText: 'قلم - قمر - علم'),
        ],
        [
          Exercise(id: 'aud_3_9_a', skillId: 'aud_3', prompt: 'هل تنتهي (قلم) و (علم) بنفس الصوت؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'قلم ... علم'),
          Exercise(id: 'aud_3_9_b', skillId: 'aud_3', prompt: 'نفس النهاية (بحر .. نهر)؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'بحر ... نهر'),
          Exercise(id: 'aud_3_9_c', skillId: 'aud_3', prompt: 'هل القافية متطابقة (جميل .. طويل)؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'جميل ... طويل'),
        ],
        [
          Exercise(id: 'aud_3_10_a', skillId: 'aud_3', prompt: 'كم كلمة سمعت؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['2', '3', '4'], correctAnswer: '3', ttsText: 'واحد اثنان ثلاثة'),
          Exercise(id: 'aud_3_10_b', skillId: 'aud_3', prompt: 'عد الكلمات:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['2', '3', '4'], correctAnswer: '3', ttsText: 'أنا أحب التفاح'),
          Exercise(id: 'aud_3_10_c', skillId: 'aud_3', prompt: 'كم وحدة (باب .. قلم .. كتاب)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['2', '3', '4'], correctAnswer: '3', ttsText: 'باب .. قلم .. كتاب'),
        ],
      ];
      return createStage(skillId, pools);
    }

    if (skillId == 'aud_4') {
      final pools = [
        [
          Exercise(id: 'aud_4_1_a', skillId: 'aud_4', prompt: 'أي صوت سمعت؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['س', 'ش'], correctAnswer: 'س', ttsText: 'س'),
          Exercise(id: 'aud_4_1_b', skillId: 'aud_4', prompt: 'ميز الصوت:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ب', 'ت'], correctAnswer: 'ب', ttsText: 'ب'),
          Exercise(id: 'aud_4_1_c', skillId: 'aud_4', prompt: 'اختر الحرف الذي سمعته:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ل', 'ر'], correctAnswer: 'ل', ttsText: 'ل'),
        ],
        [
          Exercise(id: 'aud_4_2_a', skillId: 'aud_4', prompt: 'أي كلمة سمعت؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['قلم', 'علم'], correctAnswer: 'قلم', ttsText: 'قلم'),
          Exercise(id: 'aud_4_2_b', skillId: 'aud_4', prompt: 'اختر الكلمة الصحيحة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['بحر', 'نهر'], correctAnswer: 'بحر', ttsText: 'بحر'),
          Exercise(id: 'aud_4_2_c', skillId: 'aud_4', prompt: 'وين الكلمة اللي سمعتها؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['تمر', 'قمر'], correctAnswer: 'تمر', ttsText: 'تمر'),
        ],
        [
          Exercise(id: 'aud_4_3_a', skillId: 'aud_4', prompt: 'اختر الكلمة التي سمعتها:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['تين', 'طين', 'سين'], correctAnswer: 'طين', ttsText: 'طين'),
          Exercise(id: 'aud_4_3_b', skillId: 'aud_4', prompt: 'ميز الكلمة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['فول', 'غول', 'طول'], correctAnswer: 'فول', ttsText: 'فول'),
          Exercise(id: 'aud_4_3_c', skillId: 'aud_4', prompt: 'أي وحدة سمعت؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['نمل', 'رمل', 'حمل'], correctAnswer: 'نمل', ttsText: 'نمل'),
        ],
        [
          Exercise(id: 'aud_4_4_a', skillId: 'aud_4', prompt: 'هل الكلمتان متطابقتان؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'لا', ttsText: 'قلم . علم'),
          Exercise(id: 'aud_4_4_b', skillId: 'aud_4', prompt: 'نفس الكلمة (بنت .. بيت)؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'لا', ttsText: 'بنت . بيت'),
          Exercise(id: 'aud_4_4_c', skillId: 'aud_4', prompt: 'هل هما توأم (شمس .. لمس)؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'لا', ttsText: 'شمس . لمس'),
        ],
        [
          Exercise(id: 'aud_4_5_a', skillId: 'aud_4', prompt: 'استمع للكلمة واخترها:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['فاس', 'فأر', 'فاز'], correctAnswer: 'فاس', ttsText: 'فاس'),
          Exercise(id: 'aud_4_5_b', skillId: 'aud_4', prompt: 'وين كلمة (كتاب)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['كتاب', 'كباب', 'كبير'], correctAnswer: 'كتاب', ttsText: 'كتاب'),
          Exercise(id: 'aud_4_5_c', skillId: 'aud_4', prompt: 'اختر الكلمة المطابقة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ملح', 'بلح', 'فلح'], correctAnswer: 'ملح', ttsText: 'ملح'),
        ],
        [
          Exercise(id: 'aud_4_6_a', skillId: 'aud_4', prompt: 'ميز الحرف الأول:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['س', 'ص'], correctAnswer: 'س', ttsText: 'ساعة'),
          Exercise(id: 'aud_4_6_b', skillId: 'aud_4', prompt: 'أول حرف في (طائرة):', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ط', 'ت'], correctAnswer: 'ط', ttsText: 'طائرة'),
          Exercise(id: 'aud_4_6_c', skillId: 'aud_4', prompt: 'شو أول صوت في (ظبي)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ظ', 'ذ'], correctAnswer: 'ظ', ttsText: 'ظبي'),
        ],
        [
          Exercise(id: 'aud_4_7_a', skillId: 'aud_4', prompt: 'هل تنتهي الكلمتان بنفس الحرف؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'ملح .. بلح'),
          Exercise(id: 'aud_4_7_b', skillId: 'aud_4', prompt: 'نفس النهاية (سوق .. فوق)؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'سوق .. فوق'),
          Exercise(id: 'aud_4_7_c', skillId: 'aud_4', prompt: 'هل ينتهيان بـ (ن) (عين .. سن)؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'عين .. سن'),
        ],
        [
          Exercise(id: 'aud_4_8_a', skillId: 'aud_4', prompt: 'اختر الكلمة التي فيها حرف (ر):', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['رمان', 'موز', 'تفاح'], correctAnswer: 'رمان', ttsText: 'رمان'),
          Exercise(id: 'aud_4_8_b', skillId: 'aud_4', prompt: 'وين الكلمة اللي فيها (س)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['سمك', 'كلب', 'بيت'], correctAnswer: 'سمك', ttsText: 'سمك'),
          Exercise(id: 'aud_4_8_c', skillId: 'aud_4', prompt: 'أي كلمة تحتوي (ب)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['بطة', 'نملة', 'فيل'], correctAnswer: 'بطة', ttsText: 'بطة'),
        ],
        [
          Exercise(id: 'aud_4_9_a', skillId: 'aud_4', prompt: 'أي حرف سمعت في وسط الكلمة؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ب', 'ت'], correctAnswer: 'ب', ttsText: 'جبل'),
          Exercise(id: 'aud_4_9_b', skillId: 'aud_4', prompt: 'شو الحرف اللي في النص في (قطن)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ط', 'ت'], correctAnswer: 'ط', ttsText: 'قطن'),
          Exercise(id: 'aud_4_9_c', skillId: 'aud_4', prompt: 'ميز حرف الوسط في (قلم):', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['ل', 'ن'], correctAnswer: 'ل', ttsText: 'قلم'),
        ],
        [
          Exercise(id: 'aud_4_10_a', skillId: 'aud_4', prompt: 'هل هذه كلمة واحدة؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'استقلال'),
          Exercise(id: 'aud_4_10_b', skillId: 'aud_4', prompt: 'كلمة واحدة (تلفاز)؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'تلفاز'),
          Exercise(id: 'aud_4_10_c', skillId: 'aud_4', prompt: 'هل سمعت كلمة واحدة (مستشفى)؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'مستشفى'),
        ],
      ];
      return createStage(skillId, pools);
    }

    if (skillId == 'aud_10') {
      final pools = [
        [
          Exercise(id: 'aud_10_1_a', skillId: 'aud_10', prompt: 'هل الكلمتان (تفاحة) و (تفاحة) متشابهتان؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'تفاحة .. تفاحة'),
          Exercise(id: 'aud_10_1_b', skillId: 'aud_10', prompt: 'هل هما نفس الكلمة؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'موز .. موز'),
          Exercise(id: 'aud_10_1_c', skillId: 'aud_10', prompt: 'متطابقتان؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'كتاب .. كتاب'),
        ],
        [
          Exercise(id: 'aud_10_2_a', skillId: 'aud_10', prompt: 'هل الكلمتان (بيت) و (بنت) متشابهتان؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'لا', ttsText: 'بيت .. بنت'),
          Exercise(id: 'aud_10_2_b', skillId: 'aud_10', prompt: 'مختلفتان؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'لا', ttsText: 'قلم .. علم'),
          Exercise(id: 'aud_10_2_c', skillId: 'aud_10', prompt: 'هل تسمع فرقاً؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'لا', ttsText: 'فيل .. فول'),
        ],
        [
          Exercise(id: 'aud_10_3_a', skillId: 'aud_10', prompt: 'أي كلمة هي المختلفة؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['بحر', 'بحر', 'نهر'], correctAnswer: 'نهر', ttsText: 'بحر .. بحر .. نهر'),
          Exercise(id: 'aud_10_3_b', skillId: 'aud_10', prompt: 'وين الغريبة؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['شمس', 'قمر', 'شمس'], correctAnswer: 'قمر', ttsText: 'شمس .. قمر .. شمس'),
          Exercise(id: 'aud_10_3_c', skillId: 'aud_10', prompt: 'اختر المختلفة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['توت', 'توت', 'موز'], correctAnswer: 'موز', ttsText: 'توت .. توت .. موز'),
        ],
        [
          Exercise(id: 'aud_10_4_a', skillId: 'aud_10', prompt: 'هل تسمع نفس الحرف في (ساعة) و (سوق)؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'ساعة .. سوق'),
          Exercise(id: 'aud_10_4_b', skillId: 'aud_10', prompt: 'يبدآن بنفس الحرف؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'باب .. بحر'),
          Exercise(id: 'aud_10_4_c', skillId: 'aud_10', prompt: 'نفس الصوت في الأول؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'تمر .. توت'),
        ],
        [
          Exercise(id: 'aud_10_5_a', skillId: 'aud_10', prompt: 'أي كلمة تبدأ بحرف مختلف؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['كلب', 'كتاب', 'قطة'], correctAnswer: 'قطة', ttsText: 'كلب .. كتاب .. قطة'),
          Exercise(id: 'aud_10_5_b', skillId: 'aud_10', prompt: 'وين الحرف المختلف في البداية؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['سمك', 'ساعة', 'باب'], correctAnswer: 'باب', ttsText: 'سمك .. ساعة .. باب'),
          Exercise(id: 'aud_10_5_c', skillId: 'aud_10', prompt: 'اختر الكلمة الغريبة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['نمل', 'نحل', 'فيل'], correctAnswer: 'فيل', ttsText: 'نمل .. نحل .. فيل'),
        ],
        [
          Exercise(id: 'aud_10_6_a', skillId: 'aud_10', prompt: 'هل الكلمتان (تمر) و (قمر) لهما نفس النهاية؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'تمر .. قمر'),
          Exercise(id: 'aud_10_6_b', skillId: 'aud_10', prompt: 'ينتهيان بنفس الصوت؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'جميل .. طويل'),
          Exercise(id: 'aud_10_6_c', skillId: 'aud_10', prompt: 'نفس القافية؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'سماء .. ماء'),
        ],
        [
          Exercise(id: 'aud_10_7_a', skillId: 'aud_10', prompt: 'هل (أسد) و (أرنب) يبدآن بنفس الصوت؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'أسد .. أرنب'),
          Exercise(id: 'aud_10_7_b', skillId: 'aud_10', prompt: 'نفس حرف البداية؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'وردة .. ولد'),
          Exercise(id: 'aud_10_7_c', skillId: 'aud_10', prompt: 'متشابهان في الأول؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'جبل .. جمل'),
        ],
        [
          Exercise(id: 'aud_10_8_a', skillId: 'aud_10', prompt: 'أي كلمة هي الأطول صوتاً؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['أنا', 'برتقالة', 'باب'], correctAnswer: 'برتقالة', ttsText: 'أنا .. برتقالة .. باب'),
          Exercise(id: 'aud_10_8_b', skillId: 'aud_10', prompt: 'وين الكلمة الطويلة؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['يد', 'مستشفى', 'عين'], correctAnswer: 'مستشفى', ttsText: 'يد .. مستشفى .. عين'),
          Exercise(id: 'aud_10_8_c', skillId: 'aud_10', prompt: 'اختر أطول وحدة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['كمبيوتر', 'بيت', 'شمس'], correctAnswer: 'كمبيوتر', ttsText: 'كمبيوتر .. بيت .. شمس'),
        ],
        [
          Exercise(id: 'aud_10_9_a', skillId: 'aud_10', prompt: 'هل الكلمتان (حليب) و (حميد) متشابهتان؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'لا', ttsText: 'حليب .. حميد'),
          Exercise(id: 'aud_10_9_b', skillId: 'aud_10', prompt: 'مختلفتان في الوسط؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'لا', ttsText: 'سيف .. سوف'),
          Exercise(id: 'aud_10_9_c', skillId: 'aud_10', prompt: 'هل تسمع فرقاً بسيطاً؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'لا', ttsText: 'بحر .. بدر'),
        ],
        [
          Exercise(id: 'aud_10_10_a', skillId: 'aud_10', prompt: 'ميز الكلمة التي سمعتها مرتين:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['وردة', 'سماء', 'شمس'], correctAnswer: 'وردة', ttsText: 'وردة .. سماء .. وردة'),
          Exercise(id: 'aud_10_10_b', skillId: 'aud_10', prompt: 'شو الكلمة اللي تكررت؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['باب', 'قلم', 'كتاب'], correctAnswer: 'باب', ttsText: 'باب .. قلم .. باب'),
          Exercise(id: 'aud_10_10_c', skillId: 'aud_10', prompt: 'اختر المتكررة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['بنت', 'ولد', 'أم'], correctAnswer: 'بنت', ttsText: 'بنت .. بنت .. ولد'),
        ],
      ];
      return createStage(skillId, pools);
    }

    if (skillId == 'aud_11') {
      final pools = [
        [
          Exercise(id: 'aud_11_1_a', skillId: 'aud_11', prompt: 'أكمل الآية: (الحمد لله رب ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['العالمين', 'الرحيم', 'الناس'], correctAnswer: 'العالمين', ttsText: 'الْحَمْدُ لِلَّهِ رَبِّ ...'),
          Exercise(id: 'aud_11_1_b', skillId: 'aud_11', prompt: 'أكمل: (مالك يوم ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['الدين', 'الفلق', 'الناس'], correctAnswer: 'الدين', ttsText: 'مَالِكِ يَوْمِ ...'),
          Exercise(id: 'aud_11_1_c', skillId: 'aud_11', prompt: 'أكمل: (إياك نعبد وإياك ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['نستعين', 'الرحيم', 'العالمين'], correctAnswer: 'نستعين', ttsText: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ ...'),
        ],
        [
          Exercise(id: 'aud_11_2_a', skillId: 'aud_11', prompt: 'أكمل الآية: (قل هو الله ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['أحد', 'الصمد', 'كفواً'], correctAnswer: 'أحد', ttsText: 'قُلْ هُوَ اللَّهُ ...'),
          Exercise(id: 'aud_11_2_b', skillId: 'aud_11', prompt: 'أكمل: (ولم يكن له ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['كفواً أحد', 'الصمد', 'يولد'], correctAnswer: 'كفواً أحد', ttsText: 'وَلَمْ يَكُنْ لَهُ ...'),
          Exercise(id: 'aud_11_2_c', skillId: 'aud_11', prompt: 'أكمل: (الله ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['الصمد', 'أحد', 'يولد'], correctAnswer: 'الصمد', ttsText: 'اللَّهُ ...'),
        ],
        [
          Exercise(id: 'aud_11_3_a', skillId: 'aud_11', prompt: 'أكمل الآية: (قل أعوذ برب ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['الفلق', 'الناس', 'العالمين'], correctAnswer: 'الفلق', ttsText: 'قُلْ أَعُوذُ بِرَبِّ ...'),
          Exercise(id: 'aud_11_3_b', skillId: 'aud_11', prompt: 'أكمل: (من شر ما ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['خلق', 'وقب', 'حسد'], correctAnswer: 'خلق', ttsText: 'مِنْ شَرِّ مَا ...'),
          Exercise(id: 'aud_11_3_c', skillId: 'aud_11', prompt: 'أكمل: (ومن شر غاسق إذا ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['وقب', 'حسد', 'خلق'], correctAnswer: 'وقب', ttsText: 'وَمِنْ شَرِّ غَاسِقٍ إِذَا ...'),
        ],
        [
          Exercise(id: 'aud_11_4_a', skillId: 'aud_11', prompt: 'أكمل الآية: (قل أعوذ برب ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['الناس', 'الفلق', 'أحد'], correctAnswer: 'الناس', ttsText: 'قُلْ أَعُوذُ بِرَبِّ ...'),
          Exercise(id: 'aud_11_4_b', skillId: 'aud_11', prompt: 'أكمل: (ملك ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['الناس', 'الفلق', 'العالمين'], correctAnswer: 'الناس', ttsText: 'مَلِكِ ...'),
          Exercise(id: 'aud_11_4_c', skillId: 'aud_11', prompt: 'أكمل: (إله ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['الناس', 'الفلق', 'أحد'], correctAnswer: 'الناس', ttsText: 'إِلَهِ ...'),
        ],
        [
          Exercise(id: 'aud_11_5_a', skillId: 'aud_11', prompt: 'أكمل الآية: (الذي يوسوس في صدور ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['الناس', 'الخناس', 'الفلق'], correctAnswer: 'الناس', ttsText: 'الَّذِي يُوَسْوِسُ فِي صُدُورِ ...'),
          Exercise(id: 'aud_11_5_b', skillId: 'aud_11', prompt: 'أكمل: (من شر الوسواس ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['الخناس', 'الناس', 'الفلق'], correctAnswer: 'الخناس', ttsText: 'مِنْ شَرِّ الْوَسْوَاسِ ...'),
          Exercise(id: 'aud_11_5_c', skillId: 'aud_11', prompt: 'أكمل: (من الجنة و ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['الناس', 'الخناس', 'الفلق'], correctAnswer: 'الناس', ttsText: 'مِنَ الْجِنَّةِ وَ ...'),
        ],
        [
          Exercise(id: 'aud_11_6_a', skillId: 'aud_11', prompt: 'أكمل الآية: (بسم الله ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['الرحمن الرحيم', 'العالمين', 'أحد'], correctAnswer: 'الرحمن الرحيم', ttsText: 'بِسْمِ اللَّهِ ...'),
          Exercise(id: 'aud_11_6_b', skillId: 'aud_11', prompt: 'أكمل: (الرحمن ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['الرحيم', 'الدين', 'العالمين'], correctAnswer: 'الرحيم', ttsText: 'الرَّحْمَنِ ...'),
          Exercise(id: 'aud_11_6_c', skillId: 'aud_11', prompt: 'أكمل: (اهدنا الصراط ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['المستقيم', 'العالمين', 'الرحيم'], correctAnswer: 'المستقيم', ttsText: 'اهْدِنَا الصِّرَاطَ ...'),
        ],
        [
          Exercise(id: 'aud_11_7_a', skillId: 'aud_11', prompt: 'أكمل الآية: (لم يلد ولم ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['يولد', 'يحد', 'يصمد'], correctAnswer: 'يولد', ttsText: 'لَمْ يَلِدْ وَلَمْ ...'),
          Exercise(id: 'aud_11_7_b', skillId: 'aud_11', prompt: 'أكمل: (قل هو الله ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['أحد', 'أحمد', 'أمين'], correctAnswer: 'أحد', ttsText: 'قُلْ هُوَ اللَّهُ ...'),
          Exercise(id: 'aud_11_7_c', skillId: 'aud_11', prompt: 'أكمل: (الله الصمد لم يلد ولم ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['يولد', 'يكن', 'يعلم'], correctAnswer: 'يولد', ttsText: 'اللَّهُ الصَّمَدُ لَمْ يَلِدْ وَلَمْ ...'),
        ],
        [
          Exercise(id: 'aud_11_8_a', skillId: 'aud_11', prompt: 'أكمل الآية: (ومن شر حاسد إذا ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['حسد', 'خلق', 'وقب'], correctAnswer: 'حسد', ttsText: 'وَمِنْ شَرِّ حَاسِدٍ إِذَا ...'),
          Exercise(id: 'aud_11_8_b', skillId: 'aud_11', prompt: 'أكمل: (ومن شر النفاثات في ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['العقد', 'الحسد', 'الفلق'], correctAnswer: 'العقد', ttsText: 'وَمِنْ شَرِّ النَّفَّاثَاتِ فِي ...'),
          Exercise(id: 'aud_11_8_c', skillId: 'aud_11', prompt: 'أكمل: (قل أعوذ برب الفلق من شر ما ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['خلق', 'حسد', 'وقب'], correctAnswer: 'خلق', ttsText: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ مِنْ شَرِّ مَا ...'),
        ],
        [
          Exercise(id: 'aud_11_9_a', skillId: 'aud_11', prompt: 'أكمل الآية: (قل أعوذ برب الناس ملك ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['الناس', 'الفلق', 'الدين'], correctAnswer: 'الناس', ttsText: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ مَلِكِ ...'),
          Exercise(id: 'aud_11_9_b', skillId: 'aud_11', prompt: 'أكمل: (الذي يوسوس في صدور الناس من الجنة و ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['الناس', 'العالمين', 'الخناس'], correctAnswer: 'الناس', ttsText: 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ مِنَ الْجِنَّةِ وَ ...'),
          Exercise(id: 'aud_11_9_c', skillId: 'aud_11', prompt: 'أكمل: (إله الناس من شر الوسواس ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['الخناس', 'الناس', 'الفلق'], correctAnswer: 'الخناس', ttsText: 'إِلَهِ النَّاسِ مِنْ شَرِّ الْوَسْوَاسِ ...'),
        ],
        [
          Exercise(id: 'aud_11_10_a', skillId: 'aud_11', prompt: 'أكمل الآية: (اهدنا الصراط المستقيم صراط الذين ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['أنعمت عليهم', 'العالمين', 'الرحيم'], correctAnswer: 'أنعمت عليهم', ttsText: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ صِرَاطَ الَّذِينَ ...'),
          Exercise(id: 'aud_11_10_b', skillId: 'aud_11', prompt: 'أكمل: (غير المغضوب عليهم ولا ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['الضالين', 'العالمين', 'الرحيم'], correctAnswer: 'الضالين', ttsText: 'غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا ...'),
          Exercise(id: 'aud_11_10_c', skillId: 'aud_11', prompt: 'أكمل: (إياك نعبد وإياك نستعين اهدنا ...)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['الصراط المستقيم', 'العالمين', 'الدين'], correctAnswer: 'الصراط المستقيم', ttsText: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ اهْدِنَا ...'),
        ],
      ];
      return createStage(skillId, pools);
    }

    if (skillId == 'aud_5') {
      final pools = [
        [
          Exercise(id: 'aud_5_1_a', skillId: 'aud_5', prompt: 'ما الحركة المناسبة لصوت (سَ)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['سَ', 'سُ', 'سِ'], correctAnswer: 'سَ', ttsText: 'سَ'),
          Exercise(id: 'aud_5_1_b', skillId: 'aud_5', prompt: 'وين الفتحة في (سَ)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['سَ', 'سُ', 'سِ'], correctAnswer: 'سَ', ttsText: 'سَ'),
          Exercise(id: 'aud_5_1_c', skillId: 'aud_5', prompt: 'اختر صوت الفتحة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['سَ', 'سُ', 'سِ'], correctAnswer: 'سَ', ttsText: 'سَ'),
        ],
        [
          Exercise(id: 'aud_5_2_a', skillId: 'aud_5', prompt: 'ما المقطع المطابق لصوت (بَا)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['بَا', 'بُو', 'بِي'], correctAnswer: 'بَا', ttsText: 'بَا'),
          Exercise(id: 'aud_5_2_b', skillId: 'aud_5', prompt: 'وين مقطع (بَا)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['بَا', 'بُو', 'بِي'], correctAnswer: 'بَا', ttsText: 'بَا'),
          Exercise(id: 'aud_5_2_c', skillId: 'aud_5', prompt: 'اختر صوت (بَا):', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['بَا', 'بُو', 'بِي'], correctAnswer: 'بَا', ttsText: 'بَا'),
        ],
        [
          Exercise(id: 'aud_5_3_a', skillId: 'aud_5', prompt: 'أي كلمة سمعتها؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['قَلَمٌ', 'قَالَمٌ'], correctAnswer: 'قَلَمٌ', ttsText: 'قَلَمٌ'),
          Exercise(id: 'aud_5_3_b', skillId: 'aud_5', prompt: 'وين كلمة (قلم)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['قَلَمٌ', 'قَالَمٌ'], correctAnswer: 'قَلَمٌ', ttsText: 'قَلَمٌ'),
          Exercise(id: 'aud_5_3_c', skillId: 'aud_5', prompt: 'اختر الكلمة الصحيحة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['قَلَمٌ', 'قَالَمٌ'], correctAnswer: 'قَلَمٌ', ttsText: 'قَلَمٌ'),
        ],
        [
          Exercise(id: 'aud_5_4_a', skillId: 'aud_5', prompt: 'الكلمة التي سمعتها تبدأ بحرف:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['س', 'ص', 'ث'], correctAnswer: 'ص', ttsText: 'صُورَةٌ'),
          Exercise(id: 'aud_5_4_b', skillId: 'aud_5', prompt: 'وين حرف (ص) في (صورة)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['س', 'ص', 'ث'], correctAnswer: 'ص', ttsText: 'صُورَةٌ'),
          Exercise(id: 'aud_5_4_c', skillId: 'aud_5', prompt: 'اختر أول حرف في (صورة):', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['س', 'ص', 'ث'], correctAnswer: 'ص', ttsText: 'صُورَةٌ'),
        ],
        [
          Exercise(id: 'aud_5_5_a', skillId: 'aud_5', prompt: 'هل هذا هو الكلب؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', audioAsset: 'audio/dog.mp3', imageAsset: 'assets/images/dog.png'),
          Exercise(id: 'aud_5_5_b', skillId: 'aud_5', prompt: 'هذا صوت الكلب؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', audioAsset: 'audio/dog.mp3', imageAsset: 'assets/images/dog.png'),
          Exercise(id: 'aud_5_5_c', skillId: 'aud_5', prompt: 'هل تسمع الكلب؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', audioAsset: 'audio/dog.mp3', imageAsset: 'assets/images/dog.png'),
        ],
        [
          Exercise(id: 'aud_5_6_a', skillId: 'aud_5', prompt: 'يا بطل... هل هذه بقرة؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['بقرة', 'بطة', 'قطة'], correctAnswer: 'بقرة', audioAsset: 'audio/cow.mp3', imageAsset: 'assets/images/cow.png'),
          Exercise(id: 'aud_5_6_b', skillId: 'aud_5', prompt: 'وين البقرة؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['بقرة', 'بطة', 'قطة'], correctAnswer: 'بقرة', audioAsset: 'audio/cow.mp3', imageAsset: 'assets/images/cow.png'),
          Exercise(id: 'aud_5_6_c', skillId: 'aud_5', prompt: 'اختر البقرة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['بقرة', 'بطة', 'قطة'], correctAnswer: 'بقرة', audioAsset: 'audio/cow.mp3', imageAsset: 'assets/images/cow.png'),
        ],
        [
          Exercise(id: 'aud_5_7_a', skillId: 'aud_5', prompt: 'هذا صوت المطر؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', audioAsset: 'audio/rain.mp3'),
          Exercise(id: 'aud_5_7_b', skillId: 'aud_5', prompt: 'هل تسمع المطر؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', audioAsset: 'audio/rain.mp3'),
          Exercise(id: 'aud_5_7_c', skillId: 'aud_5', prompt: 'هذا مطر؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', audioAsset: 'audio/rain.mp3'),
        ],
        [
          Exercise(id: 'aud_5_8_a', skillId: 'aud_5', prompt: 'ماذا سمعت؟ طرق باب ولا ساعة؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['طرق باب', 'ساعة', 'مكنسة'], correctAnswer: 'ساعة', audioAsset: 'audio/clock ticking.mp3'),
          Exercise(id: 'aud_5_8_b', skillId: 'aud_5', prompt: 'وين الساعة؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['طرق باب', 'ساعة', 'مكنسة'], correctAnswer: 'ساعة', audioAsset: 'audio/clock ticking.mp3'),
          Exercise(id: 'aud_5_8_c', skillId: 'aud_5', prompt: 'اختر الساعة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['طرق باب', 'ساعة', 'مكنسة'], correctAnswer: 'ساعة', audioAsset: 'audio/clock ticking.mp3'),
        ],
        [
          Exercise(id: 'aud_5_9_a', skillId: 'aud_5', prompt: 'وين صورة التفاحة؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['تفاحة', 'موزة', 'عنب'], correctAnswer: 'تفاحة', imageAsset: 'assets/images/apple.png'),
          Exercise(id: 'aud_5_9_b', skillId: 'aud_5', prompt: 'اختر التفاحة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['تفاحة', 'موزة', 'عنب'], correctAnswer: 'تفاحة', imageAsset: 'assets/images/apple.png'),
          Exercise(id: 'aud_5_9_c', skillId: 'aud_5', prompt: 'وين التفاحة اللذيذة؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['تفاحة', 'موزة', 'عنب'], correctAnswer: 'تفاحة', imageAsset: 'assets/images/apple.png'),
        ],
        [
          Exercise(id: 'aud_5_10_a', skillId: 'aud_5', prompt: 'هل هذا هو الحصان القوي؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', imageAsset: 'assets/images/horse.png'),
          Exercise(id: 'aud_5_10_b', skillId: 'aud_5', prompt: 'هذا حصان؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', imageAsset: 'assets/images/horse.png'),
          Exercise(id: 'aud_5_10_c', skillId: 'aud_5', prompt: 'هل تسمع الحصان؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', imageAsset: 'assets/images/horse.png'),
        ],
      ];
      return createStage(skillId, pools);
    }

    if (skillId == 'aud_6') {
      final pools = [
        [
          Exercise(id: 'aud_6_1_a', skillId: 'aud_6', prompt: 'هل هذا سؤال؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['خبرية', 'استفهامية'], correctAnswer: 'استفهامية', ttsText: 'هَلْ ذَهَبْتَ إِلَى المَدْرَسَةِ؟'),
          Exercise(id: 'aud_6_1_b', skillId: 'aud_6', prompt: 'هذا سؤال؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['خبرية', 'استفهامية'], correctAnswer: 'استفهامية', ttsText: 'أين القلم؟'),
          Exercise(id: 'aud_6_1_c', skillId: 'aud_6', prompt: 'اختر نوع الجملة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['خبرية', 'استفهامية'], correctAnswer: 'استفهامية', ttsText: 'متى نأكل؟'),
        ],
        [
          Exercise(id: 'aud_6_2_a', skillId: 'aud_6', prompt: 'هل المتحدث يطلب مساعدة؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'سَاعِدُونِي مِنْ فَضْلِكُمْ!'),
          Exercise(id: 'aud_6_2_b', skillId: 'aud_6', prompt: 'هل يطلب المساعدة؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'أرجوك ساعدني!'),
          Exercise(id: 'aud_6_2_c', skillId: 'aud_6', prompt: 'هل يحتاج لمساعدة؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'ساعدني يا بابا!'),
        ],
        [
          Exercise(id: 'aud_6_3_a', skillId: 'aud_6', prompt: 'هل هذا أسلوب تعجب؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'مَا أَجْمَلَ السَّمَاءَ!'),
          Exercise(id: 'aud_6_3_b', skillId: 'aud_6', prompt: 'هذا تعجب؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'يا له من ورد جميل!'),
          Exercise(id: 'aud_6_3_c', skillId: 'aud_6', prompt: 'هل يتعجب المتحدث؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'ما أروع الحديقة!'),
        ],
        [
          Exercise(id: 'aud_6_4_a', skillId: 'aud_6', prompt: 'هل المتحدث غاضب؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'لَا تَفْعَلْ ذَلِكَ مَرَّةً أُخْرَى!'),
          Exercise(id: 'aud_6_4_b', skillId: 'aud_6', prompt: 'هل هو زعلان؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'أنا غاضب منك!'),
          Exercise(id: 'aud_6_4_c', skillId: 'aud_6', prompt: 'هل يبدو غاضباً؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'لماذا فعلت هذا؟!'),
        ],
        [
          Exercise(id: 'aud_6_5_a', skillId: 'aud_6', prompt: 'هل يبدو المتحدث حزيناً؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'أَنَا أَشْعُرُ بِالحُزْنِ اليَوْمَ.'),
          Exercise(id: 'aud_6_5_b', skillId: 'aud_6', prompt: 'هل هو حزين؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'يا للاسف، أنا حزين.'),
          Exercise(id: 'aud_6_5_c', skillId: 'aud_6', prompt: 'هل المتحدث يبكي؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'أنا حزين جداً لفقداني لعبتي.'),
        ],
        [
          Exercise(id: 'aud_6_6_a', skillId: 'aud_6', prompt: 'هل هذا سؤال؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'كَمْ السَّاعَةُ الآن؟'),
          Exercise(id: 'aud_6_6_b', skillId: 'aud_6', prompt: 'سؤال؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'من طرق الباب؟'),
          Exercise(id: 'aud_6_6_c', skillId: 'aud_6', prompt: 'هل يسأل المتحدث؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'كيف حالك؟'),
        ],
        [
          Exercise(id: 'aud_6_7_a', skillId: 'aud_6', prompt: 'هل هذا الصوت سعيد؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'أنا سعيد جداً اليوم!'),
          Exercise(id: 'aud_6_7_b', skillId: 'aud_6', prompt: 'هل هو فرحان؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'يا له من خبر رائع! أنا سعيد!'),
          Exercise(id: 'aud_6_7_c', skillId: 'aud_6', prompt: 'هل المتحدث يضحك من السعادة؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'أنا متحمس وسعيد جداً!'),
        ],
        [
          Exercise(id: 'aud_6_8_a', skillId: 'aud_6', prompt: 'وين كلمة السؤال (لماذا)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['لماذا', 'كيف', 'متى'], correctAnswer: 'لماذا', ttsText: 'لماذا نبكي؟'),
          Exercise(id: 'aud_6_8_b', skillId: 'aud_6', prompt: 'وين (لماذا)؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['لماذا', 'من', 'أين'], correctAnswer: 'لماذا', ttsText: 'لماذا نأكل؟'),
          Exercise(id: 'aud_6_8_c', skillId: 'aud_6', prompt: 'اختر أداة السؤال (لماذا):', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['لماذا', 'هل', 'ماذا'], correctAnswer: 'لماذا', ttsText: 'لماذا ننام؟'),
        ],
        [
          Exercise(id: 'aud_6_9_a', skillId: 'aud_6', prompt: 'من الذي يشرب؟ (البنت)', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['البنت تشرب', 'الولد يشرب'], correctAnswer: 'البنت تشرب', ttsText: 'البنت تشرب الحليب'),
          Exercise(id: 'aud_6_9_b', skillId: 'aud_6', prompt: 'وين البنت؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['البنت تشرب', 'الولد يشرب'], correctAnswer: 'البنت تشرب', ttsText: 'البنت تلعب بالكرة'),
          Exercise(id: 'aud_6_9_c', skillId: 'aud_6', prompt: 'اختر الجملة عن البنت:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['البنت تشرب', 'الولد يشرب'], correctAnswer: 'البنت تشرب', ttsText: 'البنت تأكل التفاحة'),
        ],
        [
          Exercise(id: 'aud_6_10_a', skillId: 'aud_6', prompt: 'هل السمكة تعيش في الماء؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'السمكة تسبح في الماء'),
          Exercise(id: 'aud_6_10_b', skillId: 'aud_6', prompt: 'السمكة في الماء؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'السمكة تحب الماء'),
          Exercise(id: 'aud_6_10_c', skillId: 'aud_6', prompt: 'هل تسبح السمكة؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', ttsText: 'السمكة سريعة في الماء'),
        ],
      ];
      return createStage(skillId, pools);
    }

    if (skillId == 'aud_7') {
      final pools = [
        [
          Exercise(id: 'aud_7_1_a', skillId: 'aud_7', prompt: 'ما ترتيب الأرقام؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← 1 - 3 - 5', '← 5 - 3 - 1'], correctAnswer: '← 1 - 3 - 5', ttsText: 'واحد .. ثلاثة .. خمسة'),
          Exercise(id: 'aud_7_1_b', skillId: 'aud_7', prompt: 'الترتيب الصحيح:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← 2 - 4 - 6', '← 6 - 4 - 2'], correctAnswer: '← 2 - 4 - 6', ttsText: 'اثنان .. أربعة .. ستة'),
          Exercise(id: 'aud_7_1_c', skillId: 'aud_7', prompt: 'اختر الترتيب:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← 1 - 2 - 3', '← 3 - 2 - 1'], correctAnswer: '← 1 - 2 - 3', ttsText: 'واحد .. اثنان .. ثلاثة'),
        ],
        [
          Exercise(id: 'aud_7_2_a', skillId: 'aud_7', prompt: 'أعد ترتيب الأرقام:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← 7 - 5 - 3 - 1', '← 1 - 3 - 5 - 7'], correctAnswer: '← 7 - 5 - 3 - 1', ttsText: 'سبعة .. خمسة .. ثلاثة .. واحد'),
          Exercise(id: 'aud_7_2_b', skillId: 'aud_7', prompt: 'رتب بالعكس:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← 9 - 6 - 3', '← 3 - 6 - 9'], correctAnswer: '← 9 - 6 - 3', ttsText: 'تسعة .. ستة .. ثلاثة'),
          Exercise(id: 'aud_7_2_c', skillId: 'aud_7', prompt: 'اختر الترتيب التنازلي:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← 5 - 4 - 3', '← 3 - 4 - 5'], correctAnswer: '← 5 - 4 - 3', ttsText: 'خمسة .. أربعة .. ثلاثة'),
        ],
        [
          Exercise(id: 'aud_7_3_a', skillId: 'aud_7', prompt: 'ما هما الكلمتان بالترتيب؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← تَعَلَّم - عَلِمَ', '← عَلِمَ - تَعَلَّم'], correctAnswer: '← تَعَلَّم - عَلِمَ', ttsText: 'تعلّم .. عَلِم'),
          Exercise(id: 'aud_7_3_b', skillId: 'aud_7', prompt: 'الترتيب الصحيح للكلمات:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← باب - قلم', '← قلم - باب'], correctAnswer: '← باب - قلم', ttsText: 'باب .. قلم'),
          Exercise(id: 'aud_7_3_c', skillId: 'aud_7', prompt: 'ماذا سمعت أولاً؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← قطة - كلب', '← كلب - قطة'], correctAnswer: '← قطة - كلب', ttsText: 'قطة .. كلب'),
        ],
        [
          Exercise(id: 'aud_7_4_a', skillId: 'aud_7', prompt: 'ما هو ترتيب الكلمات؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← شَمْس - قَمَر - نُجُوم', '← قَمَر - شَمْس - نُجُوم'], correctAnswer: '← شَمْس - قَمَر - نُجُوم', ttsText: 'شمس .. قمر .. نجوم'),
          Exercise(id: 'aud_7_4_b', skillId: 'aud_7', prompt: 'رتب الكلمات الثلاث:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← تفاح - موز - عنب', '← عنب - موز - تفاح'], correctAnswer: '← تفاح - موز - عنب', ttsText: 'تفاح .. موز .. عنب'),
          Exercise(id: 'aud_7_4_c', skillId: 'aud_7', prompt: 'اختر الترتيب السمعي:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← أسد - نمر - فهد', '← فهد - نمر - أسد'], correctAnswer: '← أسد - نمر - فهد', ttsText: 'أسد .. نمر .. فهد'),
        ],
        [
          Exercise(id: 'aud_7_5_a', skillId: 'aud_7', prompt: 'ما هما الحرفان بالترتيب؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← أ - ب', '← ب - أ'], correctAnswer: '← أ - ب', ttsText: 'ألف .. باء'),
          Exercise(id: 'aud_7_5_b', skillId: 'aud_7', prompt: 'رتب الحروف:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← س - ش', '← ش - س'], correctAnswer: '← س - ش', ttsText: 'سين .. شين'),
          Exercise(id: 'aud_7_5_c', skillId: 'aud_7', prompt: 'الحروف بالترتيب هي:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← م - ن', '← ن - م'], correctAnswer: '← م - ن', ttsText: 'ميم .. نون'),
        ],
        [
          Exercise(id: 'aud_7_6_a', skillId: 'aud_7', prompt: 'ما هو "عكس" الترتيب؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← 9 - 1', '← 1 - 9'], correctAnswer: '← 9 - 1', ttsText: 'واحد .. تسعة'),
          Exercise(id: 'aud_7_6_b', skillId: 'aud_7', prompt: 'اعكس الترتيب:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← ي - أ', '← أ - ي'], correctAnswer: '← ي - أ', ttsText: 'ألف .. ياء'),
          Exercise(id: 'aud_7_6_c', skillId: 'aud_7', prompt: 'ما هو الترتيب المقلوب؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← ليل - نهار', '← نهار - ليل'], correctAnswer: '← ليل - نهار', ttsText: 'نهار .. ليل'),
        ],
        [
          Exercise(id: 'aud_7_7_a', skillId: 'aud_7', prompt: 'رتب الألوان:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← أحمر - أزرق', '← أزرق - أحمر'], correctAnswer: '← أحمر - أزرق', ttsText: 'أحمر .. أزرق'),
          Exercise(id: 'aud_7_7_b', skillId: 'aud_7', prompt: 'الترتيب اللوني:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← أخضر - أصفر', '← أصفر - أخضر'], correctAnswer: '← أخضر - أصفر', ttsText: 'أخضر .. أصفر'),
          Exercise(id: 'aud_7_7_c', skillId: 'aud_7', prompt: 'اختر ترتيب الألوان:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['← أبيض - أسود', '← أسود - أبيض'], correctAnswer: '← أبيض - أسود', ttsText: 'أبيض .. أسود'),
        ],
        [
          Exercise(id: 'aud_7_8_a', skillId: 'aud_7', prompt: 'ما هو الرقم الثالث؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['4', '6', '8'], correctAnswer: '8', ttsText: 'واحد .. خمسة .. ثمانية'),
          Exercise(id: 'aud_7_8_b', skillId: 'aud_7', prompt: 'الرقم الأخير هو:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['3', '7', '9'], correctAnswer: '9', ttsText: 'واحد .. سبعة .. تسعة'),
          Exercise(id: 'aud_7_8_c', skillId: 'aud_7', prompt: 'ما هو ثالث رقم سمعته؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['2', '4', '6'], correctAnswer: '6', ttsText: 'اثنان .. أربعة .. ستة'),
        ],
        [
          Exercise(id: 'aud_7_9_a', skillId: 'aud_7', prompt: 'أعد الجملة كما هي:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['الولد يلعب', 'البنت تلعب'], correctAnswer: 'الولد يلعب', ttsText: 'الولد يلعب في الحديقة'),
          Exercise(id: 'aud_7_9_b', skillId: 'aud_7', prompt: 'وين الجملة الصحيحة؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['أنا أحب الرسم', 'أنا أحب اللعب'], correctAnswer: 'أنا أحب الرسم', ttsText: 'أنا أحب الرسم كثيراً'),
          Exercise(id: 'aud_7_9_c', skillId: 'aud_7', prompt: 'اختر الجملة المطابقة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['السماء صافية', 'السماء غائمة'], correctAnswer: 'السماء صافية', ttsText: 'اليوم السماء صافية'),
        ],
        [
          Exercise(id: 'aud_7_10_a', skillId: 'aud_7', prompt: 'كم حيواناً سمعت؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['2', '3', '4'], correctAnswer: '2', ttsText: 'أسد .. فيل'),
          Exercise(id: 'aud_7_10_b', skillId: 'aud_7', prompt: 'عد الحيوانات:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['2', '3', '4'], correctAnswer: '3', ttsText: 'قطة .. كلب .. عصفور'),
          Exercise(id: 'aud_7_10_c', skillId: 'aud_7', prompt: 'كم عدد الحيوانات؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['2', '3', '4'], correctAnswer: '2', ttsText: 'جمل .. حصان'),
        ],
      ];
      return createStage(skillId, pools);
    }

    if (skillId == 'aud_8') {
      final pools = [
        [
          Exercise(id: 'aud_8_1_a', skillId: 'aud_8', prompt: 'يلا قول: كَلْب', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'كلب', ttsText: 'كَلْب'),
          Exercise(id: 'aud_8_1_b', skillId: 'aud_8', prompt: 'قول كَلْب يا بطل:', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'كلب', ttsText: 'كَلْب'),
          Exercise(id: 'aud_8_1_c', skillId: 'aud_8', prompt: 'كرر كلمة: كَلْب', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'كلب', ttsText: 'كَلْب'),
        ],
        [
          Exercise(id: 'aud_8_2_a', skillId: 'aud_8', prompt: 'شو اسم هذي؟ قول: تُفَّاحَة', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'تفاحة', ttsText: 'تُفَّاحَة'),
          Exercise(id: 'aud_8_2_b', skillId: 'aud_8', prompt: 'انطق تُفَّاحَة:', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'تفاحة', ttsText: 'تُفَّاحَة'),
          Exercise(id: 'aud_8_2_c', skillId: 'aud_8', prompt: 'قول كلمة: تُفَّاحَة', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'تفاحة', ttsText: 'تُفَّاحَة'),
        ],
        [
          Exercise(id: 'aud_8_3_a', skillId: 'aud_8', prompt: 'قول: كِتَاب', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'كتاب', ttsText: 'كِتَاب'),
          Exercise(id: 'aud_8_3_b', skillId: 'aud_8', prompt: 'انطق كِتَاب:', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'كتاب', ttsText: 'كِتَاب'),
          Exercise(id: 'aud_8_3_c', skillId: 'aud_8', prompt: 'كرر كلمة: كِتَاب', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'كتاب', ttsText: 'كِتَاب'),
        ],
        [
          Exercise(id: 'aud_8_4_a', skillId: 'aud_8', prompt: 'نادي عليه: بَابَا', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'بابا', ttsText: 'بَابَا'),
          Exercise(id: 'aud_8_4_b', skillId: 'aud_8', prompt: 'قول بَابَا:', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'بابا', ttsText: 'بَابَا'),
          Exercise(id: 'aud_8_4_c', skillId: 'aud_8', prompt: 'نادي بَابَا يا بطل:', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'بابا', ttsText: 'بَابَا'),
        ],
        [
          Exercise(id: 'aud_8_5_a', skillId: 'aud_8', prompt: 'انظر فوق... قول: شَمْس', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'شمس', ttsText: 'شَمْس'),
          Exercise(id: 'aud_8_5_b', skillId: 'aud_8', prompt: 'قول شَمْس:', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'شمس', ttsText: 'شَمْس'),
          Exercise(id: 'aud_8_5_c', skillId: 'aud_8', prompt: 'انطق كلمة: شَمْس', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'شمس', ttsText: 'شَمْس'),
        ],
        [
          Exercise(id: 'aud_8_6_a', skillId: 'aud_8', prompt: 'انطق: كُرْسِي', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'كرسي', ttsText: 'كُرْسِي'),
          Exercise(id: 'aud_8_6_b', skillId: 'aud_8', prompt: 'قول كُرْسِي:', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'كرسي', ttsText: 'كُرْسِي'),
          Exercise(id: 'aud_8_6_c', skillId: 'aud_8', prompt: 'كرر كلمة: كُرْسِي', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'كرسي', ttsText: 'كُرْسِي'),
        ],
        [
          Exercise(id: 'aud_8_7_a', skillId: 'aud_8', prompt: 'قول: مَامَا', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'ماما', ttsText: 'مَامَا'),
          Exercise(id: 'aud_8_7_b', skillId: 'aud_8', prompt: 'نادي مَامَا:', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'ماما', ttsText: 'مَامَا'),
          Exercise(id: 'aud_8_7_c', skillId: 'aud_8', prompt: 'قول مَامَا يا شاطر:', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'ماما', ttsText: 'مَامَا'),
        ],
        [
          Exercise(id: 'aud_8_8_a', skillId: 'aud_8', prompt: 'انطق: سَيَّارَة', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'سيارة', ttsText: 'سَيَّارَة'),
          Exercise(id: 'aud_8_8_b', skillId: 'aud_8', prompt: 'قول سَيَّارَة:', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'سيارة', ttsText: 'سَيَّارَة'),
          Exercise(id: 'aud_8_8_c', skillId: 'aud_8', prompt: 'كرر كلمة: سَيَّارَة', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'سيارة', ttsText: 'سَيَّارَة'),
        ],
        [
          Exercise(id: 'aud_8_9_a', skillId: 'aud_8', prompt: 'قول: بَقَرَة', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'بقرة', ttsText: 'بَقَرَة'),
          Exercise(id: 'aud_8_9_b', skillId: 'aud_8', prompt: 'انطق بَقَرَة:', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'بقرة', ttsText: 'بَقَرَة'),
          Exercise(id: 'aud_8_9_c', skillId: 'aud_8', prompt: 'قول بَقَرَة يا بطل:', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'بقرة', ttsText: 'بَقَرَة'),
        ],
        [
          Exercise(id: 'aud_8_10_a', skillId: 'aud_8', prompt: 'انطق: حِصَان', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'حصان', ttsText: 'حِصَان'),
          Exercise(id: 'aud_8_10_b', skillId: 'aud_8', prompt: 'قول حِصَان:', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'حصان', ttsText: 'حِصَان'),
          Exercise(id: 'aud_8_10_c', skillId: 'aud_8', prompt: 'كرر كلمة: حِصَان', type: ExerciseType.speak, difficulty: difficulty, correctAnswer: 'حصان', ttsText: 'حِصَان'),
        ],
      ];
      return createStage(skillId, pools);
    }

    if (skillId == 'aud_9') {
      final pools = [
        [
          Exercise(id: 'aud_9_1_a', skillId: 'aud_9', prompt: 'أي حيوان يقول كذا؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['بقرة', 'بطة', 'قطة'], correctAnswer: 'بقرة', audioAsset: 'audio/cow.mp3', imageAsset: 'assets/images/cow.png'),
          Exercise(id: 'aud_9_1_b', skillId: 'aud_9', prompt: 'مين صوته كذا؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['بقرة', 'خروف', 'ماعز'], correctAnswer: 'بقرة', audioAsset: 'audio/cow.mp3', imageAsset: 'assets/images/cow.png'),
          Exercise(id: 'aud_9_1_c', skillId: 'aud_9', prompt: 'اختر البقرة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['بقرة', 'كلب', 'قطة'], correctAnswer: 'بقرة', audioAsset: 'audio/cow.mp3', imageAsset: 'assets/images/cow.png'),
        ],
        [
          Exercise(id: 'aud_9_2_a', skillId: 'aud_9', prompt: 'هذا الصوت لأي حيوان؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['خروف', 'ماعز', 'حصان'], correctAnswer: 'خروف', audioAsset: 'audio/sheep.mp3', imageAsset: 'assets/images/sheep.png'),
          Exercise(id: 'aud_9_2_b', skillId: 'aud_9', prompt: 'مين يقول بااا؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['خروف', 'قطة', 'بطة'], correctAnswer: 'خروف', audioAsset: 'audio/sheep.mp3', imageAsset: 'assets/images/sheep.png'),
          Exercise(id: 'aud_9_2_c', skillId: 'aud_9', prompt: 'اختر الخروف:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['خروف', 'بقرة', 'أسد'], correctAnswer: 'خروف', audioAsset: 'audio/sheep.mp3', imageAsset: 'assets/images/sheep.png'),
        ],
        [
          Exercise(id: 'aud_9_3_a', skillId: 'aud_9', prompt: 'من يركض بسرعة؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['حصان', 'حمار', 'جمل'], correctAnswer: 'حصان', audioAsset: 'audio/horse.mp3', imageAsset: 'assets/images/horse.png'),
          Exercise(id: 'aud_9_3_b', skillId: 'aud_9', prompt: 'صوت الحصان وين؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['حصان', 'فيل', 'نمر'], correctAnswer: 'حصان', audioAsset: 'audio/horse.mp3', imageAsset: 'assets/images/horse.png'),
          Exercise(id: 'aud_9_3_c', skillId: 'aud_9', prompt: 'اختر الحصان القوي:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['حصان', 'بقرة', 'كلب'], correctAnswer: 'حصان', audioAsset: 'audio/horse.mp3', imageAsset: 'assets/images/horse.png'),
        ],
        [
          Exercise(id: 'aud_9_4_a', skillId: 'aud_9', prompt: 'من يقول مياو؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['قطة', 'كلب', 'نمر'], correctAnswer: 'قطة', audioAsset: 'audio/cat.mp3', imageAsset: 'assets/images/cat.png'),
          Exercise(id: 'aud_9_4_b', skillId: 'aud_9', prompt: 'صوت القطة وين؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['قطة', 'عصفور', 'دجاجة'], correctAnswer: 'قطة', audioAsset: 'audio/cat.mp3', imageAsset: 'assets/images/cat.png'),
          Exercise(id: 'aud_9_4_c', skillId: 'aud_9', prompt: 'اختر القطة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['قطة', 'خروف', 'بقرة'], correctAnswer: 'قطة', audioAsset: 'audio/cat.mp3', imageAsset: 'assets/images/cat.png'),
        ],
        [
          Exercise(id: 'aud_9_5_a', skillId: 'aud_9', prompt: 'من يحرس البيت؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['كلب', 'ذئب', 'ثعلب'], correctAnswer: 'كلب', audioAsset: 'audio/dog.mp3', imageAsset: 'assets/images/dog.png'),
          Exercise(id: 'aud_9_5_b', skillId: 'aud_9', prompt: 'صوت الكلب وين؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['كلب', 'قطة', 'حصان'], correctAnswer: 'كلب', audioAsset: 'audio/dog.mp3', imageAsset: 'assets/images/dog.png'),
          Exercise(id: 'aud_9_5_c', skillId: 'aud_9', prompt: 'اختر الكلب الوفي:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['كلب', 'خروف', 'بقرة'], correctAnswer: 'كلب', audioAsset: 'audio/dog.mp3', imageAsset: 'assets/images/dog.png'),
        ],
        [
          Exercise(id: 'aud_9_6_a', skillId: 'aud_9', prompt: 'صوت من هذا الجميل؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['عصفور', 'دجاجة', 'بطة'], correctAnswer: 'عصفور', audioAsset: 'audio/bird.mp3', imageAsset: 'assets/images/bird.png'),
          Exercise(id: 'aud_9_6_b', skillId: 'aud_9', prompt: 'مين يغني فوق الشجرة؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['عصفور', 'حمامة', 'غراب'], correctAnswer: 'عصفور', audioAsset: 'audio/bird.mp3', imageAsset: 'assets/images/bird.png'),
          Exercise(id: 'aud_9_6_c', skillId: 'aud_9', prompt: 'اختر العصفور:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['عصفور', 'بطة', 'قطة'], correctAnswer: 'عصفور', audioAsset: 'audio/bird.mp3', imageAsset: 'assets/images/bird.png'),
        ],
        [
          Exercise(id: 'aud_9_7_a', skillId: 'aud_9', prompt: 'شو هذي السيارة؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['سيارة', 'شاحنة', 'دراجة'], correctAnswer: 'سيارة', audioAsset: 'audio/car.mp3', imageAsset: 'assets/images/car.png'),
          Exercise(id: 'aud_9_7_b', skillId: 'aud_9', prompt: 'صوت السيارة وين؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['سيارة', 'قطار', 'طائرة'], correctAnswer: 'سيارة', audioAsset: 'audio/car.mp3', imageAsset: 'assets/images/car.png'),
          Exercise(id: 'aud_9_7_c', skillId: 'aud_9', prompt: 'اختر السيارة:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['سيارة', 'سفينة', 'دراجة'], correctAnswer: 'سيارة', audioAsset: 'audio/car.mp3', imageAsset: 'assets/images/car.png'),
        ],
        [
          Exercise(id: 'aud_9_8_a', skillId: 'aud_9', prompt: 'طوط طوط... من القادم؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['قطار', 'سفينة', 'طائرة'], correctAnswer: 'قطار', audioAsset: 'audio/toy train.mp3'),
          Exercise(id: 'aud_9_8_b', skillId: 'aud_9', prompt: 'صوت القطار وين؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['قطار', 'سيارة', 'شاحنة'], correctAnswer: 'قطار', audioAsset: 'audio/toy train.mp3'),
          Exercise(id: 'aud_9_8_c', skillId: 'aud_9', prompt: 'اختر القطار السريع:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['قطار', 'طائرة', 'دراجة'], correctAnswer: 'قطار', audioAsset: 'audio/toy train.mp3'),
        ],
        [
          Exercise(id: 'aud_9_9_a', skillId: 'aud_9', prompt: 'هذا صوت المطر؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', audioAsset: 'audio/rain.mp3'),
          Exercise(id: 'aud_9_9_b', skillId: 'aud_9', prompt: 'هل تسمع المطر؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', audioAsset: 'audio/rain.mp3'),
          Exercise(id: 'aud_9_9_c', skillId: 'aud_9', prompt: 'هذا مطر؟', type: ExerciseType.trueFalse, difficulty: difficulty, correctAnswer: 'نعم', audioAsset: 'audio/rain.mp3'),
        ],
        [
          Exercise(id: 'aud_9_10_a', skillId: 'aud_9', prompt: 'من يطرق الباب؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['طرق باب', 'جرس', 'هاتف'], correctAnswer: 'طرق باب', audioAsset: 'audio/knocking door.mp3'),
          Exercise(id: 'aud_9_10_b', skillId: 'aud_9', prompt: 'وين صوت الطرق؟', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['طرق باب', 'ساعة', 'مكنسة'], correctAnswer: 'طرق باب', audioAsset: 'audio/knocking door.mp3'),
          Exercise(id: 'aud_9_10_c', skillId: 'aud_9', prompt: 'اختر طرق الباب:', type: ExerciseType.multipleChoice, difficulty: difficulty, options: ['طرق باب', 'جرس', 'هواء'], correctAnswer: 'طرق باب', audioAsset: 'audio/knocking door.mp3'),
        ],
      ];
      return createStage(skillId, pools);
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