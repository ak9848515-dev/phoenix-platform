import 'package:flutter/material.dart';

import '../../theme/radius.dart';
import '../../theme/spacing.dart';

class PhoenixPrimaryButton extends StatelessWidget {
  const PhoenixPrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.fullWidth = false,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon), const SizedBox(width: AppSpacing.sm)],
        Text(label),
      ],
    );

    final content = fullWidth
        ? SizedBox(
            width: double.infinity,
            child: Center(child: buttonChild),
          )
        : buttonChild;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: content,
    );
  }
}
