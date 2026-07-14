import 'package:flutter/material.dart';

import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../core/design/widgets/phoenix_badge.dart';
import '../../../core/design/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_bar.dart';

/// Displays the user's resume snapshot: completion score, missing
/// sections, career highlights, and last updated date.
///
/// Reads from [ResumeService.buildResume()].
/// Presentation-only — no business logic.
class ResumeSnapshotCard extends StatelessWidget {
  const ResumeSnapshotCard({
    super.key,
    required this.resumeScore,
    required this.skillCount,
    required this.projectCount,
    required this.careerHighlights,
    required this.lastUpdated,
    required this.isComplete,
    this.onViewResume,
  });

  /// Resume quality score from 0.0 to 1.0.
  final double resumeScore;

  /// Number of skills on the resume.
  final int skillCount;

  /// Number of projects on the resume.
  final int projectCount;

  /// Career highlight bullet points.
  final List<String> careerHighlights;

  /// When the resume was last generated.
  final DateTime? lastUpdated;

  /// Whether the resume has all sections.
  final bool isComplete;

  /// Navigate to the full resume screen.
  final VoidCallback? onViewResume;

  @override
  Widget build(BuildContext context) {
    final scorePercent = (resumeScore * 100).round();
    final updatedText = lastUpdated != null
        ? _formatDate(lastUpdated!)
        : 'Not yet generated';
    final missingSections = _missingSections();

    return FadeAnimation(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 250),
      child: PhoenixCard(
        header: 'Resume Snapshot',
        action: onViewResume != null
            ? TextButton(
                onPressed: onViewResume,
                child: Text(
                  'View Resume',
                  style: PhoenixTypography.label.copyWith(
                    color: PhoenixColors.primary,
                  ),
                ),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status & Score ────────────────────────────────────
            Row(
              children: [
                PhoenixBadge(
                  label: isComplete ? 'Complete' : 'In Progress',
                  variant: isComplete
                      ? BadgeVariant.success
                      : BadgeVariant.warning,
                  isSmall: true,
                  icon: isComplete
                      ? PhoenixIcons.checkCircle
                      : PhoenixIcons.warning,
                ),
                SizedBox(width: PhoenixSpacing.sm),
                Text(
                  '$scorePercent% Score',
                  style: PhoenixTypography.label.copyWith(
                    fontWeight: FontWeight.w600,
                    color: PhoenixColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: PhoenixSpacing.lg),

            // ── Resume Progress ────────────────────────────────────
            PhoenixProgressBar(
              value: resumeScore,
              label: 'Resume Completion',
              showPercentage: true,
              minHeight: 6,
              animationDuration: const Duration(milliseconds: 800),
            ),
            SizedBox(height: PhoenixSpacing.md),

            // ── Stats ──────────────────────────────────────────────
            Row(
              children: [
                _StatMini(label: 'Skills', value: '$skillCount'),
                SizedBox(width: PhoenixSpacing.xl),
                _StatMini(label: 'Projects', value: '$projectCount'),
                SizedBox(width: PhoenixSpacing.xl),
                _StatMini(
                  label: 'Updated',
                  value: updatedText,
                ),
              ],
            ),
            SizedBox(height: PhoenixSpacing.md),

            // ── Missing Sections ───────────────────────────────────
            if (missingSections.isNotEmpty) ...[
              Text(
                'Missing Sections',
                style: PhoenixTypography.caption.copyWith(
                  color: PhoenixColors.textSecondary,
                ),
              ),
              SizedBox(height: PhoenixSpacing.sm),
              ...missingSections.map((section) => Padding(
                    padding: EdgeInsets.only(bottom: PhoenixSpacing.xs),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 4,
                          color: PhoenixColors.textDisabled,
                        ),
                        SizedBox(width: PhoenixSpacing.sm),
                        Text(
                          section,
                          style: PhoenixTypography.caption.copyWith(
                            color: PhoenixColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],

            // ── Career Highlights ─────────────────────────────────
            if (careerHighlights.isNotEmpty) ...[
              SizedBox(height: PhoenixSpacing.md),
              Text(
                'Career Highlights',
                style: PhoenixTypography.caption.copyWith(
                  color: PhoenixColors.textSecondary,
                ),
              ),
              SizedBox(height: PhoenixSpacing.sm),
              ...careerHighlights.take(2).map((highlight) => Padding(
                    padding: EdgeInsets.only(bottom: PhoenixSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: PhoenixColors.success,
                        ),
                        SizedBox(width: PhoenixSpacing.sm),
                        Expanded(
                          child: Text(
                            highlight,
                            style: PhoenixTypography.caption.copyWith(
                              color: PhoenixColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  List<String> _missingSections() {
    final missing = <String>[];
    if (skillCount < 3) missing.add('More skills needed');
    if (projectCount < 2) missing.add('Additional projects');
    if (careerHighlights.isEmpty) missing.add('Career highlights');
    return missing;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }
}

/// A compact stat label-value pair.
class _StatMini extends StatelessWidget {
  const _StatMini({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: PhoenixTypography.label.copyWith(
            color: PhoenixColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: PhoenixTypography.caption.copyWith(
            color: PhoenixColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
