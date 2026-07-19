import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../routes/app_routes.dart';
import '../intelligence/models/interview_enums.dart';
import '../intelligence/models/interview_feedback_detail.dart';
import '../intelligence/models/interview_question_detail.dart';
import '../intelligence/models/interview_session_detail.dart';

/// Full-screen mock interview practice session with question navigation,
/// timer tracking, answer recording, and post-session feedback.
class MockInterviewSessionScreen extends StatefulWidget {
  const MockInterviewSessionScreen({super.key});

  @override
  State<MockInterviewSessionScreen> createState() =>
      _MockInterviewSessionScreenState();
}

class _MockInterviewSessionScreenState
    extends State<MockInterviewSessionScreen> {
  InterviewSessionDetail? _session;
  InterviewFeedbackDetail? _feedback;
  int _currentQuestionIndex = 0;
  int _elapsedSeconds = 0;
  bool _showFeedback = false;
  bool _sessionEnded = false;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  void _initializeSession() {
    final engine = AppBootstrap.maybeInterviewIntelligenceEngine;
    if (engine == null) return;

    // Create a new session if none exists
    final session = engine.createSession(
      title: 'Mock Interview Practice',
      difficulty: InterviewDifficulty.medium,
      durationMinutes: 45,
    );
    setState(() {
      _session = session;
      _currentQuestionIndex = 0;
    });
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || _sessionEnded) return false;
      setState(() => _elapsedSeconds++);
      return true;
    });
  }

  InterviewQuestionDetail get _currentQuestion {
    if (_session == null || _session!.questions.isEmpty) {
      return InterviewQuestionDetail(
        id: 'empty',
        question: 'No questions available.',
      );
    }
    return _session!.questions[
        _currentQuestionIndex.clamp(0, _session!.questions.length - 1)];
  }

  bool get _hasNext => _currentQuestionIndex < (_session?.questions.length ?? 0) - 1;

  bool get _hasPrevious => _currentQuestionIndex > 0;

  void _nextQuestion() {
    if (_hasNext) {
      setState(() => _currentQuestionIndex++);
    }
  }

  void _previousQuestion() {
    if (_hasPrevious) {
      setState(() => _currentQuestionIndex--);
    }
  }

  void _skipQuestion() {
    final engine = AppBootstrap.maybeInterviewIntelligenceEngine;
    if (engine == null || _session == null) return;

    final updated = engine.recordAnswer(
      sessionId: _session!.id,
      questionId: _currentQuestion.id,
      skipped: true,
    );
    if (updated != null) {
      setState(() => _session = updated);
      _nextQuestion();
    }
  }

  void _submitAnswer(String answer, int timeSpent) {
    final engine = AppBootstrap.maybeInterviewIntelligenceEngine;
    if (engine == null || _session == null) return;

    // Score based on answer quality (deterministic heuristic)
    final score = _evaluateAnswer(answer, _currentQuestion);

    final updated = engine.recordAnswer(
      sessionId: _session!.id,
      questionId: _currentQuestion.id,
      answer: answer,
      timeSpentSeconds: timeSpent,
      score: score,
    );
    if (updated != null) {
      setState(() => _session = updated);
      _nextQuestion();
    }
  }

  double _evaluateAnswer(String? answer, InterviewQuestionDetail question) {
    if (answer == null || answer.trim().isEmpty) return 0.0;

    final words = answer.trim().split(RegExp(r'\s+'));
    final wordCount = words.length;
    final hasStructure =
        answer.contains(RegExp(r'(first|second|third|finally|because|therefore|however)',
            caseSensitive: false));
    final hasExample =
        answer.contains(RegExp(r'(for example|for instance|specifically|such as)',
            caseSensitive: false));
    final hasMetrics = answer.contains(RegExp(r'(\d+%|\d+x|\d+ users|\d+ customers|improved|increased|reduced)',
        caseSensitive: false));

    double score = 0.3; // Base score for attempting

    // Length bonus (50-200 words is ideal)
    if (wordCount >= 50 && wordCount <= 200) {
      score += 0.2;
    } else if (wordCount > 200) {
      score += 0.1;
    }

    // Structure bonus
    if (hasStructure) {
      score += 0.2;
    }

    // Example bonus
    if (hasExample) {
      score += 0.15;
    }

    // Metrics bonus
    if (hasMetrics) {
      score += 0.15;
    }

    // Difficulty modifier
    score -= question.difficulty.weight * 0.1;

    return score.clamp(0.0, 1.0);
  }

  void _endSession() {
    final engine = AppBootstrap.maybeInterviewIntelligenceEngine;
    if (engine == null || _session == null) return;

    setState(() => _sessionEnded = true);
    final feedback = engine.completeSession(_session!.id);
    setState(() {
      _feedback = feedback;
      _showFeedback = true;
    });
  }

  void _returnToInterview() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.interview,
      (route) => route.settings.name == AppRoutes.dashboard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Interview Practice')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_showFeedback && _feedback != null) {
      return _buildFeedbackView(theme);
    }

    final progress = _session!.questions.isEmpty
        ? 0.0
        : _session!.answeredCount / _session!.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _session!.title,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          // Timer
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_elapsedSeconds),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _elapsedSeconds > 2700
                          ? PhoenixColors.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // End session
          IconButton(
            icon: const Icon(Icons.stop_circle_outlined),
            tooltip: 'End session',
            onPressed: _endSession,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(PhoenixSpacing.lg),
        child: Column(
          children: [
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: PhoenixSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${_session!.questions.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${_session!.answeredCount} answered',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: PhoenixColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PhoenixSpacing.lg),

            // Question card
            Expanded(
              child: SingleChildScrollView(
                child: _buildQuestionCard(theme),
              ),
            ),

            // Navigation
            _buildNavigation(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(ThemeData theme) {
    final q = _currentQuestion;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: PhoenixRadius.xlRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category & Difficulty badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _categoryColor(q.category, theme).withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  q.category.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _categoryColor(q.category, theme),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: PhoenixSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _difficultyColor(q.difficulty).withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  q.difficulty.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _difficultyColor(q.difficulty),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PhoenixSpacing.md),

          // Question text
          Text(
            q.question,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: PhoenixSpacing.md),

          // Topics
          if (q.topics.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: q.topics.map((topic) {
                return Chip(
                  label: Text(
                    topic,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  side: BorderSide.none,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                );
              }).toList(),
            ),
            const SizedBox(height: PhoenixSpacing.md),
          ],

          // Tips
          if (q.tips.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(PhoenixSpacing.md),
              decoration: BoxDecoration(
                color: PhoenixColors.info.withAlpha(10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: PhoenixColors.info.withAlpha(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 14, color: PhoenixColors.info),
                      const SizedBox(width: 4),
                      Text('Tips',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: PhoenixColors.info)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...q.tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '• $tip',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigation(ThemeData theme) {
    final q = _currentQuestion;
    final isAnswered = q.isAnswered;
    final questionTime = _elapsedSeconds % (_session!.durationMinutes * 60 ~/ _session!.questions.length);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: PhoenixSpacing.md),
      child: Column(
        children: [
          // Quick score buttons (for ease of use)
          if (!isAnswered) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _submitAnswer(
                      _quickAnswer('strong'),
                      questionTime,
                    ),
                    icon: const Icon(Icons.thumb_up_alt_outlined, size: 16),
                    label: const Text('Strong'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PhoenixColors.success,
                    ),
                  ),
                ),
                const SizedBox(width: PhoenixSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _submitAnswer(
                      _quickAnswer('average'),
                      questionTime,
                    ),
                    icon: const Icon(Icons.thumbs_up_down_outlined, size: 16),
                    label: const Text('Average'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PhoenixColors.warning,
                    ),
                  ),
                ),
                const SizedBox(width: PhoenixSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _submitAnswer(
                      _quickAnswer('weak'),
                      questionTime,
                    ),
                    icon: const Icon(Icons.thumb_down_alt_outlined, size: 16),
                    label: const Text('Weak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PhoenixColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PhoenixSpacing.sm),
          ],

          // Navigation controls
          Row(
            children: [
              if (_hasPrevious)
                Expanded(
                  child: TextButton.icon(
                    onPressed: _previousQuestion,
                    icon: const Icon(Icons.chevron_left_rounded, size: 18),
                    label: const Text('Previous'),
                  ),
                ),
              if (_hasPrevious && _hasNext)
                const SizedBox(width: PhoenixSpacing.sm),
              if (_hasNext)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isAnswered ? _nextQuestion : _skipQuestion,
                    icon: Icon(
                      isAnswered ? Icons.chevron_right_rounded : Icons.skip_next_rounded,
                      size: 18,
                    ),
                    label: Text(isAnswered ? 'Next' : 'Skip'),
                  ),
                ),
              if (!_hasNext)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _endSession,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Complete Session'),
                    style: FilledButton.styleFrom(
                      backgroundColor: PhoenixColors.success,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackView(ThemeData theme) {
    final f = _feedback!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Complete'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _returnToInterview,
            child: const Text('Done'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(PhoenixSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary
            FadeAnimation(
              duration: const Duration(milliseconds: 500),
              delay: Duration.zero,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(PhoenixSpacing.xl),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      f.isGoodSession
                          ? PhoenixColors.success.withAlpha(30)
                          : f.needsImprovement
                              ? PhoenixColors.error.withAlpha(30)
                              : PhoenixColors.warning.withAlpha(30),
                      PhoenixColors.surfaceVariant,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: PhoenixRadius.xlRadius,
                ),
                child: Column(
                  children: [
                    Icon(
                      f.isGoodSession
                          ? Icons.emoji_events_rounded
                          : f.needsImprovement
                              ? Icons.trending_up_rounded
                              : Icons.thumbs_up_down_rounded,
                      size: 48,
                      color: f.isGoodSession
                          ? PhoenixColors.success
                          : f.needsImprovement
                              ? PhoenixColors.warning
                              : PhoenixColors.info,
                    ),
                    const SizedBox(height: PhoenixSpacing.md),
                    Text(
                      f.summary.isNotEmpty
                          ? f.summary
                          : f.isGoodSession
                              ? 'Great session!'
                              : f.needsImprovement
                                  ? 'Keep practicing!'
                                  : 'Good effort!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: PhoenixSpacing.sm),
                    Text(
                      'Overall: ${(f.overallScore * 100).round()}%',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: f.isGoodSession
                            ? PhoenixColors.success
                            : f.needsImprovement
                                ? PhoenixColors.warning
                                : PhoenixColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PhoenixSpacing.lg),

            // Score breakdown
            FadeAnimation(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 200),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(PhoenixSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                  borderRadius: PhoenixRadius.xlRadius,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Score Breakdown',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600)),
                    const SizedBox(height: PhoenixSpacing.md),
                    _scoreRow(theme, 'Technical', f.technicalScore, PhoenixColors.primary),
                    const SizedBox(height: PhoenixSpacing.sm),
                    _scoreRow(theme, 'Behavioral', f.behavioralScore, theme.colorScheme.tertiary),
                    const SizedBox(height: PhoenixSpacing.sm),
                    _scoreRow(theme, 'Communication', f.communicationScore, PhoenixColors.info),
                    const SizedBox(height: PhoenixSpacing.sm),
                    _scoreRow(theme, 'Confidence', f.confidenceScore, PhoenixColors.warning),
                    const SizedBox(height: PhoenixSpacing.sm),
                    _scoreRow(theme, 'Preparation', f.preparationScore, PhoenixColors.success),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PhoenixSpacing.lg),

            // Strengths
            if (f.strengths.isNotEmpty) ...[
              FadeAnimation(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 300),
                child: _feedbackListSection(
                  theme: theme,
                  title: 'Strengths',
                  icon: Icons.check_circle_outline,
                  iconColor: PhoenixColors.success,
                  items: f.strengths,
                ),
              ),
              const SizedBox(height: PhoenixSpacing.md),
            ],

            // Weak areas
            if (f.weakAreas.isNotEmpty) ...[
              FadeAnimation(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 350),
                child: _feedbackListSection(
                  theme: theme,
                  title: 'Areas to Improve',
                  icon: Icons.trending_up_rounded,
                  iconColor: PhoenixColors.warning,
                  items: f.weakAreas,
                ),
              ),
              const SizedBox(height: PhoenixSpacing.md),
            ],

            // Improvement plan
            if (f.improvementPlan.isNotEmpty) ...[
              FadeAnimation(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 400),
                child: _feedbackListSection(
                  theme: theme,
                  title: 'Improvement Plan',
                  icon: Icons.flag_rounded,
                  iconColor: PhoenixColors.info,
                  items: f.improvementPlan,
                ),
              ),
              const SizedBox(height: PhoenixSpacing.md),
            ],

            // Technical feedback
            if (f.technicalFeedback.isNotEmpty) ...[
              FadeAnimation(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 450),
                child: _feedbackListSection(
                  theme: theme,
                  title: 'Technical Feedback',
                  icon: Icons.code_rounded,
                  iconColor: PhoenixColors.primary,
                  items: f.technicalFeedback,
                ),
              ),
              const SizedBox(height: PhoenixSpacing.md),
            ],

            // Next practice focus
            if (f.nextPracticeFocus.isNotEmpty) ...[
              FadeAnimation(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 500),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(PhoenixSpacing.lg),
                  decoration: BoxDecoration(
                    color: PhoenixColors.info.withAlpha(10),
                    borderRadius: PhoenixRadius.xlRadius,
                    border: Border.all(
                      color: PhoenixColors.info.withAlpha(30),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.tips_and_updates_rounded,
                          size: 20, color: PhoenixColors.info),
                      const SizedBox(width: PhoenixSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Next Practice Focus',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: PhoenixColors.info)),
                            const SizedBox(height: 4),
                            Text(f.nextPracticeFocus,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: PhoenixSpacing.xl),

            // Return button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _returnToInterview,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Return to Interview Prep'),
              ),
            ),
            const SizedBox(height: PhoenixSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _scoreRow(ThemeData theme, String label, double score, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: PhoenixSpacing.sm),
        SizedBox(
          width: 36,
          child: Text(
            '${(score * 100).round()}%',
            textAlign: TextAlign.right,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _feedbackListSection({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      decoration: BoxDecoration(
        color: iconColor.withAlpha(8),
        borderRadius: PhoenixRadius.xlRadius,
        border: Border.all(color: iconColor.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: PhoenixSpacing.sm),
              Text(title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: PhoenixSpacing.sm),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(item,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.4,
                      )),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Color _categoryColor(InterviewQuestionCategory category, ThemeData theme) {
    switch (category) {
      case InterviewQuestionCategory.technical:
        return theme.colorScheme.primary;
      case InterviewQuestionCategory.behavioral:
        return theme.colorScheme.tertiary;
      case InterviewQuestionCategory.scenario:
        return PhoenixColors.warning;
      case InterviewQuestionCategory.coding:
        return PhoenixColors.success;
      case InterviewQuestionCategory.projectDiscussion:
        return PhoenixColors.info;
      case InterviewQuestionCategory.resumeBased:
        return Colors.purple;
    }
  }

  Color _difficultyColor(InterviewDifficulty difficulty) {
    switch (difficulty) {
      case InterviewDifficulty.easy:
        return PhoenixColors.success;
      case InterviewDifficulty.medium:
        return PhoenixColors.warning;
      case InterviewDifficulty.hard:
        return PhoenixColors.error;
      case InterviewDifficulty.expert:
        return Colors.purple;
    }
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  String _quickAnswer(String quality) {
    switch (quality) {
      case 'strong':
        return 'I have extensive experience with this area. In my recent project, '
            'I implemented a solution that improved performance by 40%. '
            'First, I analyzed the requirements, then designed the architecture, '
            'and finally executed the implementation. For example, I used '
            'specific patterns to handle edge cases effectively.';
      case 'average':
        return 'I have some experience with this topic. I worked on a similar '
            'challenge before and used standard approaches to solve it. '
            'The results were satisfactory and I learned valuable lessons.';
      case 'weak':
        return 'I have limited experience with this topic. I understand the '
            'concepts but need more hands-on practice to feel confident. '
            'I am currently studying to improve my knowledge.';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _sessionEnded = true;
    super.dispose();
  }
}
