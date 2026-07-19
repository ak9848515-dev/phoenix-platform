/// An action that tapping a notification performs.
///
/// Contains a route to navigate to and an optional label.
class NotificationAction {
  const NotificationAction({
    required this.route,
    this.label,
    this.arguments,
  });

  /// Route name to navigate to (e.g. '/career', '/academy').
  final String route;

  /// Optional action label (e.g. 'View Mission').
  final String? label;

  /// Optional arguments to pass with the route.
  final Map<String, dynamic>? arguments;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationAction && other.route == route;

  @override
  int get hashCode => route.hashCode;
}
