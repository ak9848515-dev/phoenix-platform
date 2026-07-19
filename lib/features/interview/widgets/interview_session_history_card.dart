import 'package:flutter/material.dart';

import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../intelligence/models/interview_session_detail.dart';

/// Displays recent interview practice sessions with scores and actions.
class InterviewSessionHistoryCard extends StatelessWidget {
  const InterviewSessionHistoryCard({
    super.key,
    required this.sessions,
    required this.onViewSession,
    required this.onStartNew,
  });

  final List<InterviewSessionDetail> sessions;
  final void Function(InterviewSessionDetail session) onViewSession;
  final VoidCallback onStartNew;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: PhoenixRadius.xlRadius,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(60),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: 20,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: PhoenixSpacing.sm),
              Text(
                'Practice History',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${sessions.length} sessions',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: PhoenixSpacing.md),
          ...sessions.map((session) => Padding(
            padding: const EdgeInsets.only(bottom: PhoenixSpacing.sm),
            child: _SessionTile(
              session: session,
              theme: theme,
              onTap: () => onViewSession(session),
            ),
          )),
          const SizedBox(height: PhoenixSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onStartNew,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Start New Practice'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.theme,
    required this.onTap,
  });

  final InterviewSessionDetail session;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scoreColor = session.score >= 0.7
        ? PhoenixColors.success
        : session.score >= 0.4
            ? PhoenixColors.warning
            : PhoenixColors.error;

    final statusColor = session.isCompleted
        ? PhoenixColors.success
        : session.isInProgress
            ? PhoenixColors.info
            : PhoenixColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(PhoenixSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Score indicator
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: session.score,
                    strokeWidth: 3,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                  Text(
                    '${(session.score * 100).round()}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scoreColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: PhoenixSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        session.status.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: PhoenixSpacing.md),
                      Text(
                        '${session.answeredCount}/${session.questions.length}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (session.durationMinutes > 0) ...[
                        const SizedBox(width: PhoenixSpacing.md),
                        Text(
                          '${session.durationMinutes}m',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
