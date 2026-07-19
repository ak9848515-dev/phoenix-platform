/// Company intelligence profile for opportunity matching.
///
/// Provides company overview, required/preferred skills, interview
/// difficulty, culture, growth potential, technology stack, and
/// career fit assessment.
class OpportunityCompanyProfile {
  const OpportunityCompanyProfile({
    required this.id,
    required this.name,
    this.industry = '',
    this.overview = '',
    this.requiredSkills = const [],
    this.preferredSkills = const [],
    this.interviewDifficulty = 0.5,
    this.culture = '',
    this.growthPotential = 0.5,
    this.technologyStack = const [],
    this.careerFitScore = 0.0,
    this.location = '',
    this.size = '',
    this.fundingStage = '',
  });

  /// Unique identifier.
  final String id;

  /// Company name.
  final String name;

  /// Industry sector.
  final String industry;

  /// Company overview / description.
  final String overview;

  /// Required skills for roles at this company.
  final List<String> requiredSkills;

  /// Preferred / nice-to-have skills.
  final List<String> preferredSkills;

  /// Interview difficulty rating (0.0 – 1.0).
  final double interviewDifficulty;

  /// Company culture description.
  final String culture;

  /// Growth potential score (0.0 – 1.0).
  final double growthPotential;

  /// Technologies used at the company.
  final List<String> technologyStack;

  /// How well the company fits the user's career path (0.0 – 1.0).
  final double careerFitScore;

  /// Geographic location.
  final String location;

  /// Company size (e.g. '10-50', '1000+').
  final String size;

  /// Funding stage (e.g. 'Seed', 'Series A', 'Public').
  final String fundingStage;

  /// Creates a copy with the given fields replaced.
  OpportunityCompanyProfile copyWith({
    String? id,
    String? name,
    String? industry,
    String? overview,
    List<String>? requiredSkills,
    List<String>? preferredSkills,
    double? interviewDifficulty,
    String? culture,
    double? growthPotential,
    List<String>? technologyStack,
    double? careerFitScore,
    String? location,
    String? size,
    String? fundingStage,
  }) {
    return OpportunityCompanyProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      industry: industry ?? this.industry,
      overview: overview ?? this.overview,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      preferredSkills: preferredSkills ?? this.preferredSkills,
      interviewDifficulty: interviewDifficulty ?? this.interviewDifficulty,
      culture: culture ?? this.culture,
      growthPotential: growthPotential ?? this.growthPotential,
      technologyStack: technologyStack ?? this.technologyStack,
      careerFitScore: careerFitScore ?? this.careerFitScore,
      location: location ?? this.location,
      size: size ?? this.size,
      fundingStage: fundingStage ?? this.fundingStage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is OpportunityCompanyProfile && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'OpportunityCompanyProfile(id: $id, name: $name, fit: $careerFitScore)';
}
