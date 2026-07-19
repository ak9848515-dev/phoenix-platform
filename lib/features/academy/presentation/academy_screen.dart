import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/animations/fade_animation.dart';
import '../../../routes/app_routes.dart';
import '../services/academy_service.dart';

/// The Phoenix Learn Experience — an AI-first learning interface.
///
/// Hero becomes "What would you like to learn?" with a large intelligent
/// search field. Search is the primary action. When user searches,
/// AI generates:
/// - Learning Path
/// - Missions
/// - Projects
/// - Portfolio Ideas
/// - Interview Questions
/// - Practice Exercises
///
/// NO static curriculum. NO huge course database.
/// Everything generated through the existing AI pipeline.
class AcademyScreen extends StatefulWidget {
  const AcademyScreen({super.key});

  @override
  State<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends State<AcademyScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  bool _hasSearched = false;
  String? _aiResponse;
  bool _isGenerating = false;
  AcademyService? _academyService;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _academyService = AppBootstrap.maybeAcademyService;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isGenerating = true;
      _hasSearched = true;
      _aiResponse = null;
    });

    // Use the full AI pipeline for learning generation
    final learningGenerator = AppBootstrap.maybeLearningExperienceGenerator;
    if (learningGenerator != null) {
      final result = await learningGenerator.generateForGoal(query);
      if (mounted) {
        setState(() {
          _isGenerating = false;
          if (result.isSuccess && result.experience != null) {
            final exp = result.experience!;
            _aiResponse = '🎯 **${exp.goal.title}**\n\n'
                '${exp.goal.description}\n\n'
                '${exp.hasMission ? "📋 **Mission**: ${exp.mission!.title}\n${exp.mission!.description}\n\n" : ""}'
                '${exp.lessons.isNotEmpty ? "📚 **Lessons** (${exp.lessons.length}):\n${exp.lessons.map((l) => "• ${l.title}").join("\n")}\n\n" : ""}'
                '${exp.project != null ? "🛠️ **Project**: ${exp.project!.title}\n${exp.project!.description}\n" : ""}';
          } else {
            _aiResponse = '✨ I\'m thinking about "$query". '
                'Check back soon for a personalized learning path!';
          }
        });
      }
    } else {
      // Fallback: use existing academy paths for local search
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _aiResponse = null;
        });
        // Navigate to learning path detail or show results
        final matchingPaths = _academyService?.allPaths
            .where((p) =>
                p.title.toLowerCase().contains(query.toLowerCase()) ||
                p.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
        if (matchingPaths != null && matchingPaths.isNotEmpty) {
          Navigator.of(context).pushNamed(
            AppRoutes.academyLesson,
            arguments: {'pathId': matchingPaths.first.id},
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Hero Section ─────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              PhoenixSpacing.xl,
              MediaQuery.of(context).padding.top + PhoenixSpacing.xxl,
              PhoenixSpacing.xl,
              PhoenixSpacing.xxl,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Title ─────────────────────────────────
                Text(
                  'What would you like\nto learn?',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: PhoenixSpacing.sm),
                Text(
                  'AI will create a personalized learning path for you',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: PhoenixSpacing.xl),

                // ── Large Intelligent Search Field ──────────────
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _handleSearch,
                    decoration: InputDecoration(
                      hintText: 'What would you like to learn today?',
                      hintStyle: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Icon(
                          Icons.search_rounded,
                          size: 28,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded),
                              tooltip: 'Clear search',
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _hasSearched = false;
                                  _aiResponse = null;
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: PhoenixSpacing.xl,
                        vertical: PhoenixSpacing.lg,
                      ),
                    ),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),

          // ── Results Section ─────────────────────────────────────
          if (_isGenerating)
            Padding(
              padding: const EdgeInsets.all(PhoenixSpacing.xxl),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) => Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            PhoenixColors.primary.withValues(
                                alpha: 0.1 + _pulseController.value * 0.2),
                            PhoenixColors.primary.withValues(
                                alpha: 0.3 + _pulseController.value * 0.2),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 36,
                        color: PhoenixColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: PhoenixSpacing.lg),
                  Text(
                    'Creating your personalized learning experience...',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: PhoenixSpacing.sm),
                  Text(
                    'AI is generating learning paths, missions, and projects',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

          if (_aiResponse != null && !_isGenerating)
            FadeAnimation(
              duration: const Duration(milliseconds: 600),
              delay: Duration.zero,
              child: Padding(
                padding: const EdgeInsets.all(PhoenixSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI Response
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(PhoenixSpacing.lg),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded,
                                  size: 18, color: PhoenixColors.primary),
                              const SizedBox(width: PhoenixSpacing.sm),
                              Text(
                                'AI Learning Plan',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: PhoenixSpacing.md),
                          Text(
                            _aiResponse!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: PhoenixSpacing.lg),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () =>
                                Navigator.of(context).pushNamed(AppRoutes.missionCenter),
                            icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                            label: const Text('Start Learning'),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: PhoenixSpacing.md),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                Navigator.of(context).pushNamed(AppRoutes.recommendation),
                            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                            label: const Text('More Options'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          if (!_hasSearched && !_isGenerating) ...[
            // ── Quick Topics ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PhoenixSpacing.xl,
                PhoenixSpacing.xl,
                PhoenixSpacing.xl,
                PhoenixSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore topics',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: PhoenixSpacing.md),
                  Wrap(
                    spacing: PhoenixSpacing.sm,
                    runSpacing: PhoenixSpacing.sm,
                    children: [
                      _TopicChip(
                        label: 'Flutter',
                        icon: Icons.smartphone_rounded,
                        onTap: () => _handleSearch('Flutter'),
                      ),
                      _TopicChip(
                        label: 'Machine Learning',
                        icon: Icons.psychology_rounded,
                        onTap: () => _handleSearch('Machine Learning'),
                      ),
                      _TopicChip(
                        label: 'System Design',
                        icon: Icons.account_tree_rounded,
                        onTap: () => _handleSearch('System Design'),
                      ),
                      _TopicChip(
                        label: 'Data Science',
                        icon: Icons.analytics_rounded,
                        onTap: () => _handleSearch('Data Science'),
                      ),
                      _TopicChip(
                        label: 'Cloud Computing',
                        icon: Icons.cloud_rounded,
                        onTap: () => _handleSearch('Cloud Computing'),
                      ),
                      _TopicChip(
                        label: 'Leadership',
                        icon: Icons.groups_rounded,
                        onTap: () => _handleSearch('Leadership'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Continue Learning ────────────────────────────────
            if (_academyService?.activePathProgress != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PhoenixSpacing.xl,
                  PhoenixSpacing.xl,
                  PhoenixSpacing.xl,
                  PhoenixSpacing.xxl,
                ),
                child: _ContinueLearningCard(
                  academyService: _academyService!,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.academyLesson,
                    arguments: {
                      'pathId': _academyService!.activePathProgress!.pathId,
                    },
                  ),
                ),
              ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + PhoenixSpacing.xl),
          ],
        ],
      ),
    );
  }
}

/// A topic chip for quick search.
class _TopicChip extends StatelessWidget {
  const _TopicChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      avatar: Icon(icon, size: 16, color: PhoenixColors.primary),
      label: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

/// Continue learning card shown when there's an active path.
class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({
    required this.academyService,
    required this.onTap,
  });

  final AcademyService academyService;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = academyService.activePathProgress!;
    final currentLesson = academyService.currentLesson;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(PhoenixSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: PhoenixColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: PhoenixColors.info,
                size: 24,
              ),
            ),
            const SizedBox(width: PhoenixSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continue Learning',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentLesson?.lessonId ?? progress.pathId,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.completionPercentage,
                      minHeight: 4,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: PhoenixSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
