import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../shared/widgets/phoenix_card.dart';

import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/generated_content.dart';
import '../models/generation_metadata.dart';
import '../models/generation_request.dart';
import '../services/content_generator_coordinator.dart';

/// Screen for generating an AI-powered course/learning path.
///
/// Allows the user to specify parameters like title, difficulty,
/// skill focus, and duration before generating.
class GenerateCourseScreen extends StatefulWidget {
  const GenerateCourseScreen({super.key});

  @override
  State<GenerateCourseScreen> createState() => _GenerateCourseScreenState();
}

class _GenerateCourseScreenState extends State<GenerateCourseScreen> {
  ContentGeneratorCoordinator? _coordinator;
  bool _isGenerating = false;
  GeneratedCourse? _generatedCourse;
  String? _error;

  // Form fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skillFocusController = TextEditingController();
  String _difficulty = 'intermediate';
  int _estimatedWeeks = 4;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _coordinator = AppBootstrap.maybeContentGeneratorCoordinator;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _skillFocusController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_coordinator == null) return;

    setState(() {
      _isGenerating = true;
      _generatedCourse = null;
      _error = null;
    });

    final skills = _skillFocusController.text.isNotEmpty
        ? _skillFocusController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList()
        : <String>[];

    final result = await _coordinator!.generateCourse(
      GenerationRequest(
        contentType: ContentType.course,
        title: _titleController.text.isNotEmpty
            ? _titleController.text
            : null,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        skillFocus: skills,
        difficulty: _difficulty,
        estimatedDuration: _estimatedWeeks,
      ),
    );

    // Reload the course from repository
    final courses = await _coordinator!.repository.getCourses();
    setState(() {
      _isGenerating = false;
      if (result.success && courses.isNotEmpty) {
        _generatedCourse = courses.first;
      } else {
        _error = result.error ?? 'Generation failed. Please try again.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isGenerating) {
      return _buildGeneratingState(theme);
    }

    if (_generatedCourse != null) {
      return _buildResultState(context, theme);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const SizedBox(height: AppSpacing.lg),
          _buildForm(theme),
          const SizedBox(height: AppSpacing.xl),
          PhoenixPrimaryButton(
            onPressed: _generate,
            label: 'Generate Course',
            icon: Icons.auto_awesome_rounded,
            isLoading: _isGenerating,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 18, color: AppColors.error),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(_error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                        )),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return PhoenixCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school_rounded,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Course / Learning Path',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                Text('Generate a structured learning path with AI',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text('Course Title (optional)',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'e.g., Advanced Flutter Development',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Description
          Text('Description (optional)',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Briefly describe what you want to learn...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Skill Focus
          Text('Skill Focus (comma-separated)',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _skillFocusController,
            decoration: const InputDecoration(
              hintText: 'e.g., Flutter, Dart, Firebase, State Management',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Difficulty
          Text('Difficulty',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'beginner', label: Text('Beginner')),
              ButtonSegment(value: 'intermediate', label: Text('Intermediate')),
              ButtonSegment(value: 'advanced', label: Text('Advanced')),
            ],
            selected: {_difficulty},
            onSelectionChanged: (v) =>
                setState(() => _difficulty = v.first),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Duration
          Text('Estimated Duration: $_estimatedWeeks weeks',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: AppSpacing.sm),
          Slider(
            value: _estimatedWeeks.toDouble(),
            min: 1,
            max: 16,
            divisions: 15,
            label: '$_estimatedWeeks weeks',
            onChanged: (v) =>
                setState(() => _estimatedWeeks = v.round()),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratingState(ThemeData theme) {
    return Center(
      child: PhoenixCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Generating Your Course...',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: AppSpacing.sm),
              Text(
                  'AI is creating a personalized learning path based on your profile and preferences.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultState(BuildContext context, ThemeData theme) {
    final course = _generatedCourse!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.1),
                  AppColors.success.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 32),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Course Generated!',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          )),
                      Text('Your learning path is ready',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Course title
          Text(course.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              )),
          if (course.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(course.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
          ],
          const SizedBox(height: AppSpacing.md),

          // Stats
          Row(
            children: [
              _buildStat(theme, '${course.moduleCount} Modules',
                  Icons.book_rounded, AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              _buildStat(theme, '${course.estimatedWeeks} weeks',
                  Icons.schedule_rounded, AppColors.info),
              const SizedBox(width: AppSpacing.md),
              _buildStat(theme, course.difficulty,
                  Icons.trending_up_rounded, AppColors.warning),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Modules
          Text('Modules',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: AppSpacing.md),
          ...course.modules.map((m) => _buildModuleCard(theme, m)),
          const SizedBox(height: AppSpacing.lg),

          // Learning outcomes
          if (course.learningOutcomes.isNotEmpty) ...[
            Text('Learning Outcomes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: AppSpacing.sm),
            ...course.learningOutcomes.map((o) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 16, color: AppColors.success),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(o)),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: AppSpacing.lg),

          // Actions
          Row(
            children: [
              Expanded(
                child: PhoenixPrimaryButton(
                  onPressed: () => Navigator.of(context).pop(),
                  label: 'Back to Hub',
                  icon: Icons.arrow_back_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to content library with course filter
                    Navigator.of(context).pushNamed(
                      '/content/library',
                      arguments: {'filter': ContentType.course},
                    );
                  },
                  icon: const Icon(Icons.folder_open_rounded, size: 18),
                  label: const Text('Save to Library'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
      ThemeData theme, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(ThemeData theme, CourseModule module) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: PhoenixCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(module.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${module.estimatedHours}h',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ],
            ),
            if (module.description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(module.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  )),
            ],
            if (module.topics.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: module.topics.map((t) => Chip(
                      label: Text(t,
                          style: theme.textTheme.labelSmall),
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
