import 'package:flutter/material.dart';

import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../intelligence/models/interview_enums.dart';
import '../intelligence/models/weak_topic.dart';

/// Displays detected weak topics with severity and recommended actions.
class InterviewWeakTopicsCard extends StatelessWidget {
  const InterviewWeakTopicsCard({
    super.key,
    required this.weakTopics,
    required this.onStudyTopic,
  });

  final List<WeakTopic> weakTopics;
  final void Function(String topic) onStudyTopic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: PhoenixRadius.xlRadius,
        border: Border.all(
          color: PhoenixColors.warning.withAlpha(60),
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
                  color: PhoenixColors.warning.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.priority_high_rounded,
                  size: 20,
                  color: PhoenixColors.warning,
                ),
              ),
              const SizedBox(width: PhoenixSpacing.sm),
              Text(
                'Areas to Improve',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${weakTopics.length} topics',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: PhoenixSpacing.md),
          ...weakTopics.take(4).map((topic) => Padding(
            padding: const EdgeInsets.only(bottom: PhoenixSpacing.md),
            child: _WeakTopicTile(
              topic: topic,
              theme: theme,
              onStudy: () => onStudyTopic(topic.subject),
            ),
          )),
        ],
      ),
    );
  }
}

class _WeakTopicTile extends StatelessWidget {
  const _WeakTopicTile({
    required this.topic,
    required this.theme,
    required this.onStudy,
  });

  final WeakTopic topic;
  final ThemeData theme;
  final VoidCallback onStudy;

  @override
  Widget build(BuildContext context) {
    final severityColor = topic.severity == WeakTopicSeverity.critical
        ? PhoenixColors.error
        : topic.severity == WeakTopicSeverity.high
            ? PhoenixColors.warning
            : topic.severity == WeakTopicSeverity.medium
                ? PhoenixColors.info
                : PhoenixColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(PhoenixSpacing.md),
      decoration: BoxDecoration(
        color: severityColor.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: severityColor.withAlpha(30),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: severityColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: PhoenixSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        topic.subject,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: severityColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        topic.severity.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: severityColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (topic.accuracyRate > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Accuracy: ${(topic.accuracyRate * 100).round()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (topic.missedCount > 0) ...[
                        const SizedBox(width: PhoenixSpacing.md),
                        Text(
                          'Missed: ${topic.missedCount}x',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: PhoenixColors.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                if (topic.recommendedLearning.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: topic.recommendedLearning.take(2).map((rec) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          rec,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onStudy,
                    icon: const Icon(Icons.school_outlined, size: 16),
                    label: const Text('Study & Practice'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: severityColor,
                      side: BorderSide(color: severityColor.withAlpha(80)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
