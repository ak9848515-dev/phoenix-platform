import 'package:flutter/material.dart';

/// Categories used to organize plugins in the marketplace.
///
/// These are display-oriented categories used for filtering and organizing
/// the available and installed plugin collections.
enum PluginCategory {
  /// Software development and engineering roles.
  technology('Technology', Icons.code_outlined),

  /// Business and management roles.
  business('Business', Icons.business_outlined),

  /// Educational and academic roles.
  education('Education', Icons.school_outlined),

  /// Creative and content creation roles.
  creative('Creative', Icons.brush_outlined),

  /// Health and wellness roles.
  health('Health', Icons.favorite_outlined),

  /// Finance and investment roles.
  finance('Finance', Icons.account_balance_outlined);

  const PluginCategory(this.label, this.icon);

  /// Human-readable category name.
  final String label;

  /// Material icon representing the category.
  final IconData icon;

  /// Creates a [PluginCategory] from a string label, case-insensitive.
  static PluginCategory fromString(String value) {
    return PluginCategory.values.firstWhere(
      (c) => c.label.toLowerCase() == value.toLowerCase(),
      orElse: () => PluginCategory.technology,
    );
  }

  /// Creates a [PluginCategory] from a manifest category string.
  static PluginCategory fromManifestCategory(String category) {
    return fromString(category);
  }
}
