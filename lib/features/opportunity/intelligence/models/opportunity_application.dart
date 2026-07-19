import 'opportunity_application_status.dart';

/// Tracks a user's application to a career opportunity through its lifecycle.
///
/// Supports: wishlist, applied, interview scheduled, offer received,
/// rejected, accepted — with full history timeline.
class OpportunityApplication {
  const OpportunityApplication({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    this.companyName = '',
    this.status = ApplicationStatus.wishlist,
    this.appliedAt,
    this.interviewAt,
    this.offerAt,
    this.rejectedAt,
    this.acceptedAt,
    this.notes = '',
    this.isRemote = false,
    this.location = '',
    this.salaryRange = '',
  });

  /// Unique identifier.
  final String id;

  /// The opportunity this application is for.
  final String opportunityId;

  /// Title of the opportunity.
  final String opportunityTitle;

  /// Company name.
  final String companyName;

  /// Current application status.
  final ApplicationStatus status;

  /// When the user applied.
  final DateTime? appliedAt;

  /// When the interview was scheduled.
  final DateTime? interviewAt;

  /// When the offer was received.
  final DateTime? offerAt;

  /// When the application was rejected.
  final DateTime? rejectedAt;

  /// When the offer was accepted.
  final DateTime? acceptedAt;

  /// User notes about this application.
  final String notes;

  /// Whether the position is remote.
  final bool isRemote;

  /// Location (if not remote).
  final String location;

  /// Salary range (e.g. '$80k-$120k').
  final String salaryRange;

  /// Human-readable status label.
  String get statusLabel => status.label;

  /// Whether this application is active (not rejected or accepted).
  bool get isActive =>
      status == ApplicationStatus.applied ||
      status == ApplicationStatus.interviewScheduled;

  /// Whether this application resulted in an offer.
  bool get hasOffer => status == ApplicationStatus.offerReceived ||
      status == ApplicationStatus.accepted;

  /// Days since applied (if applied).
  int? get daysSinceApplied {
    if (appliedAt == null) return null;
    return DateTime.now().difference(appliedAt!).inDays;
  }

  /// Creates a copy with the given fields replaced.
  OpportunityApplication copyWith({
    String? id,
    String? opportunityId,
    String? opportunityTitle,
    String? companyName,
    ApplicationStatus? status,
    DateTime? appliedAt,
    DateTime? interviewAt,
    DateTime? offerAt,
    DateTime? rejectedAt,
    DateTime? acceptedAt,
    String? notes,
    bool? isRemote,
    String? location,
    String? salaryRange,
  }) {
    return OpportunityApplication(
      id: id ?? this.id,
      opportunityId: opportunityId ?? this.opportunityId,
      opportunityTitle: opportunityTitle ?? this.opportunityTitle,
      companyName: companyName ?? this.companyName,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      interviewAt: interviewAt ?? this.interviewAt,
      offerAt: offerAt ?? this.offerAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      notes: notes ?? this.notes,
      isRemote: isRemote ?? this.isRemote,
      location: location ?? this.location,
      salaryRange: salaryRange ?? this.salaryRange,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is OpportunityApplication && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'OpportunityApplication(id: $id, title: $opportunityTitle, status: $statusLabel)';
}
