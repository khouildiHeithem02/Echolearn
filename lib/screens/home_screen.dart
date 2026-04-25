import 'package:flutter/material.dart';
import '../models/skill_category.dart';
import '../utils/theme.dart';
import 'exercise_screen.dart'; // We'll create this next
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auditorySkills = SkillCategory.all.where((s) => s.type == SkillType.auditory).toList();
    final languageSkills = SkillCategory.all.where((s) => s.type == SkillType.language).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('إيكوليرن - EchoLearn'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [EchoLearnTheme.primaryNavy, EchoLearnTheme.accentCyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.record_voice_over, size: 80, color: Colors.white24),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader('المهارات السمعية', Icons.hearing),
                _buildSkillGrid(context, auditorySkills),
                const SizedBox(height: 24),
                _buildSectionHeader('المهارات اللغوية', Icons.language),
                _buildSkillGrid(context, languageSkills),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: EchoLearnTheme.primaryNavy),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: EchoLearnTheme.primaryNavy),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillGrid(BuildContext context, List<SkillCategory> skills) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        return InkWell(
          onTap: () => _navigateToExercise(context, skill),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: EchoLearnTheme.primaryNavy.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      skill.type == SkillType.auditory ? Icons.graphic_eq : Icons.chat_bubble_outline,
                      color: EchoLearnTheme.primaryNavy,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    skill.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    skill.description,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToExercise(BuildContext context, SkillCategory skill) {
    // Show difficulty selection dialog or just go to easy
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseScreen(skillId: skill.id, skillTitle: skill.title),
      ),
    );
  }
}
