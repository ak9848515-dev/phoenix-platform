import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/generation_metadata.dart';
import '../models/generation_request.dart';
import '../services/content_generator_coordinator.dart';

/// Configuration for which type of enhancement to generate.
class EnhancementConfig {
  const EnhancementConfig({
    required this.contentType,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.generationMethod,
    required this.primaryLabel,
    required this.generatingTitle,
    required this.generatingMessage,
  });

  final String contentType;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String generationMethod;
  final String primaryLabel;
  final String generatingTitle;
  final String generatingMessage;

  static const EnhancementConfig portfolio = EnhancementConfig(
    contentType: ContentType.portfolioEnhancement,
    title: 'Portfolio Enhancement',
    description: 'Get AI suggestions to improve your portfolio',
    icon: Icons.folder_special_rounded,
    color: AppColors.info,
    generationMethod: 'portfolio',
    primaryLabel: 'Analyze Portfolio',
    generatingTitle: 'Analyzing Your Portfolio...',
    generatingMessage:
        'AI is evaluating your profile and generating personalized '
        'portfolio improvement suggestions.',
  );

  static const EnhancementConfig resume = EnhancementConfig(
    contentType: ContentType.resumeEnhancement,
    title: 'Resume Enhancement',
    description: 'Optimize your resume with AI-powered suggestions',
    icon: Icons.description_rounded,
    color: AppColors.warning,
    generationMethod: 'resume',
    primaryLabel: 'Analyze Resume',
    generatingTitle: 'Analyzing Your Resume...',
    generatingMessage:
        'AI is analyzing your profile and generating ATS-optimized '
        'resume improvement suggestions.',
  );

  static const EnhancementConfig interview = EnhancementConfig(
    contentType: ContentType.interviewQuestions,
    title: 'Interview Questions',
    description: 'Generate practice questions for your target role',
    icon: Icons.record_voice_over_rounded,
    color: AppColors.success,
    generationMethod: 'interview',
    primaryLabel: 'Generate Questions',
    generatingTitle: 'Generating Interview Questions...',
    generatingMessage:
        'AI is creating realistic interview questions based on your '
        'target role and skill profile.',
  );
}

/// A generic screen for generating portfolio enhancements, resume enhancements,
/// or interview questions.
class GenerateEnhancementScreen extends StatefulWidget {
  const GenerateEnhancementScreen({super.key}) : _config = null;

  /// Use the factory constructors below instead.
  const GenerateEnhancementScreen._(EnhancementConfig config, {super.key})
      : _config = config;

  final EnhancementConfig? _config;

  factory GenerateEnhancementScreen.portfolioEnhancement({Key? key}) =>
      GenerateEnhancementScreen._(EnhancementConfig.portfolio, key: key);

  factory GenerateEnhancementScreen.resumeEnhancement({Key? key}) =>
      GenerateEnhancementScreen._(EnhancementConfig.resume, key: key);

  factory GenerateEnhancementScreen.interviewQuestions({Key? key}) =>
      GenerateEnhancementScreen._(EnhancementConfig.interview, key: key);

  @override
  State<GenerateEnhancementScreen> createState() =>
      _GenerateEnhancementScreenState();
}

class _GenerateEnhancementScreenState
    extends State<GenerateEnhancementScreen> {
  ContentGeneratorCoordinator? _coordinator;
  bool _isGenerating = false;
  String? _resultSummary;
  String? _error;

  // Form fields
  final _targetRoleController = TextEditingController();
  final _skillFocusController = TextEditingController();

  EnhancementConfig get _config =>
      widget._config ?? EnhancementConfig.portfolio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _coordinator = AppBootstrap.maybeContentGeneratorCoordinator;
  }

  @override
  void dispose() {
    _targetRoleController.dispose();
    _skillFocusController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_coordinator == null) return;

    setState(() {
      _isGenerating = true;
      _resultSummary = null;
      _error = null;
    });

    final skills = _skillFocusController.text.isNotEmpty
        ? _skillFocusController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList()
        : <String>[];

    ContentGenerationResult result;
    switch (_config.generationMethod) {
      case 'portfolio':
        result = await _coordinator!.generatePortfolioEnhancement(
          GenerationRequest(
            contentType: ContentType.portfolioEnhancement,
            skillFocus: skills,
          ),
        );
      case 'resume':
        result = await _coordinator!.generateResumeEnhancement(
          GenerationRequest(
            contentType: ContentType.resumeEnhancement,
            targetRole: _targetRoleController.text.isNotEmpty
                ? _targetRoleController.text
                : null,
            skillFocus: skills,
          ),
        );
      case 'interview':
        result = await _coordinator!.generateInterviewQuestions(
          GenerationRequest(
            contentType: ContentType.interviewQuestions,
            targetRole: _targetRoleController.text.isNotEmpty
                ? _targetRoleController.text
                : null,
            skillFocus: skills,
          ),
        );
      default:
        result = ContentGenerationResult(
          success: false,
          error: 'Unknown generation type.',
        );
    }

    setState(() {
      _isGenerating = false;
      if (result.success) {
        _resultSummary = 'Content generated successfully! '
            'Check the Content Library to view it.';
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

    if (_resultSummary != null) {
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
            label: _config.primaryLabel,
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
    final cfg = _config;
    return PhoenixCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: cfg.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(cfg.icon, color: cfg.color, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cfg.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                Text(cfg.description,
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
    final cfg = _config;
    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cfg.generationMethod == 'resume' ||
              cfg.generationMethod == 'interview') ...[
            Text('Target Role',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _targetRoleController,
              decoration: const InputDecoration(
                hintText: 'e.g., Senior Flutter Developer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text('Skill Focus (comma-separated, optional)',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _skillFocusController,
            decoration: const InputDecoration(
              hintText:
                  'e.g., Flutter, System Design, Leadership',
              border: OutlineInputBorder(),
            ),
          ),
          if (cfg.generationMethod == 'portfolio') ...[
            const SizedBox(height: AppSpacing.lg),
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
                      'Portfolio analysis uses your existing profile. '
                      'Add skill focus to narrow down suggestions.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (cfg.generationMethod == 'interview') ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates_rounded,
                      size: 18, color: AppColors.success),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Questions include technical, behavioral, and '
                      'situational categories with expected answers and tips.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (cfg.generationMethod == 'resume') ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates_rounded,
                      size: 18, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Focuses on ATS optimization, keyword gaps, '
                      'and formatting improvements for your target role.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
              Text(_config.generatingTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _config.generatingMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultState(BuildContext context, ThemeData theme) {
    return Center(
      child: PhoenixCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 48),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('${_config.title} Complete!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  )),
              const SizedBox(height: AppSpacing.sm),
              Text(_resultSummary ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xl),
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
                          arguments: {
                            'filter': _config.contentType
                          },
                        );
                      },
                      icon:
                          const Icon(Icons.folder_open_rounded, size: 18),
                      label: const Text('View in Library'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
