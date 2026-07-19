import 'package:flutter/material.dart';

/// Categories of notifications in the Phoenix Notification Center.
enum NotificationCategory {
  mission('Mission', Icons.rocket_launch_outlined),
  learning('Learning', Icons.school_outlined),
  assessment('Assessment', Icons.quiz_outlined),
  interview('Interview', Icons.record_voice_over_outlined),
  resume('Resume', Icons.description_outlined),
  portfolio('Portfolio', Icons.folder_outlined),
  achievement('Achievement', Icons.emoji_events_outlined),
  dailyBrief('Daily Brief', Icons.wb_sunny_outlined),
  decision('Decision', Icons.auto_awesome_rounded),
  growthForecast('Growth', Icons.trending_up_rounded),
  adaptiveLearning('Strategy', Icons.psychology_rounded),
  career('Career', Icons.work_outlined),
  system('System', Icons.settings_outlined),
  aiAssistant('AI Assistant', Icons.smart_toy_outlined),
  sync('Sync', Icons.sync_rounded);

  const NotificationCategory(this.displayName, this.icon);

  /// Human-readable category name.
  final String displayName;

  /// Material icon representing this category.
  final IconData icon;
}
