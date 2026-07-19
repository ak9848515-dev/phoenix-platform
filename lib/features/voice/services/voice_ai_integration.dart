import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../ai_assistant/services/phoenix_assistant_service.dart';
import '../../knowledge_relationship/services/knowledge_relationship_service.dart';
import '../../mission_engine/engine/mission_engine.dart';
import '../../recommendation_engine/engine/recommendation_engine.dart';
import '../models/voice_command.dart';
import 'voice_service.dart';

/// Voice AI Integration — wires voice commands through the full AI pipeline.
///
/// Flow:
/// ```
/// Speech → VoiceService → VoiceCommandRouter → PhoenixAssistantService
///   ↓
/// AI Response → Knowledge Engine → Recommendation Engine → Mission Engine
/// ```
///
/// Handles:
/// - Microphone permissions
/// - Recognition failure with retry
/// - Cancellation
/// - Downstream engine updates
class VoiceAIIntegration {
  VoiceAIIntegration({
    required this.voiceService,
    required this.assistantService,
    this.knowledgeRelationshipService,
    this.recommendationEngine,
    this.missionEngine,
  });

  final VoiceService voiceService;
  final PhoenixAssistantService assistantService;
  final KnowledgeRelationshipService? knowledgeRelationshipService;
  final RecommendationEngine? recommendationEngine;
  final MissionEngine? missionEngine;

  int _retryCount = 0;
  static const int _maxRetries = 3;

  /// Starts listening and processes voice commands through AI.
  Future<void> startVoiceSession({
    required ValueChanged<String> onResult,
    ValueChanged<String>? onError,
    VoidCallback? onListeningStarted,
    VoidCallback? onListeningStopped,
  }) async {
    // Check microphone permission first
    final initialized = await voiceService.initialize();
    if (!initialized) {
      onError?.call(
        'Microphone access is required for voice commands. '
        'Please grant microphone permission in your device settings.',
      );
      return;
    }

    voiceService.startListening(
      onCommand: (command) => _handleCommand(command, onResult, onError),
      onListeningStarted: onListeningStarted,
      onListeningStopped: onListeningStopped,
    );
  }

  /// Handles a recognized voice command through the AI pipeline.
  Future<void> _handleCommand(
    VoiceCommand command,
    ValueChanged<String> onResult,
    ValueChanged<String>? onError,
  ) async {
    if (!command.isValid) {
      // Unknown command — send to AI for smart interpretation
      await _handleUnknownCommand(command.transcript, onResult, onError);
      return;
    }

    // Known command — use AI to generate response
    await _processWithAI(command.transcript, onResult, onError);
  }

  /// Processes voice input through the full AI pipeline.
  Future<void> _processWithAI(
    String transcript,
    ValueChanged<String> onResult,
    ValueChanged<String>? onError,
  ) async {
    try {
      // 1. Send through AI pipeline
      final response = await assistantService.chat(
        userMessage: '[Voice Command] $transcript. '
            'Provide a brief, spoken-friendly response.',
      );

      if (response.message.isNotEmpty) {
        onResult(response.message);

        // 2. Speak the response
        await voiceService.speak(response.message);

        // 3. Trigger downstream updates
        await _triggerUpdates();
      }
    } catch (e) {
      await _handleError(transcript, onResult, onError);
    }
  }

  /// Sends unknown voice commands to AI for interpretation.
  Future<void> _handleUnknownCommand(
    String transcript,
    ValueChanged<String> onResult,
    ValueChanged<String>? onError,
  ) async {
    try {
      final response = await assistantService.chat(
        userMessage: 'The user said: "$transcript". '
            'Interpret this as a command and respond helpfully.',
      );

      if (response.message.isNotEmpty) {
        onResult(response.message);
        await voiceService.speak(response.message);
        await _triggerUpdates();
      } else {
        onResult("I didn't quite catch that. Could you try again?");
      }
    } catch (e) {
      await _handleError(transcript, onResult, onError);
    }
  }

  /// Handles errors with retry logic.
  Future<void> _handleError(
    String transcript,
    ValueChanged<String> onResult,
    ValueChanged<String>? onError,
  ) async {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      await Future.delayed(Duration(milliseconds: 500 * _retryCount));
      await _processWithAI(transcript, onResult, onError);
    } else {
      _retryCount = 0;
      onError?.call(
        'I\'m having trouble processing that right now. '
        'Please try again in a moment.',
      );
    }
  }

  /// Triggers downstream updates to knowledge, recommendation, and mission engines.
  Future<void> _triggerUpdates() async {
    await Future.wait([
      // Knowledge context update requires AIContextSnapshot — skipped
      // when no context is available at the time of voice command
      if (recommendationEngine != null)
        Future(() => recommendationEngine!.evaluate()),
      if (missionEngine != null) Future(() => missionEngine!.refresh()),
    ]);
  }

  /// Stops the current voice session.
  Future<void> stopVoiceSession() async {
    _retryCount = 0;
    await voiceService.stopListening();
  }

  /// Cancels the current voice session.
  Future<void> cancelVoiceSession() async {
    _retryCount = 0;
    await voiceService.cancel();
  }

  /// Returns diagnostic information.
  Map<String, dynamic> diagnostics() {
    return {
      'retryCount': _retryCount,
      'maxRetries': _maxRetries,
      'voiceAvailable': voiceService.isAvailable,
      'voiceActive': voiceService.isActive,
    };
  }
}
