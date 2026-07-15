import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/ai/engine/conversation_engine.dart'
    show ConversationEngine;
import 'package:phoenix_platform/features/ai/models/conversation_context.dart'
    show ConversationContext;
import 'package:phoenix_platform/features/ai/models/conversation_intent.dart'
    show ConversationIntent;

void main() {
  const engine = ConversationEngine();

  final emptyContext = const ConversationContext();
  final activeContext = const ConversationContext(
    activeHabitCount: 3,
    lessonInProgress: true,
    pendingDecisions: 2,
    todaysEvents: 5,
    knowledgeNodes: 10,
  );

  group('detectIntent', () {
    test('detects greeting intent for hello', () {
      final (intent, confidence) = engine.detectIntent('hello');
      expect(intent, ConversationIntent.greeting);
      expect(confidence, greaterThan(0.9));
    });

    test('detects greeting intent for hi', () {
      final (intent, _) = engine.detectIntent('Hi there!');
      expect(intent, ConversationIntent.greeting);
    });

    test('detects progress intent for "how am i doing"', () {
      final (intent, _) = engine.detectIntent('How am I doing?');
      expect(intent, ConversationIntent.progress);
    });

    test('detects progress intent for "my progress"', () {
      final (intent, _) = engine.detectIntent('Show my progress');
      expect(intent, ConversationIntent.progress);
    });

    test('detects learning intent for "learn"', () {
      final (intent, _) = engine.detectIntent('What should I learn today?');
      expect(intent, ConversationIntent.learning);
    });

    test('detects habit intent for "habit"', () {
      final (intent, _) = engine.detectIntent('Show my habit summary');
      expect(intent, ConversationIntent.habit);
    });

    test('detects recommendation intent for "focus on"', () {
      final (intent, _) = engine.detectIntent('What should I focus on?');
      expect(intent, ConversationIntent.recommendation);
    });

    test('detects timeline intent for "timeline"', () {
      final (intent, _) = engine.detectIntent('What happened this week?');
      expect(intent, ConversationIntent.timeline);
    });

    test('detects knowledge intent for "knowledge"', () {
      final (intent, _) = engine.detectIntent('Show my knowledge graph');
      expect(intent, ConversationIntent.knowledge);
    });

    test('detects decision intent for "decision"', () {
      final (intent, _) = engine.detectIntent('Pending decisions');
      expect(intent, ConversationIntent.decision);
    });

    test('detects memory intent for "memory"', () {
      final (intent, _) = engine.detectIntent('Show my memory graph');
      expect(intent, ConversationIntent.memory);
    });

    test('detects career intent for "career"', () {
      final (intent, _) = engine.detectIntent('How job-ready am I?');
      expect(intent, ConversationIntent.career);
    });

    test('detects explanation intent for "why"', () {
      final (intent, _) = engine.detectIntent('Why did I get this insight?');
      expect(intent, ConversationIntent.explanation);
    });

    test('detects insight intent for "improve"', () {
      final (intent, _) = engine.detectIntent('What should I improve?');
      expect(intent, ConversationIntent.insight);
    });

    test('detects planning intent for "plan"', () {
      final (intent, _) = engine.detectIntent('Plan my week');
      expect(intent, ConversationIntent.planning);
    });

    test('returns general for unknown input', () {
      final (intent, confidence) = engine.detectIntent('asdfghjkl');
      expect(intent, ConversationIntent.general);
      expect(confidence, lessThan(0.5));
    });

    test('is case insensitive', () {
      final (intent1, _) = engine.detectIntent('HELLO');
      expect(intent1, ConversationIntent.greeting);

      final (intent2, _) = engine.detectIntent('LEARN FLUTTER');
      expect(intent2, ConversationIntent.learning);
    });
  });

  group('detectIntentWithContext', () {
    test('uses previous topic for low-confidence follow-ups', () {
      // "continue" is a follow-up marker
      final (intent, confidence) = engine.detectIntentWithContext(
        'continue',
        ConversationIntent.learning,
      );
      // "continue" alone doesn't match learning directly, but context should help
      expect(confidence, greaterThanOrEqualTo(0.5));
    });

    test('returns high confidence for strong matches regardless of context', () {
      final (intent, confidence) = engine.detectIntentWithContext(
        'hello',
        ConversationIntent.learning,
      );
      expect(intent, ConversationIntent.greeting);
      expect(confidence, greaterThan(0.9));
    });
  });

  group('generateSuggestions', () {
    test('returns suggestions for greeting intent', () {
      final suggestions = engine.generateSuggestions(
        ConversationIntent.greeting,
        emptyContext,
      );
      expect(suggestions, isNotEmpty);
      expect(suggestions.length, greaterThanOrEqualTo(2));
    });

    test('returns different suggestions for new vs returning user', () {
      final newUserSuggestions = engine.generateSuggestions(
        ConversationIntent.greeting,
        emptyContext,
      );
      final returningSuggestions = engine.generateSuggestions(
        ConversationIntent.greeting,
        activeContext,
      );
      // New user and returning user suggestions should differ
      final hasDifference = !_listsEqual(newUserSuggestions, returningSuggestions);
      expect(hasDifference, isTrue);
    });

    test('returns suggestions for all intent types', () {
      for (final intent in ConversationIntent.values) {
        final suggestions = engine.generateSuggestions(intent, emptyContext);
        expect(suggestions, isNotEmpty,
            reason: 'Intent ${intent.name} should return suggestions');
      }
    });
  });

  group('topSuggestions', () {
    test('returns top N suggestions', () {
      final suggestions = engine.topSuggestions(
        ConversationIntent.greeting,
        emptyContext,
        count: 2,
      );
      expect(suggestions.length, lessThanOrEqualTo(2));
    });

    test('default count is 3', () {
      final suggestions = engine.topSuggestions(
        ConversationIntent.greeting,
        emptyContext,
      );
      expect(suggestions.length, lessThanOrEqualTo(3));
    });
  });

  group('shouldSwitchContext', () {
    test('returns true when no current topic', () {
      expect(
        engine.shouldSwitchContext(ConversationIntent.learning, null),
        isTrue,
      );
    });

    test('returns false for same topic', () {
      expect(
        engine.shouldSwitchContext(
          ConversationIntent.learning,
          ConversationIntent.learning,
        ),
        isFalse,
      );
    });

    test('returns false for general intent', () {
      expect(
        engine.shouldSwitchContext(
          ConversationIntent.general,
          ConversationIntent.learning,
        ),
        isFalse,
      );
    });

    test('returns false for explanation intent (elaboration)', () {
      expect(
        engine.shouldSwitchContext(
          ConversationIntent.explanation,
          ConversationIntent.learning,
        ),
        isFalse,
      );
    });

    test('returns true for clearly different topics', () {
      expect(
        engine.shouldSwitchContext(
          ConversationIntent.habit,
          ConversationIntent.learning,
        ),
        isTrue,
      );
    });
  });

  group('buildResponse', () {
    test('returns named fields for all intents', () {
      for (final intent in ConversationIntent.values) {
        final response = engine.buildResponse(intent, emptyContext);
        expect(response.message, isNotEmpty,
            reason: 'Intent ${intent.name} should have a message');
        expect(response.confidence, greaterThan(0.0),
            reason: 'Intent ${intent.name} should have confidence > 0');
        expect(response.suggestions, isNotEmpty,
            reason: 'Intent ${intent.name} should have suggestions');
      }
    });

    test('greeting response differs for new vs returning users', () {
      final newUserResponse = engine.buildResponse(
        ConversationIntent.greeting,
        emptyContext,
      );
      final returningResponse = engine.buildResponse(
        ConversationIntent.greeting,
        activeContext,
      );
      expect(newUserResponse.message, isNot(equals(returningResponse.message)));
    });

    test('progress response includes context data', () {
      final response = engine.buildResponse(
        ConversationIntent.progress,
        activeContext,
      );
      expect(response.message, contains('3'));
      expect(response.message, contains('habits'));
    });
  });
}

bool _listsEqual(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
