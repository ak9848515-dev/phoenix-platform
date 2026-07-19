import 'package:flutter/material.dart';

import '../../core/design/theme/phoenix_colors.dart';
import '../../core/design/theme/phoenix_radius.dart';
import '../../core/design/theme/phoenix_spacing.dart';

/// Categories of errors that Phoenix handles professionally.
enum PhoenixErrorCategory {
  /// No internet connection — suggest reconnect and retry.
  network,

  /// Request took too long — suggest retry.
  timeout,

  /// User lacks permission — suggest going back.
  permission,

  /// Data failed to load — suggest retry.
  data,

  /// Something unexpected happened — suggest retry.
  unexpected,
}

/// A professional, user-friendly error experience for the Phoenix Platform.
///
/// Phoenix never exposes raw exceptions, stack traces, or technical jargon.
/// Every error state provides:
/// 1. Relevant error icon/illustration with gradient background
/// 2. Friendly title
/// 3. Human-readable explanation
/// 4. Suggested action
/// 5. Primary CTA (Retry or Back)
/// 6. Optional secondary action (Help, AI Suggestion)
///
/// Uses the Phoenix Design System for premium, consistent styling.
class PhoenixErrorState extends StatelessWidget {
  const PhoenixErrorState({
    super.key,
    this.category = PhoenixErrorCategory.unexpected,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
    this.icon,
    this.aiSuggestion,
  });

  /// Category determines the default icon, title, and message.
  final PhoenixErrorCategory category;

  /// Override the default title for this category.
  final String? title;

  /// Override the default message for this category.
  final String? message;

  /// Label for the primary action button.
  final String? actionLabel;

  /// Called when the primary action is tapped.
  final VoidCallback? onAction;

  /// Label for the secondary action button.
  final String? secondaryLabel;

  /// Called when the secondary action is tapped.
  final VoidCallback? onSecondary;

  /// Override the default icon for this category.
  final IconData? icon;

  /// Optional AI-powered suggestion for resolving the error.
  final String? aiSuggestion;

  // ── Default values per category ───────────────────────────────────

  IconData get _defaultIcon {
    switch (category) {
      case PhoenixErrorCategory.network:
        return Icons.wifi_off_rounded;
      case PhoenixErrorCategory.timeout:
        return Icons.hourglass_empty_rounded;
      case PhoenixErrorCategory.permission:
        return Icons.lock_outline_rounded;
      case PhoenixErrorCategory.data:
        return Icons.cloud_off_rounded;
      case PhoenixErrorCategory.unexpected:
        return Icons.error_outline_rounded;
    }
  }

  String get _defaultTitle {
    switch (category) {
      case PhoenixErrorCategory.network:
        return 'No internet connection';
      case PhoenixErrorCategory.timeout:
        return 'Taking longer than expected';
      case PhoenixErrorCategory.permission:
        return 'Permission needed';
      case PhoenixErrorCategory.data:
        return "Couldn't load this information";
      case PhoenixErrorCategory.unexpected:
        return 'Something unexpected happened';
    }
  }

  String get _defaultMessage {
    switch (category) {
      case PhoenixErrorCategory.network:
        return 'Please check your connection and try again. '
            'Phoenix works offline too — your data is safe.';
      case PhoenixErrorCategory.timeout:
        return 'This is taking longer than expected. '
            'You can try again or check back later.';
      case PhoenixErrorCategory.permission:
        return "You don't have permission to access this feature. "
            'Contact your workspace admin if you need access.';
      case PhoenixErrorCategory.data:
        return "We couldn't load this information right now. "
            'Your existing data is still accessible.';
      case PhoenixErrorCategory.unexpected:
        return 'Something unexpected happened. '
            "We're ready to try again whenever you are.";
    }
  }

  Color get _accentColor {
    switch (category) {
      case PhoenixErrorCategory.network:
        return PhoenixColors.warning;
      case PhoenixErrorCategory.timeout:
        return PhoenixColors.warning;
      case PhoenixErrorCategory.permission:
        return PhoenixColors.warning;
      case PhoenixErrorCategory.data:
        return PhoenixColors.info;
      case PhoenixErrorCategory.unexpected:
        return PhoenixColors.error;
    }
  }

  String get _defaultActionLabel {
    switch (category) {
      case PhoenixErrorCategory.permission:
        return 'Go Back';
      default:
        return 'Try Again';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayIcon = icon ?? _defaultIcon;
    final displayTitle = title ?? _defaultTitle;
    final displayMessage = message ?? _defaultMessage;
    final displayActionLabel = actionLabel ?? _defaultActionLabel;
    final accentColor = _accentColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PhoenixSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Error icon with gradient background
            Semantics(
              excludeSemantics: true,
              child: Container(
                padding: const EdgeInsets.all(PhoenixSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.12),
                      accentColor.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: PhoenixRadius.xlRadius,
                ),
                child: Icon(
                  displayIcon,
                  size: 48,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(height: PhoenixSpacing.xl),

            // 2. Friendly title
            Text(
              displayTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: PhoenixSpacing.sm),

            // 3. Human-readable explanation
            Text(
              displayMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            // 4. AI-powered suggestion
            if (aiSuggestion != null) ...[
              const SizedBox(height: PhoenixSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(PhoenixSpacing.md),
                decoration: BoxDecoration(
                  color: PhoenixColors.primary.withValues(alpha: 0.06),
                  borderRadius: PhoenixRadius.mdRadius,
                  border: Border.all(
                    color: PhoenixColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: PhoenixColors.primary,
                    ),
                    const SizedBox(width: PhoenixSpacing.sm),
                    Expanded(
                      child: Text(
                        aiSuggestion!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: PhoenixSpacing.xl),

            // 5. Primary action
            if (onAction != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAction,
                  icon: Icon(
                    category == PhoenixErrorCategory.permission
                        ? Icons.arrow_back_rounded
                        : Icons.refresh_rounded,
                    size: 18,
                  ),
                  label: Text(displayActionLabel),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: PhoenixRadius.mdRadius,
                    ),
                  ),
                ),
              ),

            // 6. Optional secondary action
            if (secondaryLabel != null && onSecondary != null) ...[
              const SizedBox(height: PhoenixSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: onSecondary,
                  icon: const Icon(Icons.help_outline_rounded, size: 18),
                  label: Text(secondaryLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
