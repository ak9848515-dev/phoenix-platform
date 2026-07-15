import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../../../models/user_settings.dart';

/// First-Time Experience onboarding flow.
///
/// A guided 7-step journey that introduces Phoenix as a Personal Growth
/// Operating System. The user progresses through:
///
/// 0. Welcome
/// 1. Identity Selection
/// 2. Primary Goal
/// 3. Experience Level
/// 4. Learning Preferences
/// 5. Mission Preview
/// 6. Finish
///
/// On completion, [UserSettings.onboardingComplete] is persisted so the
/// flow is never shown again.
///
/// Architecture Rules:
/// - No AI orchestration
/// - No business logic — all data is placeholder/display
/// - Reuses existing design system tokens
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // ── Collected user input ─────────────────────────────────────────────
  String? _selectedIdentity;
  String? _selectedGoal;
  String? _selectedExperience;
  final Set<String> _selectedPreferences = {};

  static const int _totalPages = 7;

  // ── Identity options ─────────────────────────────────────────────────
  static const List<_IdentityOption> _identityOptions = [
    _IdentityOption(icon: Icons.code_rounded, name: 'Software Engineer'),
    _IdentityOption(icon: Icons.business_rounded, name: 'SAP Consultant'),
    _IdentityOption(icon: Icons.smart_toy_rounded, name: 'AI Engineer'),
    _IdentityOption(icon: Icons.rocket_launch_rounded, name: 'Product Builder'),
    _IdentityOption(icon: Icons.analytics_rounded, name: 'Data Analyst'),
    _IdentityOption(icon: Icons.trending_up_rounded, name: 'Entrepreneur'),
  ];

  // ── Goal options ─────────────────────────────────────────────────────
  static const List<_GoalOption> _goalOptions = [
    _GoalOption(icon: Icons.work_outline, name: 'Get a Job'),
    _GoalOption(icon: Icons.school_outlined, name: 'Learn a Skill'),
    _GoalOption(icon: Icons.build_outlined, name: 'Build a Project'),
    _GoalOption(icon: Icons.store_outlined, name: 'Start a Business'),
    _GoalOption(icon: Icons.trending_up_outlined, name: 'Improve Productivity'),
    _GoalOption(icon: Icons.stars_outlined, name: 'Grow Career'),
  ];

  // ── Experience options ───────────────────────────────────────────────
  static const List<_ExperienceOption> _experienceOptions = [
    _ExperienceOption(name: 'Beginner', desc: 'New to this field'),
    _ExperienceOption(name: 'Intermediate', desc: 'Some experience'),
    _ExperienceOption(name: 'Advanced', desc: 'Strong foundation'),
    _ExperienceOption(name: 'Expert', desc: 'Deep expertise'),
  ];

  // ── Learning preferences ─────────────────────────────────────────────
  static const List<_PreferenceOption> _preferenceOptions = [
    _PreferenceOption(icon: Icons.flag_outlined, name: 'Mission Based'),
    _PreferenceOption(icon: Icons.build_outlined, name: 'Project Based'),
    _PreferenceOption(icon: Icons.menu_book_outlined, name: 'Reading'),
    _PreferenceOption(icon: Icons.ondemand_video_outlined, name: 'Video'),
    _PreferenceOption(icon: Icons.handyman_outlined, name: 'Practice'),
    _PreferenceOption(icon: Icons.blender_outlined, name: 'Mixed'),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final storage = AppBootstrap.storageService;
    final current = storage.readUserSettings();
    final updated = current.copyWith(onboardingComplete: true);
    await storage.saveUserSettings(updated);

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress Indicator ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: Row(
                children: [
                  // Back button (hidden on first page)
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: _goBack,
                      tooltip: 'Back',
                    )
                  else
                    const SizedBox(width: 48),

                  const Spacer(),

                  // Dots
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_totalPages, (i) {
                        final isActive = i <= _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),

                  const Spacer(),

                  // Skip button (hide on finish page)
                  if (_currentPage < _totalPages - 1)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: const Text('Skip'),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // ── Page Content ──────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomePage(),
                  _buildIdentityPage(),
                  _buildGoalPage(),
                  _buildExperiencePage(),
                  _buildPreferencesPage(),
                  _buildMissionPreviewPage(),
                  _buildFinishPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PAGE 0 — WELCOME
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Logo
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 72,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          Text(
            'Welcome to Phoenix',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            'Your Personal Growth Operating System',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(
            'Phoenix helps you define who you want to become,\n'
            'track your growth, and take action every day.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.7),
                ),
            textAlign: TextAlign.center,
          ),

          const Spacer(flex: 1),

          // Primary CTA
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _goNext,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Get Started'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Secondary CTA
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login),
              icon: const Icon(Icons.login_rounded),
              label: const Text('Sign In'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const Spacer(flex: 1),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PAGE 1 — IDENTITY SELECTION
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildIdentityPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 1),

          Text(
            'Who do you want to become?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choose the identity that best matches your aspirations.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.1,
              physics: const NeverScrollableScrollPhysics(),
              children: _identityOptions.map((opt) {
                final selected = _selectedIdentity == opt.name;
                return _CardOption(
                  selected: selected,
                  icon: opt.icon,
                  label: opt.name,
                  onTap: () {
                    setState(() => _selectedIdentity = opt.name);
                  },
                );
              }).toList(),
            ),
          ),

          const Spacer(flex: 1),

          // Continue
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _selectedIdentity != null ? _goNext : null,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Continue'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PAGE 2 — PRIMARY GOAL
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildGoalPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 1),

          Text(
            'What is your primary goal?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pick one main focus for your journey.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Expanded(
            child: ListView.separated(
              itemCount: _goalOptions.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final opt = _goalOptions[index];
                final selected = _selectedGoal == opt.name;
                return _ListTileOption(
                  selected: selected,
                  icon: opt.icon,
                  label: opt.name,
                  onTap: () {
                    setState(() => _selectedGoal = opt.name);
                  },
                );
              },
            ),
          ),

          const Spacer(flex: 1),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _selectedGoal != null ? _goNext : null,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Continue'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PAGE 3 — EXPERIENCE LEVEL
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildExperiencePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 1),

          Text(
            'What is your experience level?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'This helps us tailor the journey to your needs.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _experienceOptions.map((opt) {
                final selected = _selectedExperience == opt.name;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _CardOption(
                    selected: selected,
                    icon: _experienceIcon(opt.name),
                    label: opt.name,
                    subtitle: opt.desc,
                    onTap: () {
                      setState(() => _selectedExperience = opt.name);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const Spacer(flex: 1),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _selectedExperience != null ? _goNext : null,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Continue'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  IconData _experienceIcon(String level) {
    switch (level) {
      case 'Beginner':
        return Icons.eco_outlined;
      case 'Intermediate':
        return Icons.trending_up_outlined;
      case 'Advanced':
        return Icons.rocket_outlined;
      case 'Expert':
        return Icons.stars_outlined;
      default:
        return Icons.person_outline;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // PAGE 4 — LEARNING PREFERENCES
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildPreferencesPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 1),

          Text(
            'How do you prefer to learn?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Select all that apply.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.1,
              physics: const NeverScrollableScrollPhysics(),
              children: _preferenceOptions.map((opt) {
                final selected = _selectedPreferences.contains(opt.name);
                return _CardOption(
                  selected: selected,
                  icon: opt.icon,
                  label: opt.name,
                  multiSelect: true,
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedPreferences.remove(opt.name);
                      } else {
                        _selectedPreferences.add(opt.name);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),

          const Spacer(flex: 1),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _goNext,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(
                _selectedPreferences.isNotEmpty
                    ? 'Continue'
                    : 'Skip — I\'ll figure it out',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PAGE 5 — MISSION PREVIEW
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildMissionPreviewPage() {
    final identity = _selectedIdentity ?? 'learner';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),

          Text(
            'Your First Mission',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'A sneak peek at what\'s waiting for you.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Preview card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.rocket_launch_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                Text(
                  'Complete $identity Fundamentals',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),

                Text(
                  'Learn the core concepts and skills needed to start '
                  'your journey as a $identity.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _PreviewStat(
                      icon: Icons.timer_outlined,
                      value: '30 min',
                      label: 'Est. Time',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    _PreviewStat(
                      icon: Icons.stars_outlined,
                      value: '+50 XP',
                      label: 'Reward',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    _PreviewStat(
                      icon: Icons.flag_outlined,
                      value: '4',
                      label: 'Lessons',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(flex: 1),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _goNext,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Looks Great!'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PAGE 6 — FINISH
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildFinishPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Celebration
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.6),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          Text(
            'Welcome to Phoenix!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            'Your journey begins now.\n'
            'Let\'s grow, track, and achieve together.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),

          const Spacer(flex: 1),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _completeOnboarding,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Enter Phoenix'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Shared widgets
// ═══════════════════════════════════════════════════════════════════════

/// A selectable card option with icon and label.
class _CardOption extends StatelessWidget {
  const _CardOption({
    required this.selected,
    required this.icon,
    required this.label,
    this.subtitle,
    this.multiSelect = false,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool multiSelect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: selected ? AppColors.primary : theme.colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected
                    ? AppColors.primary
                    : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ],
            if (multiSelect && selected)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A selectable list tile option with icon and label.
class _ListTileOption extends StatelessWidget {
  const _ListTileOption({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: selected ? AppColors.primary : theme.colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? AppColors.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle_rounded,
                size: 22,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

/// A small stat item used in the mission preview.
class _PreviewStat extends StatelessWidget {
  const _PreviewStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Data classes
// ═══════════════════════════════════════════════════════════════════════

class _IdentityOption {
  const _IdentityOption({required this.icon, required this.name});
  final IconData icon;
  final String name;
}

class _GoalOption {
  const _GoalOption({required this.icon, required this.name});
  final IconData icon;
  final String name;
}

class _ExperienceOption {
  const _ExperienceOption({required this.name, required this.desc});
  final String name;
  final String desc;
}

class _PreferenceOption {
  const _PreferenceOption({required this.icon, required this.name});
  final IconData icon;
  final String name;
}
