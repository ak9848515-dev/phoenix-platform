import '../models/academy_lesson.dart';
import '../models/academy_module.dart';
import '../models/exercise.dart';
import '../models/learning_path.dart';
import '../models/lesson_content.dart';
import '../models/quiz_question.dart';

/// Registry of all available learning paths in the Academy.
///
/// This is the single source of truth for learning path content.
/// Defaults to hardcoded paths. Use [LearningPathRegistry.fromPaths]
/// to load from persisted data.
class LearningPathRegistry {
  /// Creates a registry with the default hardcoded learning paths.
  LearningPathRegistry() : _paths = _defaultPaths();

  /// Creates a registry with the given [paths] (e.g. loaded from storage).
  LearningPathRegistry.fromPaths(this._paths);

  final List<LearningPath> _paths;

  /// Returns the default hardcoded learning paths.
  static List<LearningPath> _defaultPaths() => [
        _flutterPath(),
        _dartPath(),
        _aiPath(),
        _dataStructuresPath(),
        _systemDesignPath(),
        _sapPath(),
      ];

  /// All registered learning paths.
  List<LearningPath> get allPaths => _paths;

  /// Returns a path by ID, or null if not found.
  LearningPath? findById(String id) {
    try {
      return _paths.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns paths matching career tags.
  List<LearningPath> findByTags(List<String> tags) {
    return _paths
        .where((p) => p.careerTags.any((t) => tags.contains(t)))
        .toList();
  }

  // ── Flutter Development Path ─────────────────────────────────────

  static LearningPath _flutterPath() {
    return LearningPath(
      id: 'flutter',
      title: 'Flutter Development',
      description:
          'Master Flutter from basics to production. Build beautiful, '
          'performant cross-platform apps with confidence.',
      iconName: 'smartphone',
      color: 0xFF1389FD,
      careerTags: ['Mobile', 'UI', 'Cross-Platform'],
      difficulty: 2,
      estimatedHours: 40,
      modules: [
        AcademyModule(
          id: 'flutter-intro',
          title: 'Flutter Fundamentals',
          description: 'Get started with Flutter, widgets, and layouts.',
          order: 0,
          iconName: 'flag',
          lessons: [
            AcademyLesson(
              id: 'flutter-intro-01',
              title: 'What is Flutter?',
              description:
                  'Understand Flutter\'s architecture, widget tree, and '
                  'why it\'s different from other frameworks.',
              durationMinutes: 15,
              contentVersion: 1,
              sections: [
                const LessonContentSection(
                  id: 'fs1',
                  type: LessonContentType.text,
                  data:
                      '# What is Flutter?\n\nFlutter is Google\'s UI toolkit '
                      'for building natively compiled applications for mobile, '
                      'web, and desktop from a single codebase.\n\n'
                      '## Key Concepts\n\n- **Widget Tree**: Everything is a '
                      'widget. Your entire UI is a tree of widgets.\n'
                      '- **Composition over Inheritance**: Combine small '
                      'widgets to build complex UIs.\n'
                      '- **Hot Reload**: See changes instantly during '
                      'development.',
                ),
                const LessonContentSection(
                  id: 'fs2',
                  type: LessonContentType.code,
                  data:
                      'void main() {\n'
                      '  runApp(const MyApp());\n'
                      '}\n\n'
                      'class MyApp extends StatelessWidget {\n'
                      '  const MyApp({super.key});\n\n'
                      '  @override\n'
                      '  Widget build(BuildContext context) {\n'
                      '    return MaterialApp(\n'
                      '      home: Scaffold(\n'
                      '        appBar: AppBar(title: Text("Hello Flutter")),\n'
                      '        body: Center(child: Text("Hello, World!")),\n'
                      '      ),\n'
                      '    );\n'
                      '  }\n'
                      '}',
                  language: 'dart',
                ),
              ],
              quizzes: [
                const QuizQuestion(
                  id: 'fq1',
                  question: 'What is Flutter?',
                  options: [
                    'A programming language',
                    'A UI toolkit by Google',
                    'A database',
                    'An operating system',
                  ],
                  correctAnswerIndex: 1,
                  explanation:
                      'Flutter is Google\'s UI toolkit for building '
                      'natively compiled applications.',
                  points: 10,
                ),
              ],
              exercises: [
                Exercise(
                  id: 'fe1',
                  title: 'Create Your First Widget',
                  description:
                      'Write a Flutter app that displays your name centered '
                      'on the screen with a blue background.',
                  type: ExerciseType.coding,
                  hints: [
                    'Use Scaffold with a backgroundColor property',
                    'Center widget takes a child parameter',
                    'Text widget can display your name',
                  ],
                  points: 20,
                ),
              ],
            ),
            AcademyLesson(
              id: 'flutter-intro-02',
              title: 'Widgets & Layouts',
              description:
                  'Learn the core layout widgets: Row, Column, Stack, '
                  'Container, and how to compose them.',
              durationMinutes: 25,
              contentVersion: 1,
              prerequisiteLessonIds: ['flutter-intro-01'],
              sections: [
                const LessonContentSection(
                  id: 'fl1',
                  type: LessonContentType.text,
                  data:
                      '# Widgets & Layouts\n\nFlutter layouts are built using '
                      'composition. Every layout is a widget.\n\n'
                      '## Core Layout Widgets\n\n'
                      '- **Row**: Horizontal layout\n'
                      '- **Column**: Vertical layout\n'
                      '- **Stack**: Overlapping layout\n'
                      '- **Container**: Box model with padding, margin, decoration',
                ),
              ],
              quizzes: [
                const QuizQuestion(
                  id: 'flq1',
                  question: 'Which widget arranges children vertically?',
                  options: ['Row', 'Column', 'Stack', 'Container'],
                  correctAnswerIndex: 1,
                  explanation:
                      'Column arranges its children vertically.',
                  points: 10,
                ),
              ],
              exercises: [
                Exercise(
                  id: 'fle1',
                  title: 'Build a Profile Card Layout',
                  description:
                      'Create a profile card with an avatar, name, and '
                      'bio using Row, Column, and Container.',
                  type: ExerciseType.coding,
                  hints: [
                    'Use CircleAvatar for the profile picture',
                    'Column for the text layout',
                    'Container with decoration for the card',
                  ],
                  points: 20,
                ),
              ],
            ),
          ],
        ),
        AcademyModule(
          id: 'flutter-state',
          title: 'State Management',
          description: 'Manage app state with setState, Provider, and Riverpod.',
          order: 1,
          iconName: 'toggle_on',
          lessons: [
            AcademyLesson(
              id: 'flutter-state-01',
              title: 'Understanding State',
              description:
                  'Learn the difference between ephemeral and app state.',
              durationMinutes: 20,
              contentVersion: 1,
              prerequisiteLessonIds: ['flutter-intro-02'],
              sections: [
                const LessonContentSection(
                  id: 'fst1',
                  type: LessonContentType.text,
                  data:
                      '# Understanding State\n\nState is any data that can '
                      'change over time. Flutter supports two types:\n\n'
                      '## Ephemeral State\nState local to a widget.\n'
                      '## App State\nState shared across widgets.',
                ),
              ],
              quizzes: [],
              exercises: [],
            ),
          ],
        ),
      ],
    );
  }

  // ── Dart Programming Path ────────────────────────────────────────

  static LearningPath _dartPath() {
    return LearningPath(
      id: 'dart',
      title: 'Dart Programming',
      description:
          'Learn Dart from fundamentals to advanced patterns. '
          'The language powering Flutter.',
      iconName: 'terminal',
      color: 0xFF0175C2,
      careerTags: ['Language', 'OOP', 'Functional'],
      difficulty: 1,
      estimatedHours: 25,
      modules: [
        AcademyModule(
          id: 'dart-basics',
          title: 'Dart Fundamentals',
          description: 'Syntax, types, control flow, and functions.',
          order: 0,
          iconName: 'code',
          lessons: [
            AcademyLesson(
              id: 'dart-basics-01',
              title: 'Variables & Types',
              description:
                  'Learn Dart\'s type system, null safety, and variable '
                  'declarations.',
              durationMinutes: 20,
              contentVersion: 1,
              sections: [
                const LessonContentSection(
                  id: 'db1',
                  type: LessonContentType.text,
                  data:
                      '# Variables & Types\n\nDart is a statically typed '
                      'language with sound null safety.\n\n'
                      '## Key Concepts\n\n'
                      '- `var`, `final`, `const`\n'
                      '- Null safety with `?` and `!`\n'
                      '- Built-in types: int, double, String, bool, List, Map',
                ),
                const LessonContentSection(
                  id: 'db2',
                  type: LessonContentType.code,
                  data:
                      'void main() {\n'
                      '  // Type inference with var\n'
                      '  var name = "Phoenix";\n\n'
                      '  // Explicit typing\n'
                      '  int count = 42;\n\n'
                      '  // Null safety\n'
                      '  String? maybe;\n'
                      '  maybe ??= "default";\n\n'
                      '  print(\'\$name has \$count items\');\n'
                      '}',
                  language: 'dart',
                ),
              ],
              quizzes: [
                const QuizQuestion(
                  id: 'dbq1',
                  question:
                      'Which keyword declares a runtime constant in Dart?',
                  options: ['var', 'final', 'const', 'static'],
                  correctAnswerIndex: 1,
                  explanation:
                      '`final` sets a value once at runtime. '
                      '`const` is a compile-time constant.',
                  points: 10,
                ),
              ],
              exercises: [
                Exercise(
                  id: 'dbe1',
                  title: 'Null Safety Practice',
                  description:
                      'Write a function that safely handles nullable strings.',
                  type: ExerciseType.coding,
                  hints: [
                    'Use the ?. operator for null-safe access',
                    'Use ?? for default values',
                    'Use ! only when you\'re sure it\'s non-null',
                  ],
                  points: 20,
                ),
              ],
            ),
          ],
        ),
        AcademyModule(
          id: 'dart-advanced',
          title: 'Advanced Dart',
          description: 'Generics, async, isolates, and metaprogramming.',
          order: 1,
          iconName: 'auto_awesome',
          lessons: [
            AcademyLesson(
              id: 'dart-advanced-01',
              title: 'Async Programming',
              description:
                  'Master Future, Stream, async/await, and error handling.',
              durationMinutes: 30,
              contentVersion: 1,
              prerequisiteLessonIds: ['dart-basics-01'],
              sections: [
                const LessonContentSection(
                  id: 'da1',
                  type: LessonContentType.text,
                  data:
                      '# Async Programming\n\nDart uses Future and Stream for '
                      'asynchronous programming.\n\n'
                      '## Key Concepts\n\n'
                      '- Future<T> for single values\n'
                      '- Stream<T> for sequences\n'
                      '- async/await syntax\n'
                      '- Error handling with try/catch',
                ),
              ],
              quizzes: [],
              exercises: [],
            ),
          ],
        ),
      ],
    );
  }

  // ── AI & Machine Learning Path ───────────────────────────────────

  static LearningPath _aiPath() {
    return LearningPath(
      id: 'ai',
      title: 'AI & Machine Learning',
      description:
          'Understand AI fundamentals, LLMs, prompt engineering, '
          'and building AI-powered applications.',
      iconName: 'psychology',
      color: 0xFF9C27B0,
      careerTags: ['AI', 'ML', 'Data Science'],
      difficulty: 3,
      estimatedHours: 35,
      modules: [
        AcademyModule(
          id: 'ai-fundamentals',
          title: 'AI Fundamentals',
          description:
              'Core concepts: ML, neural networks, and LLMs.',
          order: 0,
          iconName: 'lightbulb',
          lessons: [
            AcademyLesson(
              id: 'ai-fund-01',
              title: 'What is Machine Learning?',
              description:
                  'Understand supervised, unsupervised, and reinforcement '
                  'learning.',
              durationMinutes: 20,
              contentVersion: 1,
              sections: [
                const LessonContentSection(
                  id: 'ai1',
                  type: LessonContentType.text,
                  data:
                      '# What is Machine Learning?\n\nMachine Learning enables '
                      'computers to learn from data without explicit '
                      'programming.\n\n'
                      '## Types\n\n'
                      '- **Supervised**: Labeled data (classification, regression)\n'
                      '- **Unsupervised**: Unlabeled data (clustering)\n'
                      '- **Reinforcement**: Trial and error (gaming, robotics)',
                ),
              ],
              quizzes: [
                const QuizQuestion(
                  id: 'aiq1',
                  question:
                      'Which ML type uses labeled training data?',
                  options: [
                    'Unsupervised',
                    'Supervised',
                    'Reinforcement',
                    'Transfer',
                  ],
                  correctAnswerIndex: 1,
                  explanation:
                      'Supervised learning uses labeled data to train models.',
                  points: 10,
                ),
              ],
              exercises: [],
            ),
          ],
        ),
      ],
    );
  }

  // ── Data Structures Path ─────────────────────────────────────────

  static LearningPath _dataStructuresPath() {
    return LearningPath(
      id: 'data-structures',
      title: 'Data Structures',
      description:
          'Master essential data structures: arrays, linked lists, trees, '
          'graphs, hash tables, and more.',
      iconName: 'account_tree',
      color: 0xFF4CAF50,
      careerTags: ['Algorithms', 'Computer Science', 'Problem Solving'],
      difficulty: 3,
      estimatedHours: 30,
      modules: [
        AcademyModule(
          id: 'ds-fundamentals',
          title: 'Core Data Structures',
          description: 'Arrays, linked lists, stacks, and queues.',
          order: 0,
          iconName: 'layers',
          lessons: [
            AcademyLesson(
              id: 'ds-fund-01',
              title: 'Arrays & Lists',
              description:
                  'Understand dynamic arrays, time complexity, and '
                  'when to use them.',
              durationMinutes: 20,
              contentVersion: 1,
              sections: [
                const LessonContentSection(
                  id: 'ds1',
                  type: LessonContentType.text,
                  data:
                      '# Arrays & Lists\n\nArrays store elements in '
                      'contiguous memory. Random access is O(1).\n\n'
                      '## Operations\n\n'
                      '- Access: O(1)\n'
                      '- Search: O(n)\n'
                      '- Insert (end): O(1) amortized\n'
                      '- Insert (middle): O(n)\n'
                      '- Delete: O(n)',
                ),
              ],
              quizzes: [
                const QuizQuestion(
                  id: 'dsq1',
                  question: 'What is the time complexity of array access?',
                  options: ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
                  correctAnswerIndex: 0,
                  explanation:
                      'Array access is O(1) — constant time.',
                  points: 10,
                ),
              ],
              exercises: [],
            ),
          ],
        ),
      ],
    );
  }

  // ── System Design Path ───────────────────────────────────────────

  static LearningPath _systemDesignPath() {
    return LearningPath(
      id: 'system-design',
      title: 'System Design',
      description:
          'Design scalable distributed systems. Learn architecture patterns, '
          'trade-offs, and real-world case studies.',
      iconName: 'lan',
      color: 0xFFFF6F00,
      careerTags: ['Architecture', 'Distributed Systems', 'Backend'],
      difficulty: 4,
      estimatedHours: 40,
      modules: [
        AcademyModule(
          id: 'sd-fundamentals',
          title: 'Design Fundamentals',
          description:
              'Latency, throughput, CAP theorem, and load balancing.',
          order: 0,
          iconName: 'foundation',
          lessons: [
            AcademyLesson(
              id: 'sd-fund-01',
              title: 'CAP Theorem',
              description:
                  'Understand the Consistency, Availability, Partition '
                  'Tolerance trade-off.',
              durationMinutes: 25,
              contentVersion: 1,
              sections: [
                const LessonContentSection(
                  id: 'sd1',
                  type: LessonContentType.text,
                  data:
                      '# CAP Theorem\n\nIn a distributed system, you can '
                      'only guarantee two of three properties:\n\n'
                      '- **Consistency**: Every read returns the latest write\n'
                      '- **Availability**: Every request gets a response\n'
                      '- **Partition Tolerance**: System works despite '
                      'network failures\n\n'
                      'In practice, you choose between CP and AP since '
                      'partition tolerance is unavoidable.',
                ),
              ],
              quizzes: [
                const QuizQuestion(
                  id: 'sdq1',
                  question: 'Which systems typically choose AP over CP?',
                  options: [
                    'Banking systems',
                    'Social media feeds',
                    'SQL databases',
                    'File systems',
                  ],
                  correctAnswerIndex: 1,
                  explanation:
                      'Social media prefers availability over strict '
                      'consistency.',
                  points: 10,
                ),
              ],
              exercises: [],
            ),
          ],
        ),
      ],
    );
  }

  // ── SAP Path ─────────────────────────────────────────────────────

  static LearningPath _sapPath() {
    return LearningPath(
      id: 'sap',
      title: 'SAP Consulting',
      description:
          'Learn SAP fundamentals, FICO, MM, SD modules, and '
          'enterprise consulting skills.',
      iconName: 'business',
      color: 0xFF003366,
      careerTags: ['Enterprise', 'SAP', 'Consulting'],
      difficulty: 3,
      estimatedHours: 50,
      modules: [
        AcademyModule(
          id: 'sap-intro',
          title: 'SAP Fundamentals',
          description: 'SAP architecture, navigation, and core concepts.',
          order: 0,
          iconName: 'flag',
          lessons: [
            AcademyLesson(
              id: 'sap-intro-01',
              title: 'Introduction to SAP',
              description:
                  'Understand ERP systems and SAP\'s role in enterprise '
                  'software.',
              durationMinutes: 20,
              contentVersion: 1,
              sections: [
                const LessonContentSection(
                  id: 'sap1',
                  type: LessonContentType.text,
                  data:
                      '# Introduction to SAP\n\nSAP is the world\'s leading '
                      'ERP system. It integrates all business processes into '
                      'a single platform.\n\n'
                      '## Key Modules\n\n'
                      '- **FI**: Financial Accounting\n'
                      '- **CO**: Controlling\n'
                      '- **MM**: Materials Management\n'
                      '- **SD**: Sales & Distribution\n'
                      '- **HR**: Human Resources',
                ),
              ],
              quizzes: [
                const QuizQuestion(
                  id: 'sapq1',
                  question: 'What does ERP stand for?',
                  options: [
                    'Enterprise Resource Planning',
                    'Electronic Resource Protocol',
                    'Enterprise Routing Protocol',
                    'Extended Resource Planning',
                  ],
                  correctAnswerIndex: 0,
                  explanation:
                      'ERP = Enterprise Resource Planning.',
                  points: 10,
                ),
              ],
              exercises: [],
            ),
          ],
        ),
      ],
    );
  }
}
