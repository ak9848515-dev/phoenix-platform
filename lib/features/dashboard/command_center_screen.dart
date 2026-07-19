import 'package:flutter/material.dart';

import '../../core/bootstrap.dart';
import '../../shared/widgets/phoenix_skeleton_loader.dart';
import 'widgets/dashboard_welcome_section.dart';
import 'widgets/progressive_sections.dart';

/// The Phoenix Dashboard — a calm, premium, story-telling experience.
///
/// First visible screen contains ONLY:
/// • AI-generated Welcome
/// • Subtle animated premium background
/// • Today's Focus (single highest priority)
/// • Continue button
///
/// Scrolling progressively reveals:
/// 1. Growth Journey Timeline
/// 2. Today's Missions
/// 3. Progress
/// 4. AI Insight
/// 5. Continue Learning
/// 6. Personalized Recommendations
///
/// Architecture:
/// - All data sourced from engine snapshots only
/// - No direct service access
/// - Tells a story, doesn't show data
class CommandCenterScreen extends StatefulWidget {
  const CommandCenterScreen({super.key});

  @override
  State<CommandCenterScreen> createState() => _CommandCenterScreenState();
}

class _CommandCenterScreenState extends State<CommandCenterScreen> {
  bool _isLoading = true;
  DateTime _lastFrameTime = DateTime.now();
  bool _frameTrackingStarted = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_frameTrackingStarted) {
      _frameTrackingStarted = true;
      _scheduleNextFrame();
    }
  }

  void _scheduleNextFrame() {
    WidgetsBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _onFrame(Duration _) {
    if (!mounted) return;
    final now = DateTime.now();
    final elapsed = now.difference(_lastFrameTime).inMilliseconds;
    _lastFrameTime = now;
    final diagnostics = AppBootstrap.maybeDiagnosticsService;
    diagnostics?.recordFrameTime(elapsed);
    _scheduleNextFrame();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final diagnostics = AppBootstrap.maybeDiagnosticsService;
    diagnostics?.recordWidgetRebuild('CommandCenterScreen');

    if (_isLoading) {
      return ShimmerLoader(
        child: const DashboardSkeleton(),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const DashboardWelcomeSection(),
        const ProgressiveSections(),
      ],
    );
  }
}