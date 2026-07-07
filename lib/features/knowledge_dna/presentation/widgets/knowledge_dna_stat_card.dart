import 'package:flutter/material.dart';

import '../../../../theme/radius.dart';
import '../../../../theme/spacing.dart';

/// A presentation widget for displaying a compact stat tile in the Knowledge
/// DNA interface.
class KnowledgeDNAStatCard extends StatelessWidget {
  const KnowledgeDNAStatCard({
    required this.title,
    required this.value,
    required this.accentColor,
    super.key,
  });

  final String title;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: AppSpacing.lg,
              height: AppSpacing.lg,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: theme.textTheme.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: theme.textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}
