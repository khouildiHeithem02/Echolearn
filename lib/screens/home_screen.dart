import 'package:flutter/material.dart';
import '../models/skill_category.dart';
import '../utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'exercise_screen.dart'; 
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
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: EchoLearnTheme.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [EchoLearnTheme.primaryBlue, EchoLearnTheme.accentYellow],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5)
                        ],
                      ),
                      child: const Icon(Icons.face_retouching_natural, size: 60, color: EchoLearnTheme.softCoral),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'إيكوليرن - EchoLearn',
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [const Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(2, 2))],
                      ),
                    ),
                  ],
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
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: EchoLearnTheme.primaryBlue.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: EchoLearnTheme.primaryNavy, size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: EchoLearnTheme.primaryNavy
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillGrid(BuildContext context, List<SkillCategory> skills) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        
        return InkWell(
          onTap: () => _navigateToExercise(context, skill),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: EchoLearnTheme.primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      skill.type == SkillType.auditory ? Icons.hearing : Icons.forum,
                      color: EchoLearnTheme.primaryNavy,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    skill.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 12,
                      color: EchoLearnTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    skill.description,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
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
