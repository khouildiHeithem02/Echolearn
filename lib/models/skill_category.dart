enum SkillType { auditory, language }

class SkillCategory {
  final String id;
  final String title;
  final String description;
  final SkillType type;
  final String iconPath;

  SkillCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.iconPath = '',
  });

  static List<SkillCategory> get all => [
    // Auditory Skills (9)
    SkillCategory(
      id: 'aud_1',
      title: 'التمييز بين الأصوات',
      description: 'الفروق الدقيقة بين الفونيمات وتحليل الإشارة السمعية',
      type: SkillType.auditory,
    ),
    SkillCategory(
      id: 'aud_2',
      title: 'التمييز بين الحروف والمقاطع',
      description: 'الحروف المتشابهة وإدراك المقاطع داخل الكلمة',
      type: SkillType.auditory,
    ),
    SkillCategory(
      id: "aud_3",
      title: "الصوت المستمر والمتقطع",
      description: "التمييز بين طول ونوع الصوت",
      type: SkillType.auditory,
    ),
    SkillCategory(
      id: "aud_4",
      title: "الكلمات المتشابهة",
      description: "التفريق بين الكلمات المتقاربة صوتياً",
      type: SkillType.auditory,
    ),
    SkillCategory(
      id: "aud_5",
      title: "التمييز السمعي البصري",
      description: "ربط الصوت بالصورة أو الحرف",
      type: SkillType.auditory,
    ),
    SkillCategory(
      id: "aud_6",
      title: "النبرة والإيقاع والتنغيم",
      description: "تمييز نوع الجملة من اللحن الصوتي",
      type: SkillType.auditory,
    ),
    SkillCategory(
      id: "aud_7",
      title: "الذاكرة السمعية",
      description: "الاحتفاظ بالمعلومات الصوتية واسترجاعها",
      type: SkillType.auditory,
    ),
    SkillCategory(
      id: "aud_8",
      title: "الوعي الصوتي",
      description: "تحليل الكلمة إلى أصوات ومكونات",
      type: SkillType.auditory,
    ),
    SkillCategory(
      id: "aud_9",
      title: "أصوات البيئة",
      description: "تمييز أصوات الحيوانات والطبيعة",
      type: SkillType.auditory,
    ),

    // Language Skills (8)
    SkillCategory(
      id: 'lang_1',
      title: 'الفهم السمعي',
      description: 'استيعاب التعليمات والقصص والأوامر',
      type: SkillType.language,
    ),
    SkillCategory(
      id: 'lang_2',
      title: 'التعبير وبناء الجمل',
      description: 'القدرة على تركيب جمل صحيحة',
      type: SkillType.language,
    ),
    SkillCategory(
      id: 'lang_3',
      title: 'المعالجة اللغوية',
      description: 'فهم المترادفات والأضداد وتحليل الجمل',
      type: SkillType.language,
    ),
    SkillCategory(
      id: 'lang_4',
      title: 'تسمية الأشياء',
      description: 'تسمية الصور بمساعدة مؤشرات صوتية',
      type: SkillType.language,
    ),
    SkillCategory(
      id: 'lang_5',
      title: 'التوافق بين الجملة والصورة',
      description: 'تحديد صحة الجملة بناءً على الصورة',
      type: SkillType.language,
    ),
    SkillCategory(
      id: 'lang_6',
      title: 'القصص المسموعة',
      description: 'الإجابة على أسئلة حول قصة قصيرة',
      type: SkillType.language,
    ),
    SkillCategory(
      id: 'lang_7',
      title: 'التعبير عن الصور',
      description: 'وصف مشاهد بسيطة مسموعة أو مرئية',
      type: SkillType.language,
    ),
    SkillCategory(
      id: 'lang_8',
      title: 'ترتيب الجمل والفقرات',
      description: 'ترتيب حروف أو كلمات مبعثرة',
      type: SkillType.language,
    ),
  ];
}
