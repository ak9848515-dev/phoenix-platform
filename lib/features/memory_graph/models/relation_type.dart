/// Types of relationships between entities in the Memory Graph.
///
/// Relationships are directional. `isDirected` indicates whether
/// direction matters (e.g. "dependsOn" from A→B means A depends on B).
///
/// Architecture supports unlimited future types — just add a new
/// enum value.
enum RelationType {
  dependsOn,
  relatedTo,
  createdBy,
  completedBy,
  learnedFrom,
  leadsTo,
  blocks,
  strengthens,
  weakens,
  references,
  parent,
  child,
  similar,
  associated,
  custom;

  String get label {
    switch (this) {
      case RelationType.dependsOn:
        return 'Depends On';
      case RelationType.relatedTo:
        return 'Related To';
      case RelationType.createdBy:
        return 'Created By';
      case RelationType.completedBy:
        return 'Completed By';
      case RelationType.learnedFrom:
        return 'Learned From';
      case RelationType.leadsTo:
        return 'Leads To';
      case RelationType.blocks:
        return 'Blocks';
      case RelationType.strengthens:
        return 'Strengthens';
      case RelationType.weakens:
        return 'Weakens';
      case RelationType.references:
        return 'References';
      case RelationType.parent:
        return 'Parent';
      case RelationType.child:
        return 'Child';
      case RelationType.similar:
        return 'Similar';
      case RelationType.associated:
        return 'Associated';
      case RelationType.custom:
        return 'Custom';
    }
  }

  /// Whether this relationship type is directional.
  bool get isDirected {
    switch (this) {
      case RelationType.dependsOn:
      case RelationType.createdBy:
      case RelationType.completedBy:
      case RelationType.learnedFrom:
      case RelationType.leadsTo:
      case RelationType.blocks:
      case RelationType.strengthens:
      case RelationType.weakens:
      case RelationType.parent:
      case RelationType.child:
        return true;
      case RelationType.relatedTo:
      case RelationType.references:
      case RelationType.similar:
      case RelationType.associated:
      case RelationType.custom:
        return false;
    }
  }

  /// Returns the inverse relation type (for directed relations).
  RelationType? get inverse {
    switch (this) {
      case RelationType.dependsOn:
        return null; // Not a simple inverse
      case RelationType.createdBy:
        return null;
      case RelationType.completedBy:
        return null;
      case RelationType.learnedFrom:
        return null;
      case RelationType.leadsTo:
        return null;
      case RelationType.blocks:
        return null;
      case RelationType.strengthens:
        return RelationType.weakens;
      case RelationType.weakens:
        return RelationType.strengthens;
      case RelationType.parent:
        return RelationType.child;
      case RelationType.child:
        return RelationType.parent;
      case RelationType.relatedTo:
      case RelationType.references:
      case RelationType.similar:
      case RelationType.associated:
      case RelationType.custom:
        return null;
    }
  }

  static RelationType fromString(String value) {
    return RelationType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => RelationType.associated,
    );
  }
}
