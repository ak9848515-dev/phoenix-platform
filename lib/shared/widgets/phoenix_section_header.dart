import 'package:flutter/material.dart';

import '../../theme/spacing.dart';

class PhoenixSectionHeader extends StatelessWidget {
  const PhoenixSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final Widget? actions;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) ...[
            const SizedBox(width: AppSpacing.sm),
            actions!,
          ],
        ],
      ),
    );
  }
}
