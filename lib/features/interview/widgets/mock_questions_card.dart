import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../models/interview_question.dart';

/// Displays mock interview questions for practice.
class MockQuestionsCard extends StatelessWidget {
  const MockQuestionsCard({super.key, required this.questions});

  final List<InterviewQuestion> questions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (questions.isEmpty) return const SizedBox.shrink();

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Mock Questions', style: theme.textTheme.titleMedium),
              const Spacer(),
              Text(
                '${questions.length} questions',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...questions.map(
            (q) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: _typeColor(
                            q.questionType,
                            theme,
                          ).withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _typeLabel(q.questionType),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _typeColor(q.questionType, theme),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          q.question,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (q.tips.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: q.tips
                            .map(
                              (tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outlined,
                                      size: 14,
                                      color: Colors.amber.shade600,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              fontStyle: FontStyle.italic,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _typeColor(QuestionType type, ThemeData theme) {
    switch (type) {
      case QuestionType.technical:
        return theme.colorScheme.primary;
      case QuestionType.behavioral:
        return theme.colorScheme.tertiary;
      case QuestionType.hr:
        return Colors.green;
      case QuestionType.systemDesign:
        return Colors.orange;
      case QuestionType.pluginSpecific:
        return Colors.purple;
    }
  }

  String _typeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.technical:
        return 'Tech';
      case QuestionType.behavioral:
        return 'Behav';
      case QuestionType.hr:
        return 'HR';
      case QuestionType.systemDesign:
        return 'SD';
      case QuestionType.pluginSpecific:
        return 'Plugin';
    }
  }
}
