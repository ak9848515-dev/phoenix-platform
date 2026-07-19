/// Status of a user's application to a career opportunity.
///
/// Represents the full lifecycle from wishlist through acceptance/rejection.
enum ApplicationStatus {
  wishlist('Wishlist'),
  applied('Applied'),
  interviewScheduled('Interview'),
  offerReceived('Offer'),
  rejected('Rejected'),
  accepted('Accepted');

  const ApplicationStatus(this.label);
  final String label;
}
