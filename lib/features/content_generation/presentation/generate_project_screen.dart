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

/// Screen for generating an AI-powered portfolio project.
///
/// Allows the user to specify technologies, difficulty, and duration.
class GenerateProjectScreen extends StatefulWidget {
  const GenerateProjectScreen({super.key});

  @override
  State<GenerateProjectScreen> createState() =>
      _GenerateProjectScreenState();
}

class _GenerateProjectScreenState extends State<GenerateProjectScreen> {
  ContentGeneratorCoordinator? _coordinator;
  bool _isGenerating = false;
  GeneratedProject? _generatedProject;
  String? _error;

  // Form fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _technologiesController = TextEditingController();
  String _difficulty = 'intermediate';
  int _estimatedWeeks = 2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _coordinator = AppBootstrap.maybeContentGeneratorCoordinator;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _technologiesController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_coordinator == null) return;

    setState(() {
      _isGenerating = true;
      _generatedProject = null;
      _error = null;
    });

    final techs = _technologiesController.text.isNotEmpty
        ? _technologiesController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList()
        : <String>[];

    final result = await _coordinator!.generateProject(
      GenerationRequest(
        contentType: ContentType.project,
        title: _titleController.text.isNotEmpty
            ? _titleController.text
            : null,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        technologies: techs,
        difficulty: _difficulty,
        estimatedDuration: _estimatedWeeks,
      ),
    );

    final projects = await _coordinator!.repository.getProjects();
    setState(() {
      _isGenerating = false;
      if (result.success && projects.isNotEmpty) {
        _generatedProject = projects.first;
      } else {
        _error = result.error ?? 'Generation failed.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isGenerating) {
      return _buildGeneratingState(theme);
    }

    if (_generatedProject != null) {
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
            label: 'Generate Project',
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
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.code_rounded,
                color: AppColors.secondary, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Portfolio Project',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                Text('Generate a portfolio-worthy project with milestones',
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
          Text('Project Title (optional)',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'e.g., Real-time Chat Application',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Description (optional)',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Briefly describe the project idea...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Technologies (comma-separated)',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _technologiesController,
            decoration: const InputDecoration(
              hintText: 'e.g., Flutter, Firebase, WebSocket',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Difficulty',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'beginner', label: Text('Beginner')),
              ButtonSegment(
                  value: 'intermediate', label: Text('Intermediate')),
              ButtonSegment(value: 'advanced', label: Text('Advanced')),
            ],
            selected: {_difficulty},
            onSelectionChanged: (v) =>
                setState(() => _difficulty = v.first),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Estimated Duration: $_estimatedWeeks weeks',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: AppSpacing.sm),
          Slider(
            value: _estimatedWeeks.toDouble(),
            min: 1,
            max: 12,
            divisions: 11,
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
              Text('Generating Your Project...',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: AppSpacing.sm),
              Text(
                  'AI is creating a portfolio project with milestones tailored to your tech stack.',
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
    final project = _generatedProject!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      Text('Project Generated!',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          )),
                      Text('Your portfolio project is ready',
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
          Text(project.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              )),
          if (project.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(project.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildStat(theme, '${project.milestoneCount} Milestones',
                  Icons.flag_rounded, AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              _buildStat(theme, '${project.estimatedWeeks} weeks',
                  Icons.schedule_rounded, AppColors.info),
              const SizedBox(width: AppSpacing.md),
              _buildStat(theme, project.difficulty,
                  Icons.trending_up_rounded, AppColors.warning),
            ],
          ),
          if (project.hasTechnologies) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('Technologies',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: project.technologies.map((t) => Chip(
                    label: Text(t,
                        style: theme.textTheme.labelSmall),
                    materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )).toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text('Milestones',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: AppSpacing.md),
          ...project.milestones.map(
              (m) => _buildMilestoneCard(theme, m)),
          const SizedBox(height: AppSpacing.lg),
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
                    Navigator.of(context).pushNamed(
                      '/content/library',
                      arguments: {'filter': ContentType.project},
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

  Widget _buildMilestoneCard(
      ThemeData theme, ProjectMilestone milestone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: PhoenixCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.flag_rounded,
                  color: AppColors.primary, size: 16),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(milestone.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                  if (milestone.description.isNotEmpty)
                    Text(milestone.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                  if (milestone.deliverables.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    ...milestone.deliverables.map((d) => Text(
                          '• $d',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${milestone.estimatedHours}h',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
