/// Immutable metrics payload for Knowledge DNA UI cards.
class KnowledgeDNAMetrics {
  const KnowledgeDNAMetrics({
    required this.knowledgeScore,
    required this.confidenceScore,
    required this.retentionScore,
    required this.learningVelocity,
    required this.summary,
  });

  final double knowledgeScore;
  final double confidenceScore;
  final double retentionScore;
  final double learningVelocity;
  final String summary;
}
