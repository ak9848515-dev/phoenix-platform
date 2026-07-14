import 'package:flutter/material.dart';

/// Knowledge domains for the Personal Knowledge Graph.
///
/// Each domain represents a semantic category of knowledge
/// that the engine indexes and reasons about.
///
/// Architecture targets: unlimited future domains.
enum KnowledgeDomain {
  skills(
    'Skills',
    Icons.psychology_rounded,
    'Learned and developed abilities',
  ),
  goals(
    'Goals',
    Icons.flag_rounded,
    'Aspirations and objectives',
  ),
  learning(
    'Learning',
    Icons.school_rounded,
    'Academy lessons and courses',
  ),
  career(
    'Career',
    Icons.work_rounded,
    'Professional development',
  ),
  projects(
    'Projects',
    Icons.folder_rounded,
    'Built and delivered work',
  ),
  portfolio(
    'Portfolio',
    Icons.folder_special_rounded,
    'Curated body of work',
  ),
  resume(
    'Resume',
    Icons.description_rounded,
    'Professional summary',
  ),
  missions(
    'Missions',
    Icons.rocket_launch_rounded,
    'Active and completed missions',
  ),
  habits(
    'Habits',
    Icons.repeat_rounded,
    'Behavioural patterns',
  ),
  decisions(
    'Decisions',
    Icons.account_tree_rounded,
    'Past choices and outcomes',
  ),
  timeline(
    'Timeline',
    Icons.timeline_rounded,
    'Life events and milestones',
  ),
  aiConversations(
    'AI Conversations',
    Icons.chat_rounded,
    'AI mentor interactions',
  ),
  custom(
    'Custom',
    Icons.extension_rounded,
    'User-defined domain',
  );

  const KnowledgeDomain(this.label, this.icon, this.description);

  final String label;
  final IconData icon;
  final String description;

  static KnowledgeDomain fromString(String value) {
    return KnowledgeDomain.values.firstWhere(
      (d) => d.name == value,
      orElse: () => KnowledgeDomain.custom,
    );
  }

  static KnowledgeDomain? tryParse(String value) {
    try {
      return fromString(value);
    } catch (_) {
      return null;
    }
  }
}
