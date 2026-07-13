import 'opportunity_gap.dart';
import 'opportunity_requirement.dart';

/// Immutable representation of the match between the user and an opportunity.
class OpportunityMatch {
  const OpportunityMatch({
    required this.opportunityId,
    this.matchScore = 0.0,
    this.requirements = const [],
    this.gaps = const [],
  });

  /// The opportunity this match is for.
  final String opportunityId;

  /// Overall match score from 0.0 to 1.0.
  final double matchScore;

  /// Requirement-by-requirement breakdown.
  final List<OpportunityRequirement> requirements;

  /// Identified skill gaps.
  final List<OpportunityGap> gaps;

  /// Number of matched requirements.
  int get matchedCount => requirements.where((r) => r.isMatched).length;

  /// Number of unmatched requirements.
  int get unmatchedCount => requirements.where((r) => !r.isMatched).length;

  /// Creates a copy with the given fields replaced.
  OpportunityMatch copyWith({
    String? opportunityId,
    double? matchScore,
    List<OpportunityRequirement>? requirements,
    List<OpportunityGap>? gaps,
  }) {
    return OpportunityMatch(
      opportunityId: opportunityId ?? this.opportunityId,
      matchScore: matchScore ?? this.matchScore,
      requirements: requirements ?? this.requirements,
      gaps: gaps ?? this.gaps,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpportunityMatch && other.opportunityId == opportunityId;
  }

  @override
  int get hashCode => opportunityId.hashCode;

  @override
  String toString() =>
      'OpportunityMatch(id: $opportunityId, score: $matchScore)';
}
