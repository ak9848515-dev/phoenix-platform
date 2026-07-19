/// Comprehensive profile describing the user's identity, goals, and preferences.
///
/// [IdentityProfile] is the single source of truth for who the user is and
/// who they want to become. It aggregates data from [Identity], journey,
/// and onboarding selections into one unified model.
///
/// **Sections:**
/// - Personal: Name, DOB, Gender, Country, Language
/// - Professional: Profession, Experience, Education, Industry
/// - Growth: Goals, Aspirations, Interests, Skills, Daily available time, Learning preferences
/// - AI: AI Preferences, Provider Preferences
///
/// Immutable. Use [copyWith] to produce modified copies.
class IdentityProfile {
  const IdentityProfile({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.category,
    required this.currentLevel,
    required this.targetLevel,
    required this.careerGoal,
    required this.experienceLevel,
    this.learningStyle = const [],
    this.interests = const [],
    this.strengths = const [],
    this.weaknesses = const [],
    this.preferredLanguage = 'en',
    this.preferredDifficulty = 'intermediate',
    this.preferredMissionLength = 'medium',
    // ── Personal ─────────────────────────────────────────────────
    this.fullName = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.country = '',
    this.language = 'en',
    // ── Professional ─────────────────────────────────────────────
    this.profession = '',
    this.professionalExperience = '',
    this.education = '',
    this.industry = '',
    // ── Growth ───────────────────────────────────────────────────
    this.goals = const [],
    this.aspirations = const [],
    this.skills = const [],
    this.dailyAvailableMinutes = 30,
    this.learningPreferences = const [],
    // ── AI ───────────────────────────────────────────────────────
    this.aiPreferences = const [],
    this.preferredAIProvider = '',
    this.aiModelPreference = '',
  });

  /// Unique identifier matching the parent [Identity.id].
  final String id;

  /// Display name (e.g. "Software Engineer").
  final String title;

  /// Short description of this identity.
  final String description;

  /// Icon identifier for visual representation.
  final String iconName;

  /// Category grouping (e.g. "Technology", "Business", "Creative").
  final String category;

  /// Current proficiency level.
  final int currentLevel;

  /// Target proficiency level.
  final int targetLevel;

  /// The user's primary career goal.
  final String careerGoal;

  /// Current experience level (beginner, intermediate, advanced, expert).
  final String experienceLevel;

  /// Preferred learning styles (e.g. ["mission", "reading", "video"]).
  final List<String> learningStyle;

  /// User's areas of interest.
  final List<String> interests;

  /// User's identified strengths.
  final List<String> strengths;

  /// User's identified areas for growth.
  final List<String> weaknesses;

  /// Preferred language code (e.g. "en").
  final String preferredLanguage;

  /// Preferred content difficulty (beginner, intermediate, advanced, expert).
  final String preferredDifficulty;

  /// Preferred mission length (short, medium, long).
  final String preferredMissionLength;

  // ── Personal Section ─────────────────────────────────────────────

  /// User's full name.
  final String fullName;

  /// Date of birth (ISO format string).
  final String dateOfBirth;

  /// Gender identity.
  final String gender;

  /// Country of residence.
  final String country;

  /// Primary language.
  final String language;

  // ── Professional Section ─────────────────────────────────────────

  /// Current or target profession.
  final String profession;

  /// Years or description of professional experience.
  final String professionalExperience;

  /// Highest education level or degree.
  final String education;

  /// Industry of work.
  final String industry;

  // ── Growth Section ───────────────────────────────────────────────

  /// List of personal and professional goals.
  final List<String> goals;

  /// List of aspirations and dreams.
  final List<String> aspirations;

  /// List of skills (current and desired).
  final List<String> skills;

  /// Daily available time for learning in minutes.
  final int dailyAvailableMinutes;

  /// Learning preferences (e.g. ["morning", "visual", "hands-on"]).
  final List<String> learningPreferences;

  // ── AI Section ───────────────────────────────────────────────────

  /// AI-related preferences (e.g. ["concise", "detailed", "creative"]).
  final List<String> aiPreferences;

  /// Preferred AI provider ID.
  final String preferredAIProvider;

  /// Preferred AI model name.
  final String aiModelPreference;

  /// The total number of levels to progress through.
  int get totalLevels => targetLevel;

  /// Remaining levels to reach the target.
  int get remainingLevels => (targetLevel - currentLevel).clamp(0, targetLevel);

  /// Progress toward the target level as a fraction (0.0–1.0).
  double get completionRatio =>
      targetLevel > 0 ? (currentLevel / targetLevel).clamp(0.0, 1.0) : 0.0;

  /// Creates a copy with the given fields replaced.
  IdentityProfile copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    String? category,
    int? currentLevel,
    int? targetLevel,
    String? careerGoal,
    String? experienceLevel,
    List<String>? learningStyle,
    List<String>? interests,
    List<String>? strengths,
    List<String>? weaknesses,
    String? preferredLanguage,
    String? preferredDifficulty,
    String? preferredMissionLength,
    // Personal
    String? fullName,
    String? dateOfBirth,
    String? gender,
    String? country,
    String? language,
    // Professional
    String? profession,
    String? professionalExperience,
    String? education,
    String? industry,
    // Growth
    List<String>? goals,
    List<String>? aspirations,
    List<String>? skills,
    int? dailyAvailableMinutes,
    List<String>? learningPreferences,
    // AI
    List<String>? aiPreferences,
    String? preferredAIProvider,
    String? aiModelPreference,
  }) {
    return IdentityProfile(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      category: category ?? this.category,
      currentLevel: currentLevel ?? this.currentLevel,
      targetLevel: targetLevel ?? this.targetLevel,
      careerGoal: careerGoal ?? this.careerGoal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      learningStyle: learningStyle ?? this.learningStyle,
      interests: interests ?? this.interests,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredDifficulty: preferredDifficulty ?? this.preferredDifficulty,
      preferredMissionLength:
          preferredMissionLength ?? this.preferredMissionLength,
      // Personal
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      language: language ?? this.language,
      // Professional
      profession: profession ?? this.profession,
      professionalExperience: professionalExperience ?? this.professionalExperience,
      education: education ?? this.education,
      industry: industry ?? this.industry,
      // Growth
      goals: goals ?? this.goals,
      aspirations: aspirations ?? this.aspirations,
      skills: skills ?? this.skills,
      dailyAvailableMinutes: dailyAvailableMinutes ?? this.dailyAvailableMinutes,
      learningPreferences: learningPreferences ?? this.learningPreferences,
      // AI
      aiPreferences: aiPreferences ?? this.aiPreferences,
      preferredAIProvider: preferredAIProvider ?? this.preferredAIProvider,
      aiModelPreference: aiModelPreference ?? this.aiModelPreference,
    );
  }

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'iconName': iconName,
    'category': category,
    'currentLevel': currentLevel,
    'targetLevel': targetLevel,
    'careerGoal': careerGoal,
    'experienceLevel': experienceLevel,
    'learningStyle': learningStyle,
    'interests': interests,
    'strengths': strengths,
    'weaknesses': weaknesses,
    'preferredLanguage': preferredLanguage,
    'preferredDifficulty': preferredDifficulty,
    'preferredMissionLength': preferredMissionLength,
    // Personal
    'fullName': fullName,
    'dateOfBirth': dateOfBirth,
    'gender': gender,
    'country': country,
    'language': language,
    // Professional
    'profession': profession,
    'professionalExperience': professionalExperience,
    'education': education,
    'industry': industry,
    // Growth
    'goals': goals,
    'aspirations': aspirations,
    'skills': skills,
    'dailyAvailableMinutes': dailyAvailableMinutes,
    'learningPreferences': learningPreferences,
    // AI
    'aiPreferences': aiPreferences,
    'preferredAIProvider': preferredAIProvider,
    'aiModelPreference': aiModelPreference,
  };

  /// Creates from a JSON-compatible map.
  factory IdentityProfile.fromMap(Map<String, dynamic> map) => IdentityProfile(
    id: map['id'] as String,
    title: map['title'] as String,
    description: map['description'] as String? ?? '',
    iconName: map['iconName'] as String? ?? 'circle_outlined',
    category: map['category'] as String? ?? 'General',
    currentLevel: map['currentLevel'] as int? ?? 1,
    targetLevel: map['targetLevel'] as int? ?? 5,
    careerGoal: map['careerGoal'] as String? ?? '',
    experienceLevel: map['experienceLevel'] as String? ?? 'beginner',
    learningStyle: (map['learningStyle'] as List<dynamic>?)
            ?.cast<String>() ?? [],
    interests:
        (map['interests'] as List<dynamic>?)?.cast<String>() ?? [],
    strengths:
        (map['strengths'] as List<dynamic>?)?.cast<String>() ?? [],
    weaknesses:
        (map['weaknesses'] as List<dynamic>?)?.cast<String>() ?? [],
    preferredLanguage: map['preferredLanguage'] as String? ?? 'en',
    preferredDifficulty:
        map['preferredDifficulty'] as String? ?? 'intermediate',
    preferredMissionLength:
        map['preferredMissionLength'] as String? ?? 'medium',
    // Personal
    fullName: map['fullName'] as String? ?? '',
    dateOfBirth: map['dateOfBirth'] as String? ?? '',
    gender: map['gender'] as String? ?? '',
    country: map['country'] as String? ?? '',
    language: map['language'] as String? ?? 'en',
    // Professional
    profession: map['profession'] as String? ?? '',
    professionalExperience: map['professionalExperience'] as String? ?? '',
    education: map['education'] as String? ?? '',
    industry: map['industry'] as String? ?? '',
    // Growth
    goals: (map['goals'] as List<dynamic>?)?.cast<String>() ?? [],
    aspirations: (map['aspirations'] as List<dynamic>?)?.cast<String>() ?? [],
    skills: (map['skills'] as List<dynamic>?)?.cast<String>() ?? [],
    dailyAvailableMinutes: map['dailyAvailableMinutes'] as int? ?? 30,
    learningPreferences: (map['learningPreferences'] as List<dynamic>?)?.cast<String>() ?? [],
    // AI
    aiPreferences: (map['aiPreferences'] as List<dynamic>?)?.cast<String>() ?? [],
    preferredAIProvider: map['preferredAIProvider'] as String? ?? '',
    aiModelPreference: map['aiModelPreference'] as String? ?? '',
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdentityProfile && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'IdentityProfile(id: $id, title: $title, '
      'level: $currentLevel/$targetLevel, goal: $careerGoal)';
}