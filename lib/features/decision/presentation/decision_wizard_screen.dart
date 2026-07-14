import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/decision_analysis.dart';
import '../models/decision_criterion.dart';
import '../models/decision_option.dart';
import '../models/decision_risk.dart';
import '../models/decision_type.dart';
import '../services/decision_intelligence_service.dart';

/// Step-by-step wizard for creating a new decision analysis.
class DecisionWizardScreen extends StatefulWidget {
  const DecisionWizardScreen({super.key});

  @override
  State<DecisionWizardScreen> createState() => _DecisionWizardScreenState();
}

class _DecisionWizardScreenState extends State<DecisionWizardScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  DecisionType _selectedType = DecisionType.career;
  int _currentStep = 0;

  final List<DecisionCriterion> _criteria = [];
  final List<DecisionOption> _options = [];
  final List<DecisionRisk> _risks = [];

  DecisionIntelligenceService? _service;
  DecisionAnalysis? _result;

  @override
  void initState() {
    super.initState();
    _service = AppBootstrap.maybeDecisionService;
    _addDefaultCriteria();
  }

  void _addDefaultCriteria() {
    _criteria.add(const DecisionCriterion(
      id: 'c1', name: 'Impact', weight: 1.0, description: 'How significant is the outcome?'));
    _criteria.add(const DecisionCriterion(
      id: 'c2', name: 'Effort', weight: 0.8, isBeneficial: false, description: 'How much effort is required?'));
    _criteria.add(const DecisionCriterion(
      id: 'c3', name: 'Timeline', weight: 0.6, isBeneficial: false, description: 'How long will it take?'));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Decision Analysis'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (_currentStep) {
      case 0:
        return _buildStepSetup();
      case 1:
        return _buildStepCriteria();
      case 2:
        return _buildStepOptions();
      case 3:
        return _buildStepReview();
      default:
        return _buildStepResult();
    }
  }

  Widget _buildStepSetup() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(1, 4, 'Setup'),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'What decision are you making?',
              hintText: 'e.g. Which job offer should I accept?',
              border: OutlineInputBorder(),
            ),
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Context (optional)',
              hintText: 'Add any relevant context...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<DecisionType>(
            initialValue: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Decision Type',
              border: OutlineInputBorder(),
            ),
            items: DecisionType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.label),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedType = value);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          PhoenixPrimaryButton(
            onPressed: _titleController.text.trim().isEmpty
                ? () {}
                : () => setState(() => _currentStep = 1),
            label: 'Next: Criteria',
            icon: Icons.arrow_forward_rounded,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStepCriteria() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(2, 4, 'Criteria'),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Define the criteria for evaluating your options.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ..._criteria.asMap().entries.map((entry) {
            final i = entry.key;
            final c = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: PhoenixCard(
                child: Column(
                  children: [
                    TextField(
                      controller: TextEditingController(text: c.name),
                      decoration: InputDecoration(
                        labelText: 'Criterion ${i + 1}',
                        hintText: 'e.g. Salary, Location, Culture',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        _criteria[i] = c.copyWith(name: val);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Text('Weight: '),
                        Expanded(
                          child: Slider(
                            value: c.weight,
                            min: 0.1,
                            max: 2.0,
                            divisions: 19,
                            label: c.weight.toStringAsFixed(1),
                            onChanged: (val) {
                              setState(() {
                                _criteria[i] = c.copyWith(weight: val);
                              });
                            },
                          ),
                        ),
                        Text(c.weight.toStringAsFixed(1)),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Higher is better'),
                        Switch(
                          value: c.isBeneficial,
                          onChanged: (val) {
                            setState(() {
                              _criteria[i] = c.copyWith(isBeneficial: val);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: PhoenixPrimaryButton(
                  onPressed: () => setState(() => _currentStep = 0),
                  label: 'Back',
                  icon: Icons.arrow_back_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PhoenixPrimaryButton(
                  onPressed: () => setState(() => _currentStep = 2),
                  label: 'Next: Options',
                  icon: Icons.arrow_forward_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepOptions() {
    // Simplified options step
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(3, 4, 'Options'),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              'Define your options and score them against the criteria.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: PhoenixPrimaryButton(
                  onPressed: () => setState(() => _currentStep = 1),
                  label: 'Back',
                  icon: Icons.arrow_back_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PhoenixPrimaryButton(
                  onPressed: () => _runAnalysis(),
                  label: 'Analyze',
                  icon: Icons.auto_awesome_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepReview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildStepIndicator(4, 4, 'Results'),
          const SizedBox(height: AppSpacing.lg),
          if (_result != null) _buildResults(_result!),
        ],
      ),
    );
  }

  Widget _buildResults(DecisionAnalysis analysis) {
    final theme = Theme.of(context);
    final top = analysis.topRecommendation;
    final scored = analysis.weightedScores;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top recommendation
        if (top != null)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommended',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  top.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(
                  value: scored[top.id] != null
                      ? scored[top.id]! / 100
                      : 0,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Score: ${scored[top.id]?.toStringAsFixed(0) ?? "N/A"}/100',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.lg),

        // Score breakdown
        Text(
          'Score Breakdown',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...scored.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _options.firstWhere((o) => o.id == entry.key).title,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(
                    value: entry.value / 100,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 40,
                  child: Text(
                    entry.value.toStringAsFixed(0),
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: AppSpacing.lg),
        PhoenixPrimaryButton(
          onPressed: () => Navigator.of(context).pop(),
          label: 'Done',
          icon: Icons.check_rounded,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStepResult() => const SizedBox.shrink();

  Widget _buildStepIndicator(int current, int total, String label) {
    return Row(
      children: [
        ...List.generate(total, (i) {
          final isActive = i < current;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
        const SizedBox(width: AppSpacing.md),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _runAnalysis() {
    final svc = _service;
    if (svc == null) return;

    final analysis = svc.createAnalysis(
      title: _titleController.text.trim(),
      decisionType: _selectedType,
      description: _descController.text.trim(),
      criteria: _criteria,
      options: _options.isEmpty
          ? [
              const DecisionOption(
                id: 'opt1',
                title: 'Option A',
                scores: {'c1': 80, 'c2': 60, 'c3': 70},
              ),
              const DecisionOption(
                id: 'opt2',
                title: 'Option B',
                scores: {'c1': 60, 'c2': 80, 'c3': 50},
              ),
            ]
          : _options,
      risks: _risks,
    );

    svc.saveAnalysis(analysis);
    setState(() {
      _result = analysis;
      _currentStep = 3;
    });
  }
}
