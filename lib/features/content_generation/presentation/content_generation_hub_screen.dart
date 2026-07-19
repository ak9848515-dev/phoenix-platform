import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_empty_state.dart';
import '../../../shared/widgets/phoenix_loading_widget.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/generation_metadata.dart';
import '../services/content_repository.dart';

/// The Content Generation Hub — landing screen for AI-powered content generation.
///
/// Displays cards for each content type the user can generate:
/// - Course / Learning Path
/// - Portfolio Project
/// - Portfolio Enhancement
/// - Resume Enhancement
/// - Interview Questions
///
/// Also shows recent generations for quick access.
class ContentGenerationHubScreen extends StatefulWidget {
  const ContentGenerationHubScreen({super.key});

  @override
  State<ContentGenerationHubScreen> createState() =>
      _ContentGenerationHubScreenState();
}

class _ContentGenerationHubScreenState
    extends State<ContentGenerationHubScreen> {
  ContentRepository? _repository;
  List<ContentLibraryItem> _recentItems = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final coordinator = AppBootstrap.maybeContentGeneratorCoordinator;
    _repository = coordinator?.repository;
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    if (_repository == null) return;
    setState(() => _isLoading = true);
    try {
      final all = await _repository!.getAllContent();
      setState(() {
        _recentItems = all.take(5).toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const PhoenixLoadingWidget(
        icon: Icons.auto_awesome_rounded,
        title: 'Content Generation',
        subtitle: 'Preparing your generation tools...',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppSpacing.lg),
          _buildSectionLabel(context, 'Generate', Icons.auto_awesome_rounded),
          const SizedBox(height: AppSpacing.md),
          _buildGenerationTypes(context),
          const SizedBox(height: AppSpacing.xl),
          if (_recentItems.isNotEmpty) ...[
            _buildSectionLabel(
                context, 'Recent Generations', Icons.history_rounded),
            const SizedBox(height: AppSpacing.md),
            ..._recentItems.map(
                (item) => _buildRecentItem(context, item)),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.of(context)
                    .pushNamed(AppRoutes.contentLibrary),
                icon: const Icon(Icons.folder_open_rounded, size: 18),
                label: const Text('View All Generated Content'),
              ),
            ),
          ] else ...[
            _buildSectionLabel(
                context, 'Recently Generated', Icons.history_rounded),
            const SizedBox(height: AppSpacing.md),
            const PhoenixEmptyState(
              icon: Icons.auto_awesome_outlined,
              title: 'No content generated yet',
              message:
                  'Tap on any generation type above to create your first '
                  'AI-powered content. Courses, projects, resume enhancements, '
                  'and interview prep are just a click away.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Content Generation',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                    Text('Generate AI-powered content for your growth journey',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    size: 18, color: AppColors.info),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'AI generates content based on your profile, goals, '
                    'and skill gaps. Results are saved locally for offline access.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(
      BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Text(label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }

  Widget _buildGenerationTypes(BuildContext context) {
    return Column(
      children: [
        _GenerationTypeCard(
          icon: Icons.school_rounded,
          color: AppColors.primary,
          title: 'Course / Learning Path',
          description:
              'Generate a structured learning path with modules, topics, and '
              'projects tailored to your skill gaps.',
          duration: '3-5 min',
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.generateCourse),
        ),
        const SizedBox(height: AppSpacing.md),
        _GenerationTypeCard(
          icon: Icons.code_rounded,
          color: AppColors.secondary,
          title: 'Portfolio Project',
          description:
              'Create a portfolio-worthy project with milestones, deliverables, '
              'and learning outcomes to showcase your skills.',
          duration: '2-4 min',
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.generateProject),
        ),
        const SizedBox(height: AppSpacing.md),
        _GenerationTypeCard(
          icon: Icons.folder_special_rounded,
          color: AppColors.info,
          title: 'Portfolio Enhancement',
          description:
              'Get AI suggestions to improve your portfolio — project ideas, '
              'skill gap analysis, and technology recommendations.',
          duration: '1-2 min',
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.generatePortfolioEnhancement),
        ),
        const SizedBox(height: AppSpacing.md),
        _GenerationTypeCard(
          icon: Icons.description_rounded,
          color: AppColors.warning,
          title: 'Resume Enhancement',
          description:
              'Optimize your resume with ATS analysis, keyword suggestions, '
              'and formatting improvements for your target role.',
          duration: '1-2 min',
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.generateResumeEnhancement),
        ),
        const SizedBox(height: AppSpacing.md),
        _GenerationTypeCard(
          icon: Icons.record_voice_over_rounded,
          color: AppColors.success,
          title: 'Interview Questions',
          description:
              'Generate realistic interview questions with expected answers '
              'and tips — technical, behavioral, and situational.',
          duration: '2-3 min',
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.generateInterviewQuestions),
        ),
      ],
    );
  }

  Widget _buildRecentItem(
      BuildContext context, ContentLibraryItem item) {
    final theme = Theme.of(context);
    final color = _typeColor(item.type);
    final displayName = ContentType.displayName(item.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: PhoenixCard(
        onTap: () => _navigateToDetail(context, item),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_typeIcon(item.type), color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _formatDate(item.generatedAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, ContentLibraryItem item) {
    // Navigate to the appropriate detail view based on type
    switch (item.type) {
      case ContentType.course:
        Navigator.of(context).pushNamed(
          AppRoutes.contentLibrary,
          arguments: {'filter': ContentType.course},
        );
      case ContentType.project:
        Navigator.of(context).pushNamed(
          AppRoutes.contentLibrary,
          arguments: {'filter': ContentType.project},
        );
      case ContentType.portfolioEnhancement:
        Navigator.of(context).pushNamed(
          AppRoutes.contentLibrary,
          arguments: {'filter': ContentType.portfolioEnhancement},
        );
      case ContentType.resumeEnhancement:
        Navigator.of(context).pushNamed(
          AppRoutes.contentLibrary,
          arguments: {'filter': ContentType.resumeEnhancement},
        );
      case ContentType.interviewQuestions:
        Navigator.of(context).pushNamed(
          AppRoutes.contentLibrary,
          arguments: {'filter': ContentType.interviewQuestions},
        );
      default:
        Navigator.of(context).pushNamed(AppRoutes.contentLibrary);
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case ContentType.course:
        return AppColors.primary;
      case ContentType.project:
        return AppColors.secondary;
      case ContentType.portfolioEnhancement:
        return AppColors.info;
      case ContentType.resumeEnhancement:
        return AppColors.warning;
      case ContentType.interviewQuestions:
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case ContentType.course:
        return Icons.school_rounded;
      case ContentType.project:
        return Icons.code_rounded;
      case ContentType.portfolioEnhancement:
        return Icons.folder_special_rounded;
      case ContentType.resumeEnhancement:
        return Icons.description_rounded;
      case ContentType.interviewQuestions:
        return Icons.record_voice_over_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}';
  }
}

/// A card for a content generation type on the hub screen.
class _GenerationTypeCard extends StatelessWidget {
  const _GenerationTypeCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.duration,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoenixCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 2),
                Text(description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(duration,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                )),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant, size: 20),
        ],
      ),
    );
  }
}
