import '../../../core/sample_repository.dart';
import '../../knowledge_dna/knowledge_dna_service.dart';
import '../models/growth_dimension.dart';
import '../models/growth_metrics.dart';
import '../models/growth_trend.dart';
import 'growth_calculator.dart';

/// Calculates knowledge growth from Knowledge DNA analysis.
///
/// Delegates to [KnowledgeDNAService] which derives the score from
/// mission completion, progress level, and learning velocity.
class KnowledgeCalculator implements GrowthCalculator {
  KnowledgeCalculator({
    KnowledgeDNAService? knowledgeService,
  }) : _knowledgeService = knowledgeService ??
            KnowledgeDNAService(repository: const SampleRepository());

  final KnowledgeDNAService _knowledgeService;

  GrowthMetrics? _previous;

  @override
  GrowthMetrics calculate() {
    final analysis = _knowledgeService.buildAnalysis();
    final score = analysis.knowledgeScore.clamp(0.0, 1.0);
    final previous = _previous;
    final trend = previous != null
        ? GrowthTrend.fromScores(score, previous.score)
        : GrowthTrend.stable;

    _previous = GrowthMetrics(
      dimension: GrowthDimension.knowledge,
      score: score,
      trend: trend,
      previousScore: previous?.score,
      label: '${(analysis.confidenceScore * 100).round()}% confidence',
      detail: 'Learning velocity: ${analysis.learningVelocity.toStringAsFixed(1)}',
    );

    return _previous!;
  }

  @override
  GrowthMetrics? get previousMetrics => _previous;
}
