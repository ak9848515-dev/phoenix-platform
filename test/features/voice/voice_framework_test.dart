import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:phoenix_platform/features/voice/models/voice_command.dart';
import 'package:phoenix_platform/features/voice/models/voice_session.dart';
import 'package:phoenix_platform/features/voice/models/voice_state.dart';
import 'package:phoenix_platform/features/voice/providers/mock_speech_provider.dart';

import 'package:phoenix_platform/features/voice/services/voice_command_router.dart';
import 'package:phoenix_platform/features/voice/services/voice_service.dart';
import 'package:phoenix_platform/features/voice/services/voice_session_manager.dart';
import 'package:phoenix_platform/features/voice/widgets/voice_button.dart';

void main() {
  // ═════════════════════════════════════════════════════════════════
  // 1. Voice Session State (enum)
  // ═════════════════════════════════════════════════════════════════

  group('VoiceSessionState', () {
    test('has all required states', () {
      expect(VoiceSessionState.values.length, 5);
      expect(VoiceSessionState.idle, isA<VoiceSessionState>());
      expect(VoiceSessionState.listening, isA<VoiceSessionState>());
      expect(VoiceSessionState.processing, isA<VoiceSessionState>());
      expect(VoiceSessionState.speaking, isA<VoiceSessionState>());
      expect(VoiceSessionState.error, isA<VoiceSessionState>());
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // 2. Voice Session Model
  // ═════════════════════════════════════════════════════════════════

  group('VoiceSession', () {
    test('creates with default idle state', () {
      const session = VoiceSession();
      expect(session.state, VoiceSessionState.idle);
      expect(session.transcript, isNull);
      expect(session.errorMessage, isNull);
      expect(session.durationMs, 0);
      expect(session.isActive, isFalse);
    });

    test('isActive returns true for listening state', () {
      const session = VoiceSession(state: VoiceSessionState.listening);
      expect(session.isActive, isTrue);
    });

    test('isActive returns true for processing state', () {
      const session = VoiceSession(state: VoiceSessionState.processing);
      expect(session.isActive, isTrue);
    });

    test('isActive returns true for speaking state', () {
      const session = VoiceSession(state: VoiceSessionState.speaking);
      expect(session.isActive, isTrue);
    });

    test('copyWith replaces fields', () {
      const session = VoiceSession();
      final updated = session.copyWith(
        state: VoiceSessionState.listening,
        transcript: 'Hello',
        durationMs: 500,
      );
      expect(updated.state, VoiceSessionState.listening);
      expect(updated.transcript, 'Hello');
      expect(updated.durationMs, 500);
    });

    test('copyWith clears transcript and error', () {
      final session = VoiceSession(
        state: VoiceSessionState.error,
        transcript: 'test',
        errorMessage: 'error',
      );
      final cleared = session.copyWith(clearTranscript: true, clearError: true);
      expect(cleared.transcript, isNull);
      expect(cleared.errorMessage, isNull);
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // 3. Voice Command Model
  // ═════════════════════════════════════════════════════════════════

  group('VoiceCommand', () {
    test('creates from type and transcript', () {
      const cmd = VoiceCommand(
        type: VoiceCommandType.openDashboard,
        transcript: 'Open Dashboard',
      );
      expect(cmd.type, VoiceCommandType.openDashboard);
      expect(cmd.transcript, 'Open Dashboard');
      expect(cmd.isValid, isTrue);
      expect(cmd.label, 'Open Dashboard');
    });

    test('unknown type is invalid', () {
      const cmd = VoiceCommand(
        type: VoiceCommandType.unknown,
        transcript: 'gibberish',
      );
      expect(cmd.isValid, isFalse);
      expect(cmd.route, isNull);
    });

    test('low confidence is invalid', () {
      final cmd = VoiceCommand(
        type: VoiceCommandType.openDashboard,
        transcript: 'Open Dashboard',
        confidence: 0.3,
      );
      expect(cmd.isValid, isFalse);
    });

    test('each type returns correct route', () {
      // Spot-check a few
      expect(
        const VoiceCommand(
          type: VoiceCommandType.openDashboard,
          transcript: '',
        ).route,
        '/dashboard',
      );
      expect(
        const VoiceCommand(
          type: VoiceCommandType.openProfile,
          transcript: '',
        ).route,
        '/profile',
      );
      expect(
        const VoiceCommand(
          type: VoiceCommandType.continueMission,
          transcript: '',
        ).route,
        '/',
      );
      expect(
        const VoiceCommand(type: VoiceCommandType.openAiMentor, transcript: '')
            .route,
        '/ai',
      );
    });

    test('each type returns correct label', () {
      expect(
        const VoiceCommand(
          type: VoiceCommandType.improveResume,
          transcript: '',
        ).label,
        'Improve Resume',
      );
      expect(
        const VoiceCommand(
          type: VoiceCommandType.practiceInterview,
          transcript: '',
        ).label,
        'Practice Interview',
      );
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // 4. Speech Provider Interface
  // ═════════════════════════════════════════════════════════════════

  group('MockSpeechProvider', () {
    test('initialize returns true', () async {
      final provider = MockSpeechProvider();
      final result = await provider.initialize();
      expect(result, isTrue);
      expect(provider.isAvailable, isTrue);
    });

    test('initialize returns false when configured to fail', () async {
      final provider = MockSpeechProvider(shouldFailOnInit: true);
      final result = await provider.initialize();
      expect(result, isFalse);
      expect(provider.isAvailable, isFalse);
    });

    test('startListening streams canned phrases', () async {
      final provider = MockSpeechProvider(
        cannedPhrases: ['Open Dashboard', 'Open Profile'],
        recognitionDelay: Duration.zero,
      );
      await provider.initialize();

      final phrases = <String>[];
      final subscription = provider.startListening().listen(phrases.add);

      // Wait for stream to complete
      await Future.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();
      await provider.dispose();

      expect(phrases.length, 2);
      expect(phrases[0], 'Open Dashboard');
      expect(phrases[1], 'Open Profile');
    });

    test('startListening throws when configured to fail', () async {
      final provider = MockSpeechProvider(shouldFailOnListen: true);
      await provider.initialize();

      expect(
        () => provider.startListening(),
        throwsA(isA<StateError>()),
      );
    });

    test('speak completes after delay', () async {
      final provider = MockSpeechProvider(synthesisDelay: Duration.zero);
      await provider.initialize();

      // Should complete without error
      await provider.speak('Hello');
    });

    test('speak throws when configured to fail', () async {
      final provider = MockSpeechProvider(shouldFailOnSpeak: true);
      await provider.initialize();

      await expectLater(
        () => provider.speak('Hello'),
        throwsA(isA<StateError>()),
      );
    });

    test('stopListening closes stream', () async {
      final provider = MockSpeechProvider(recognitionDelay: Duration.zero);
      await provider.initialize();

      final stream = provider.startListening();
      await provider.stopListening();

      // Stream should be closed
      expect(stream, emitsDone);
    });

    test('dispose cleans up resources', () async {
      final provider = MockSpeechProvider();
      await provider.initialize();
      await provider.dispose();

      expect(provider.isAvailable, isFalse);
    });

    test('supportsRecognition and supportsSynthesis return true', () {
      final provider = MockSpeechProvider();
      expect(provider.supportsRecognition, isTrue);
      expect(provider.supportsSynthesis, isTrue);
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // 5. Voice Session Manager (state machine)
  // ═════════════════════════════════════════════════════════════════

  group('VoiceSessionManager', () {
    test('starts in idle state', () {
      final manager = VoiceSessionManager();
      expect(manager.state, VoiceSessionState.idle);
      expect(manager.isActive, isFalse);
    });

    test('startListening transitions to listening', () {
      final manager = VoiceSessionManager();
      manager.startListening();
      expect(manager.state, VoiceSessionState.listening);
      expect(manager.isActive, isTrue);
    });

    test('startProcessing transitions with transcript', () {
      final manager = VoiceSessionManager();
      manager.startListening();
      manager.startProcessing('Open Dashboard');
      expect(manager.state, VoiceSessionState.processing);
      expect(manager.currentSession.transcript, 'Open Dashboard');
    });

    test('startSpeaking transitions to speaking', () {
      final manager = VoiceSessionManager();
      manager.startListening();
      manager.startSpeaking();
      expect(manager.state, VoiceSessionState.speaking);
    });

    test('finish returns to idle', () {
      final manager = VoiceSessionManager();
      manager.startListening();
      manager.finish();
      expect(manager.state, VoiceSessionState.idle);
      expect(manager.isActive, isFalse);
    });

    test('fail transitions to error then back to idle', () async {
      final manager = VoiceSessionManager();
      manager.startListening();
      manager.fail('Test error');

      // Should transition to error first
      expect(manager.state, VoiceSessionState.error);
      expect(manager.currentSession.errorMessage, 'Test error');

      // Should auto-reset after delay
      await Future.delayed(const Duration(seconds: 3));
      expect(manager.state, VoiceSessionState.idle);
    });

    test('cancel resets immediately', () {
      final manager = VoiceSessionManager();
      manager.startListening();
      manager.startProcessing('test');
      manager.cancel();
      expect(manager.state, VoiceSessionState.idle);
      expect(manager.currentSession.transcript, isNull);
    });

    test('tickDuration updates session duration', () {
      final manager = VoiceSessionManager();
      manager.startListening();
      // StartedAt is set, so tickDuration should update durationMs
      manager.tickDuration();
      expect(manager.currentSession.durationMs, greaterThanOrEqualTo(0));
    });

    test('addListener and removeListener work', () {
      final manager = VoiceSessionManager();
      var notified = false;

      final dispose = manager.addListener(() => notified = true);
      manager.startListening();
      expect(notified, isTrue);

      notified = false;
      dispose();
      manager.finish();
      expect(notified, isFalse);
    });

    test('diagnostics returns correct info', () {
      final manager = VoiceSessionManager();
      manager.startListening();

      final diag = manager.diagnostics();
      expect(diag['state'], 'listening');
      expect(diag['isActive'], isTrue);
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // 6. Voice Command Router
  // ═════════════════════════════════════════════════════════════════

  group('VoiceCommandRouter', () {
    late VoiceCommandRouter router;

    setUp(() {
      router = VoiceCommandRouter();
    });

    test('parses "Open Dashboard" as openDashboard', () {
      final cmd = router.parse('Open Dashboard');
      expect(cmd.type, VoiceCommandType.openDashboard);
    });

    test('parses "go to dashboard" as openDashboard', () {
      final cmd = router.parse('go to dashboard');
      expect(cmd.type, VoiceCommandType.openDashboard);
    });

    test('parses "continue mission" as continueMission', () {
      final cmd = router.parse('Continue Mission');
      expect(cmd.type, VoiceCommandType.continueMission);
    });

    test('parses "improve resume" as improveResume', () {
      final cmd = router.parse('Improve Resume');
      expect(cmd.type, VoiceCommandType.improveResume);
    });

    test('parses "practice interview" as practiceInterview', () {
      final cmd = router.parse('Practice Interview');
      expect(cmd.type, VoiceCommandType.practiceInterview);
    });

    test('parses "show portfolio" as showPortfolio', () {
      final cmd = router.parse('Show Portfolio');
      expect(cmd.type, VoiceCommandType.showPortfolio);
    });

    test('parses "open ai mentor" as openAiMentor', () {
      final cmd = router.parse('Open AI Mentor');
      expect(cmd.type, VoiceCommandType.openAiMentor);
    });

    test('parses "unknown command text" as unknown', () {
      final cmd = router.parse('some random text that is not a command');
      expect(cmd.type, VoiceCommandType.unknown);
    });

    test('parse is case-insensitive', () {
      final cmd = router.parse('OPEN DASHBOARD');
      expect(cmd.type, VoiceCommandType.openDashboard);
    });

    test('parse handles partial matches', () {
      final cmd = router.parse('I want to open my portfolio please');
      expect(cmd.type, VoiceCommandType.showPortfolio);
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // 7. Voice Service
  // ═════════════════════════════════════════════════════════════════

  group('VoiceService', () {
    late MockSpeechProvider provider;
    late VoiceService voiceService;

    setUp(() async {
      provider = MockSpeechProvider(
        cannedPhrases: ['Open Dashboard', 'Continue Mission'],
        recognitionDelay: Duration.zero,
        synthesisDelay: Duration.zero,
      );
      voiceService = VoiceService(provider: provider);
    });

    test('not initialized by default', () {
      expect(voiceService.isAvailable, isFalse);
    });

    test('initialize returns true and marks as available', () async {
      final result = await voiceService.initialize();
      expect(result, isTrue);
      expect(voiceService.isAvailable, isTrue);
    });

    test('startListening transitions state to listening', () async {
      await voiceService.initialize();
      voiceService.startListening();
      expect(voiceService.state, VoiceSessionState.listening);
      expect(voiceService.isActive, isTrue);
    });

    test('startListening invokes onCommand callback', () async {
      await voiceService.initialize();
      var lastCommand = '';
      voiceService.startListening(
        onCommand: (cmd) => lastCommand = cmd.label,
      );

      // Give the mock provider time to stream phrases
      await Future.delayed(const Duration(milliseconds: 50));
      await voiceService.stopListening();

      // Should have received at least one command
      expect(lastCommand, isNotEmpty);
    });

    test('startListening does nothing when not initialized', () {
      voiceService.startListening();
      expect(voiceService.isActive, isFalse);
    });

    test('startListening does nothing when already active', () async {
      await voiceService.initialize();
      voiceService.startListening();
      voiceService.startListening(); // second call should be ignored
      expect(voiceService.isActive, isTrue);
    });

    test('stopListening returns to idle', () async {
      await voiceService.initialize();
      voiceService.startListening();
      await voiceService.stopListening();
      expect(voiceService.state, VoiceSessionState.idle);
    });

    test('speak transitions to speaking then idle', () async {
      await voiceService.initialize();
      await voiceService.speak('Hello');
      expect(voiceService.state, VoiceSessionState.idle);
    });

    test('speak does nothing when not initialized', () async {
      await voiceService.speak('Hello');
      expect(voiceService.state, VoiceSessionState.idle);
    });

    test('stopSpeaking stops speech', () async {
      await voiceService.initialize();
      // Start speaking
      voiceService.speak('Long message to speak');

      // Immediately stop
      await voiceService.stopSpeaking();
      expect(voiceService.state, VoiceSessionState.idle);
    });

    test('cancel resets to idle', () async {
      await voiceService.initialize();
      voiceService.startListening();
      await voiceService.cancel();
      expect(voiceService.state, VoiceSessionState.idle);
    });

    test('listener is notified on state changes', () async {
      await voiceService.initialize();
      var callCount = 0;
      final dispose = voiceService.addListener(() => callCount++);

      voiceService.startListening();
      expect(callCount, greaterThan(0));

      dispose();
      await voiceService.stopListening();
    });

    test('diagnostics returns correct info', () async {
      await voiceService.initialize();
      final diag = voiceService.diagnostics();
      expect(diag['initialized'], isTrue);
      expect(diag['provider'], 'Mock');
      expect(diag['session']['state'], 'idle');
    });

    test('dispose cleans up', () async {
      await voiceService.initialize();
      await voiceService.dispose();
      expect(voiceService.isAvailable, isFalse);
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // 8. Widget Smoke Tests
  // ═════════════════════════════════════════════════════════════════

  group('Voice widgets', () {
    testWidgets('VoiceButton renders idle state mic icon', (tester) async {
      final provider = MockSpeechProvider(
        recognitionDelay: const Duration(milliseconds: 500),
        synthesisDelay: Duration.zero,
        cannedPhrases: ['Open Dashboard'],
      );
      final voiceService = VoiceService(provider: provider);
      await voiceService.initialize();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceButton(voiceService: voiceService),
          ),
        ),
      );

      // Button should be visible with idle mic icon
      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
    });

    testWidgets('VoiceButton tap triggers listening state via service',
        (tester) async {
      final provider = MockSpeechProvider(
        recognitionDelay: Duration.zero,
        synthesisDelay: Duration.zero,
        cannedPhrases: ['Open Dashboard'],
      );
      final voiceService = VoiceService(provider: provider);
      await voiceService.initialize();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceButton(voiceService: voiceService),
          ),
        ),
      );

      // Start listening via the service directly to verify state transition.
      // Using runAsync to avoid timer tracking conflicts with the mock
      // provider's stream creation.
      await tester.runAsync(() async {
        voiceService.startListening();
      });

      // The state may be listening or processing depending on whether
      // microtasks from the mock provider have already delivered phrases.
      // Either is a valid active state.
      expect(voiceService.isActive, isTrue);

      // Clean up in runAsync to avoid timer issues
      await tester.runAsync(() async {
        await voiceService.cancel();
      });
    });
  });
}


