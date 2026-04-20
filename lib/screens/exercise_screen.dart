import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/exercise_provider.dart';
import '../models/exercise_model.dart';
import '../services/audio_service.dart';
import '../utils/theme.dart';

class ExerciseScreen extends StatefulWidget {
  final String skillId;
  final String skillTitle;

  const ExerciseScreen({super.key, required this.skillId, required this.skillTitle});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExerciseProvider>().loadExercises(widget.skillId, Difficulty.easy);
    });
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
                  _buildMultipleChoiceOptions(provider, exercise.options),
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
                SizedBox(
                  height: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) => _AnimatedBar(delay: index * 100)),
                  ),
                ),
                InkWell(
                  onTap: () => AudioService.instance.speak(exercise.ttsText),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: EchoLearnTheme.accentCyan.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: EchoLearnTheme.accentCyan.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: const Icon(Icons.graphic_eq, size: 60, color: EchoLearnTheme.accentCyan),
                  ),
                ),
              ],
            );
          }
        ),
        const SizedBox(height: 16),
        const Text(
          'اضغط لتحليل الإشارة السمعية', 
          style: TextStyle(color: EchoLearnTheme.primaryNavy, fontWeight: FontWeight.bold)
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

  Widget _buildCompletion(ExerciseProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars, size: 100, color: Colors.orange),
          const SizedBox(height: 24),
          const Text(
            'أحسنت! لقد أكملت التمرين',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'درجتك: ${provider.score}%',
            style: const TextStyle(fontSize: 40, color: EchoLearnTheme.primaryNavy, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('العودة للقائمة الرئيسية'),
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
