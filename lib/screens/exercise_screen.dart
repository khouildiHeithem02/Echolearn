import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/exercise_provider.dart';
import '../models/exercise_model.dart';
import '../services/audio_service.dart';
import '../utils/theme.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

class ExerciseScreen extends StatefulWidget {
  final String skillId;
  final String skillTitle;

  const ExerciseScreen({super.key, required this.skillId, required this.skillTitle});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  double _level = 0.0;
  String _currentExerciseId = ''; // Track which question is active
  bool _isPlayingAudio = false;  // Prevent double-play
  List<String> _shuffledOptions = []; // Shuffled options for the current exercise

  @override
  void initState() {
    super.initState();
    _initSpeech();
    // Listen for audio completion to reset the playing flag
    AudioService.instance.player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlayingAudio = false);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExerciseProvider>().loadExercises(widget.skillId, Difficulty.easy);
    });
  }

  void _initSpeech() async {
    try {
      await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (errorNotification) {
          setState(() => _isListening = false);
          print('Speech Error: $errorNotification');
        },
      );
    } catch (e) {
      print('Speech Init Error: $e');
    }
  }

  void _listen() async {
    if (!_isListening) {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        bool available = await _speech.initialize();
        if (available) {
          setState(() {
            _isListening = true;
            _lastWords = '';
          });
          _speech.listen(
            onResult: (val) => setState(() {
              _lastWords = val.recognizedWords;
              if (val.finalResult) {
                _isListening = false;
                Future.delayed(const Duration(milliseconds: 500), () {
                  _checkSpeechResult(_lastWords);
                });
              }
            }),
            localeId: 'ar-SA',
            onSoundLevelChange: (level) => setState(() => _level = level),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب السماح باستخدام المايكروفون')),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _checkSpeechResult(String words) {
    if (words.isEmpty) return;
    
    final provider = context.read<ExerciseProvider>();
    final exercise = provider.currentExercise!;
    
    // Normalize Arabic (remove tashkeel and common variations)
    String normalize(String text) {
      return text
          .replaceAll(RegExp(r'[\u064B-\u065F]'), '') // Remove Tashkeel
          .replaceAll('أ', 'ا')
          .replaceAll('إ', 'ا')
          .replaceAll('آ', 'ا')
          .replaceAll('ة', 'ه')
          .replaceAll('ى', 'ي')
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .trim();
    }

    String normalizedResult = normalize(words);
    String normalizedAnswer = normalize(exercise.correctAnswer);
    
    if (normalizedResult == normalizedAnswer || 
        normalizedResult.contains(normalizedAnswer) || 
        normalizedAnswer.contains(normalizedResult)) {
      provider.submitAnswer(exercise.correctAnswer);
    } else {
      provider.submitAnswer(words);
    }
  }

  // Play audio/TTS once — ignore tap if already playing
  void _playExerciseAudio(Exercise exercise) {
    if (_isPlayingAudio) return; // Already playing, ignore
    setState(() => _isPlayingAudio = true);
    if (exercise.audioAsset.isNotEmpty) {
      AudioService.instance.playAsset(exercise.audioAsset);
      // Reset flag after a safe timeout in case onPlayerComplete doesn't fire
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) setState(() => _isPlayingAudio = false);
      });
    } else {
      if (exercise.isGentle) {
        AudioService.instance.speakGentle(exercise.ttsText);
      } else {
        AudioService.instance.speak(exercise.ttsText);
      }
      // TTS has no completion stream, reset after estimated duration
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _isPlayingAudio = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.skillTitle),
      ),
      body: Consumer<ExerciseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.currentExercise == null) {
            return _buildCompletion(provider);
          }

          final exercise = provider.currentExercise!;

          // Auto-play audio once when a new exercise appears
          if (exercise.id != _currentExerciseId) {
            _currentExerciseId = exercise.id;
            _isPlayingAudio = false;
            _lastWords = '';
            
            // Shuffle options for the new exercise
            _shuffledOptions = List<String>.from(exercise.options)..shuffle();
            
            Future.microtask(() => _playExerciseAudio(exercise));
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: provider.exercises.isEmpty 
                      ? 0 
                      : provider.currentIndex / provider.exercises.length,
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 10,
                ),
                const SizedBox(height: 40),
                Text(
                  exercise.prompt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                _buildInteractionArea(exercise),
                const Spacer(),
                if (exercise.type == ExerciseType.trueFalse)
                  _buildTrueFalseOptions(provider)
                else if (exercise.type == ExerciseType.multipleChoice)
                  _buildMultipleChoiceOptions(provider, _shuffledOptions)
                else if (exercise.type == ExerciseType.speak)
                  _buildSpeakOptions(provider, exercise),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInteractionArea(Exercise exercise) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                if (exercise.imageAsset.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        exercise.imageAsset,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                SizedBox(
                  height: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) => _AnimatedBar(delay: index * 100)),
                  ),
                ),
                InkWell(
                  onTap: () => _playExerciseAudio(exercise),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _isPlayingAudio
                          ? EchoLearnTheme.accentCyan.withValues(alpha: 0.25)
                          : EchoLearnTheme.accentCyan.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: EchoLearnTheme.accentCyan.withValues(
                              alpha: _isPlayingAudio ? 0.5 : 0.2),
                          blurRadius: _isPlayingAudio ? 30 : 20,
                          spreadRadius: _isPlayingAudio ? 8 : 5,
                        )
                      ],
                    ),
                    child: Icon(
                      _isPlayingAudio ? Icons.volume_up : Icons.play_circle_fill,
                      size: 60,
                      color: EchoLearnTheme.accentCyan,
                    ),
                  ),
                ),
              ],
            );
          }
        ),
        const SizedBox(height: 16),
        Text(
          _isPlayingAudio ? 'جاري تشغيل الصوت...' : 'اضغط لسماع الصوت مرة أخرى',
          style: TextStyle(
            color: _isPlayingAudio
                ? EchoLearnTheme.accentCyan
                : EchoLearnTheme.primaryNavy,
            fontWeight: FontWeight.bold,
          )
        ),
      ],
    );
  }
  Widget _buildTrueFalseOptions(ExerciseProvider provider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => provider.submitAnswer('نعم'),
            style: ElevatedButton.styleFrom(backgroundColor: EchoLearnTheme.successGreen),
            child: const Text('نعم/صحيح'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => provider.submitAnswer('لا'),
            style: ElevatedButton.styleFrom(backgroundColor: EchoLearnTheme.errorRed),
            child: const Text('لا/خطأ'),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceOptions(ExerciseProvider provider, List<String> options) {
    return Column(
      children: options.map((option) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: ElevatedButton(
          onPressed: () => provider.submitAnswer(option),
          child: Text(option),
        ),
      )).toList(),
    );
  }

  Widget _buildSpeakOptions(ExerciseProvider provider, Exercise exercise) {
    return Column(
      children: [
        if (_lastWords.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: EchoLearnTheme.accentCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'سمعت: $_lastWords',
              style: const TextStyle(fontSize: 18, color: EchoLearnTheme.primaryNavy, fontWeight: FontWeight.bold),
            ),
          ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _listen,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isListening)
                _buildRippleEffect(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _isListening ? EchoLearnTheme.errorRed : EchoLearnTheme.accentCyan,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? EchoLearnTheme.errorRed : EchoLearnTheme.accentCyan).withValues(alpha: 0.4),
                      blurRadius: 15,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _isListening ? 'جاري الاستماع... (اضغط للإيقاف)' : 'اضغط على المايك وابدأ التحدث',
          style: TextStyle(
            color: _isListening ? EchoLearnTheme.errorRed : EchoLearnTheme.primaryNavy,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildRippleEffect() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Container(
          width: 100 + (100 * value),
          height: 100 + (100 * value),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: EchoLearnTheme.errorRed.withValues(alpha: 1 - value),
              width: 2,
            ),
          ),
        );
      },
      onEnd: () {
        // This creates a continuous loop if combined with state, 
        // but for simplicity we'll let it be.
      },
    );
  }

  Widget _buildCompletion(ExerciseProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars, size: 80, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            'أحسنت! لقد أكملت التمرين',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            'درجتك: ${provider.scorePercentage}%',
            style: const TextStyle(fontSize: 36, color: EchoLearnTheme.primaryNavy, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'ملخص الإجابات:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: EchoLearnTheme.primaryNavy),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: provider.exercises.length,
              itemBuilder: (context, index) {
                final exercise = provider.exercises[index];
                final isCorrect = provider.userResults.length > index ? provider.userResults[index] : false;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? EchoLearnTheme.successGreen : EchoLearnTheme.errorRed,
                    ),
                    title: Text(
                      exercise.prompt,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الصوت: ${exercise.ttsText}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        if (!isCorrect)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'الإجابة الصحيحة: ${exercise.correctAnswer}',
                              style: const TextStyle(fontSize: 12, color: EchoLearnTheme.successGreen, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('العودة للقائمة الرئيسية'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBar extends StatefulWidget {
  final int delay;
  const _AnimatedBar({required this.delay});

  @override
  State<_AnimatedBar> createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<_AnimatedBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 10, end: 60).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: _animation.value,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: EchoLearnTheme.accentCyan,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}