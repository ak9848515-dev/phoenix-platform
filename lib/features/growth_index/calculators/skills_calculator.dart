import '../../../core/sample_repository.dart';
import '../../knowledge_dna/knowledge_dna_service.dart';
import '../models/growth_dimension.dart';
import '../models/growth_metrics.dart';
import '../models/growth_trend.dart';
import 'growth_calculator.dart';

/// Calculates practical skills proficiency from Knowledge DNA analysis.
///
/// Skills score is derived from the ratio of skill strengths to total
/// identified skills (strengths + weaknesses).
class SkillsCalculator implements GrowthCalculator {
  SkillsCalculator({
    KnowledgeDNAService? knowledgeService,
  }) : _knowledgeService = knowledgeService ??
            KnowledgeDNAService(repository: const SampleRepository());

  final KnowledgeDNAService _knowledgeService;

  GrowthMetrics? _previous;

  @override
  GrowthMetrics calculate() {
    final analysis = _knowledgeService.buildAnalysis();
    final strengths = analysis.skillStrengths.length;
    final weaknesses = analysis.skillWeaknesses.length;
    final total = strengths + weaknesses;
    final score = total > 0
        ? (strengths / total * 0.7 + analysis.confidenceScore * 0.3).clamp(0.0, 1.0)
        : 0.0;
    final previous = _previous;
    final trend = previous != null
        ? GrowthTrend.fromScores(score, previous.score)
        : GrowthTrend.stable;

    _previous = GrowthMetrics(
      dimension: GrowthDimension.skills,
      score: score,
      trend: trend,
      previousScore: previous?.score,
      label: '$strengths strengths, $weaknesses to improve',
      detail: '${total > 0 ? (strengths / total * 100).round() : 0}% proficiency',
    );

    return _previous!;
  }

  @override
  GrowthMetrics? get previousMetrics => _previous;
}
