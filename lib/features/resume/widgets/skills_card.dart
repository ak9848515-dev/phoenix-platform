import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_indicator.dart';
import '../models/resume_skill.dart';

/// Displays the user's skills with proficiency levels in the resume.
class SkillsCard extends StatelessWidget {
  const SkillsCard({super.key, required this.skills});

  final List<ResumeSkill> skills;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (skills.isEmpty) return const SizedBox.shrink();

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Skills', style: theme.textTheme.titleMedium),
              const Spacer(),
              Text(
                '${skills.length} skills',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...skills.map(
            (skill) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      skill.name,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: PhoenixProgressIndicator(
                      value: skill.proficiency,
                      minHeight: 6,
                      valueColor: skill.isStrength
                          ? Colors.green
                          : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${(skill.proficiency * 100).round()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.end,
                    ),
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
