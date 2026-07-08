/// Immutable recommendation model for Knowledge DNA recommendations.
class KnowledgeDNARecommendation {
  const KnowledgeDNARecommendation({
    required this.title,
    required this.description,
    required this.kind,
  });

  final String title;
  final String description;
  final String kind;
}
