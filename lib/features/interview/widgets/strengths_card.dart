import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../shared/widgets/phoenix_card.dart';

/// Displays interview-related strengths.
class StrengthsCard extends StatelessWidget {
  const StrengthsCard({super.key, required this.strengths});

  final List<String> strengths;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (strengths.isEmpty) return const SizedBox.shrink();

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 20,
                color: Colors.green.shade600,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Interview Strengths', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...strengths
              .take(5)
              .map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green.shade400,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(s, style: theme.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
