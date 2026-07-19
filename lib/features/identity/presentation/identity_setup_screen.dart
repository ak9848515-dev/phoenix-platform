import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../routes/app_routes.dart';
import '../models/identity_profile.dart';

/// Mandatory Identity Setup Screen.
///
/// Shown after FIRST successful Google Authentication.
/// User cannot enter Dashboard until Identity is created.
///
/// Flow:
/// Splash → Google Authentication → Identity Setup → Workspace Init → Dashboard
///
/// Elegant, minimal screens with maximum usability.
class IdentitySetupScreen extends StatefulWidget {
  const IdentitySetupScreen({super.key});

  @override
  State<IdentitySetupScreen> createState() => _IdentitySetupScreenState();
}

class _IdentitySetupScreenState extends State<IdentitySetupScreen> {
  int _currentStep = 0;
  bool _isSaving = false;

  // ── Personal fields ──────────────────────────────────────────────
  final _nameController = TextEditingController();
  String? _selectedGender;
  String? _selectedCountry;

  // ── Professional fields ──────────────────────────────────────────
  final _professionController = TextEditingController();
  String? _selectedExperience;
  String? _selectedEducation;

  // ── Growth fields ────────────────────────────────────────────────
  final _goalController = TextEditingController();
  final _aspirationController = TextEditingController();
  final _skillsController = TextEditingController();
  int _dailyMinutes = 30;

  // ── AI fields ────────────────────────────────────────────────────
  final _aiPrefController = TextEditingController();

  static const _countries = [
    'United States', 'United Kingdom', 'Canada', 'Australia',
    'India', 'Germany', 'France', 'Japan', 'Brazil', 'Other',
  ];

  static const _experienceLevels = [
    '0-1 years', '1-3 years', '3-5 years', '5-10 years', '10+ years',
  ];

  static const _educationLevels = [
    'High School', 'Associate', 'Bachelor\'s', 'Master\'s', 'PhD', 'Other',
  ];

  static const _genders = [
    'Male', 'Female', 'Non-binary', 'Prefer not to say',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _professionController.dispose();
    _goalController.dispose();
    _aspirationController.dispose();
    _skillsController.dispose();
    _aiPrefController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    setState(() => _isSaving = true);

    try {
      final identityEngine = AppBootstrap.maybeIdentityEngine;
      if (identityEngine == null) return;

      // Collect skills from comma-separated input
      final skillsList = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final goalsList = [_goalController.text.trim()]
          .where((g) => g.isNotEmpty)
          .toList();
      final aspirationsList = [_aspirationController.text.trim()]
          .where((a) => a.isNotEmpty)
          .toList();

      final profile = IdentityProfile(
        id: 'user_identity',
        title: _professionController.text.isNotEmpty
            ? _professionController.text
            : 'Explorer',
        description: 'Personal growth journey',
        iconName: 'person_outlined',
        category: 'General',
        currentLevel: 1,
        targetLevel: 5,
        careerGoal: _goalController.text.isNotEmpty
            ? _goalController.text
            : 'Define your career goal',
        experienceLevel: (_selectedExperience != null && _selectedExperience!.isNotEmpty)
            ? _selectedExperience!
            : 'beginner',
        // Personal
        fullName: _nameController.text.trim(),
        gender: _selectedGender ?? '',
        country: _selectedCountry ?? '',
        language: 'en',
        // Professional
        profession: _professionController.text.trim(),
        professionalExperience: _selectedExperience ?? '',
        education: _selectedEducation ?? '',
        industry: '',
        // Growth
        goals: goalsList,
        aspirations: aspirationsList,
        skills: skillsList,
        dailyAvailableMinutes: _dailyMinutes,
        // AI
        aiPreferences: _aiPrefController.text.isNotEmpty
            ? [_aiPrefController.text.trim()]
            : [],
        preferredAIProvider: '',
      );

      await identityEngine.updateProfile(profile);
      await identityEngine.refresh();

      if (mounted) {
        // Navigate to dashboard — identity setup complete
        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Go back',
                onPressed: () => setState(() => _currentStep--),
              )
            : null,
        title: Text(
          'Set Up Your Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PhoenixSpacing.xl,
                vertical: PhoenixSpacing.md,
              ),
              child: Row(
                children: List.generate(4, (index) {
                  final isActive = index == _currentStep;
                  final isComplete = index < _currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isActive
                            ? PhoenixColors.primary
                            : isComplete
                                ? PhoenixColors.success
                                : PhoenixColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Step content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(PhoenixSpacing.xl),
                child: FadeAnimation(
                  duration: const Duration(milliseconds: 400),
                  delay: Duration.zero,
                  child: _buildCurrentStep(),
                ),
              ),
            ),

            // Bottom action
            Padding(
              padding: const EdgeInsets.all(PhoenixSpacing.xl),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _isSaving
                      ? null
                      : _currentStep < 3
                          ? () => setState(() => _currentStep++)
                          : _saveAndContinue,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _currentStep < 3
                              ? Icons.arrow_forward_rounded
                              : Icons.check_rounded,
                        ),
                  label: Text(
                    _currentStep < 3
                        ? 'Continue'
                        : _isSaving
                            ? 'Saving...'
                            : 'Complete Setup',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalStep();
      case 1:
        return _buildProfessionalStep();
      case 2:
        return _buildGrowthStep();
      case 3:
        return _buildAIStep();
      default:
        return _buildPersonalStep();
    }
  }

  // ── Step 1: Personal ─────────────────────────────────────────────

  Widget _buildPersonalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          icon: Icons.person_outline,
          title: 'Personal Information',
          subtitle: 'Help us know you better',
        ),
        const SizedBox(height: PhoenixSpacing.xl),
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          hint: 'Enter your full name',
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: PhoenixSpacing.lg),
        _buildDropdown(
          label: 'Gender',
          value: _selectedGender,
          items: _genders,
          onChanged: (v) => setState(() => _selectedGender = v),
          icon: Icons.wc_outlined,
        ),
        const SizedBox(height: PhoenixSpacing.lg),
        _buildDropdown(
          label: 'Country',
          value: _selectedCountry,
          items: _countries,
          onChanged: (v) => setState(() => _selectedCountry = v),
          icon: Icons.public_outlined,
        ),
      ],
    );
  }

  // ── Step 2: Professional ─────────────────────────────────────────

  Widget _buildProfessionalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          icon: Icons.work_outline,
          title: 'Professional Details',
          subtitle: 'What do you do?',
        ),
        const SizedBox(height: PhoenixSpacing.xl),
        _buildTextField(
          controller: _professionController,
          label: 'Profession / Job Title',
          hint: 'e.g. Software Engineer',
          icon: Icons.work_outlined,
        ),
        const SizedBox(height: PhoenixSpacing.lg),
        _buildDropdown(
          label: 'Experience',
          value: _selectedExperience,
          items: _experienceLevels,
          onChanged: (v) => setState(() => _selectedExperience = v),
          icon: Icons.timeline_outlined,
        ),
        const SizedBox(height: PhoenixSpacing.lg),
        _buildDropdown(
          label: 'Education',
          value: _selectedEducation,
          items: _educationLevels,
          onChanged: (v) => setState(() => _selectedEducation = v),
          icon: Icons.school_outlined,
        ),
      ],
    );
  }

  // ── Step 3: Growth ───────────────────────────────────────────────

  Widget _buildGrowthStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          icon: Icons.auto_awesome_outlined,
          title: 'Growth & Goals',
          subtitle: 'What do you want to achieve?',
        ),
        const SizedBox(height: PhoenixSpacing.xl),
        _buildTextField(
          controller: _goalController,
          label: 'Primary Goal',
          hint: 'e.g. Become a senior developer',
          icon: Icons.flag_outlined,
        ),
        const SizedBox(height: PhoenixSpacing.lg),
        _buildTextField(
          controller: _aspirationController,
          label: 'Aspiration',
          hint: 'e.g. Lead a tech team',
          icon: Icons.stars_outlined,
        ),
        const SizedBox(height: PhoenixSpacing.lg),
        _buildTextField(
          controller: _skillsController,
          label: 'Skills (comma separated)',
          hint: 'e.g. Flutter, Python, Leadership',
          icon: Icons.psychology_outlined,
        ),
        const SizedBox(height: PhoenixSpacing.lg),
        _buildMinutesSelector(),
      ],
    );
  }

  Widget _buildMinutesSelector() {
    return Container(
      padding: const EdgeInsets.all(PhoenixSpacing.md),
      decoration: BoxDecoration(
        color: PhoenixColors.surface,
        borderRadius: PhoenixRadius.lgRadius,
        border: Border.all(color: PhoenixColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 20, color: PhoenixColors.primary),
              const SizedBox(width: PhoenixSpacing.sm),
              Text(
                'Daily Available Time',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: PhoenixSpacing.md),
          Row(
            children: [
              IconButton(
                tooltip: 'Decrease daily minutes',
                onPressed: _dailyMinutes > 5
                    ? () => setState(() => _dailyMinutes -= 5)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$_dailyMinutes min',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: PhoenixColors.primary,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Increase daily minutes',
                onPressed: _dailyMinutes < 120
                    ? () => setState(() => _dailyMinutes += 5)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          Slider(
            value: _dailyMinutes.toDouble(),
            min: 5,
            max: 120,
            divisions: 23,
            label: '$_dailyMinutes min',
            onChanged: (v) => setState(() => _dailyMinutes = v.round()),
          ),
        ],
      ),
    );
  }

  // ── Step 4: AI Preferences ───────────────────────────────────────

  Widget _buildAIStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          icon: Icons.auto_awesome_rounded,
          title: 'AI Preferences',
          subtitle: 'How would you like AI to assist you?',
        ),
        const SizedBox(height: PhoenixSpacing.xl),
        _buildTextField(
          controller: _aiPrefController,
          label: 'AI Preferences',
          hint: 'e.g. Auto-suggest, detailed explanations, code reviews',
          icon: Icons.tune_outlined,
          maxLines: 3,
        ),
        const SizedBox(height: PhoenixSpacing.lg),
        Container(
          padding: const EdgeInsets.all(PhoenixSpacing.lg),
          decoration: BoxDecoration(
            color: PhoenixColors.primary.withValues(alpha: 0.06),
            borderRadius: PhoenixRadius.xlRadius,
            border: Border.all(
              color: PhoenixColors.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: PhoenixColors.primary,
              ),
              const SizedBox(width: PhoenixSpacing.md),
              Expanded(
                child: Text(
                  'You can update these preferences anytime from your Profile.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PhoenixColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Reusable Widgets ────────────────────────────────────────────

  Widget _buildStepHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: PhoenixColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: PhoenixColors.primary, size: 24),
        ),
        const SizedBox(width: PhoenixSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: PhoenixColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: (value != null && value.isNotEmpty) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.3),
      ),
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: onChanged,
    );
  }
}