import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../models/generated_content.dart';
import '../models/generation_metadata.dart';

/// Repository for persisting generated content.
///
/// Uses SharedPreferences for durable storage. Each content type is
/// stored under a separate key, loaded once and cached in memory.
///
/// **Architecture Rules:**
/// - Never stores plain AI response JSON — only validated domain models
/// - Never exposes SharedPreferences directly
/// - Always returns empty lists on error (never throws)
class ContentRepository {
  static const String _keyCourses = 'phx_gen_courses';
  static const String _keyProjects = 'phx_gen_projects';
  static const String _keyPortfolioEnhancements = 'phx_gen_portfolio_enh';
  static const String _keyResumeEnhancements = 'phx_gen_resume_enh';
  static const String _keyInterviewQuestions = 'phx_gen_interview_qs';

  final PhoenixLogger _logger = PhoenixLogger.shared;

  // ── In-memory caches ─────────────────────────────────────────────

  List<GeneratedCourse>? _cachedCourses;
  List<GeneratedProject>? _cachedProjects;
  List<GeneratedPortfolioEnhancement>? _cachedPortfolioEnhancements;
  List<GeneratedResumeEnhancement>? _cachedResumeEnhancements;
  List<GeneratedInterviewQuestions>? _cachedInterviewQuestions;

  // ── Courses ─────────────────────────────────────────────────────

  Future<List<GeneratedCourse>> getCourses() async {
    if (_cachedCourses != null) return _cachedCourses!;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCourses);
    if (raw == null || raw.isEmpty) {
      _cachedCourses = [];
      return [];
    }
    try {
      final list = json.decode(raw) as List<dynamic>;
      _cachedCourses = list
          .map((e) =>
              GeneratedCourse.fromJson(e as Map<String, dynamic>))
          .toList();
      return _cachedCourses!;
    } catch (e) {
      _logger.warning('Failed to load courses: $e',
          source: 'ContentRepository');
      return [];
    }
  }

  Future<void> saveCourse(GeneratedCourse course) async {
    final courses = await getCourses();
    final updated = [course, ...courses];
    _cachedCourses = updated;
    await _persistList(_keyCourses,
        updated.map((c) => c.toJson()).toList());
  }

  Future<void> deleteCourse(String id) async {
    final courses = await getCourses();
    _cachedCourses = courses.where((c) => c.id != id).toList();
    await _persistList(_keyCourses,
        _cachedCourses!.map((c) => c.toJson()).toList());
  }

  // ── Projects ───────────────────────────────────────────────────

  Future<List<GeneratedProject>> getProjects() async {
    if (_cachedProjects != null) return _cachedProjects!;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyProjects);
    if (raw == null || raw.isEmpty) {
      _cachedProjects = [];
      return [];
    }
    try {
      final list = json.decode(raw) as List<dynamic>;
      _cachedProjects = list
          .map((e) =>
              GeneratedProject.fromJson(e as Map<String, dynamic>))
          .toList();
      return _cachedProjects!;
    } catch (e) {
      _logger.warning('Failed to load projects: $e',
          source: 'ContentRepository');
      return [];
    }
  }

  Future<void> saveProject(GeneratedProject project) async {
    final projects = await getProjects();
    final updated = [project, ...projects];
    _cachedProjects = updated;
    await _persistList(_keyProjects,
        updated.map((p) => p.toJson()).toList());
  }

  Future<void> deleteProject(String id) async {
    final projects = await getProjects();
    _cachedProjects = projects.where((p) => p.id != id).toList();
    await _persistList(_keyProjects,
        _cachedProjects!.map((p) => p.toJson()).toList());
  }

  // ── Portfolio Enhancements ─────────────────────────────────────

  Future<List<GeneratedPortfolioEnhancement>>
      getPortfolioEnhancements() async {
    if (_cachedPortfolioEnhancements != null) {
      return _cachedPortfolioEnhancements!;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyPortfolioEnhancements);
    if (raw == null || raw.isEmpty) {
      _cachedPortfolioEnhancements = [];
      return [];
    }
    try {
      final list = json.decode(raw) as List<dynamic>;
      _cachedPortfolioEnhancements = list
          .map((e) => GeneratedPortfolioEnhancement.fromJson(
              e as Map<String, dynamic>))
          .toList();
      return _cachedPortfolioEnhancements!;
    } catch (e) {
      _logger.warning(
          'Failed to load portfolio enhancements: $e',
          source: 'ContentRepository');
      return [];
    }
  }

  Future<void> savePortfolioEnhancement(
      GeneratedPortfolioEnhancement enh) async {
    final items = await getPortfolioEnhancements();
    final updated = [enh, ...items];
    _cachedPortfolioEnhancements = updated;
    await _persistList(_keyPortfolioEnhancements,
        updated.map((e) => e.toJson()).toList());
  }

  Future<void> deletePortfolioEnhancement(String id) async {
    final items = await getPortfolioEnhancements();
    _cachedPortfolioEnhancements =
        items.where((e) => e.id != id).toList();
    await _persistList(_keyPortfolioEnhancements,
        _cachedPortfolioEnhancements!.map((e) => e.toJson()).toList());
  }

  // ── Resume Enhancements ───────────────────────────────────────

  Future<List<GeneratedResumeEnhancement>>
      getResumeEnhancements() async {
    if (_cachedResumeEnhancements != null) {
      return _cachedResumeEnhancements!;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyResumeEnhancements);
    if (raw == null || raw.isEmpty) {
      _cachedResumeEnhancements = [];
      return [];
    }
    try {
      final list = json.decode(raw) as List<dynamic>;
      _cachedResumeEnhancements = list
          .map((e) => GeneratedResumeEnhancement.fromJson(
              e as Map<String, dynamic>))
          .toList();
      return _cachedResumeEnhancements!;
    } catch (e) {
      _logger.warning(
          'Failed to load resume enhancements: $e',
          source: 'ContentRepository');
      return [];
    }
  }

  Future<void> saveResumeEnhancement(
      GeneratedResumeEnhancement enh) async {
    final items = await getResumeEnhancements();
    final updated = [enh, ...items];
    _cachedResumeEnhancements = updated;
    await _persistList(_keyResumeEnhancements,
        updated.map((e) => e.toJson()).toList());
  }

  Future<void> deleteResumeEnhancement(String id) async {
    final items = await getResumeEnhancements();
    _cachedResumeEnhancements =
        items.where((e) => e.id != id).toList();
    await _persistList(_keyResumeEnhancements,
        _cachedResumeEnhancements!.map((e) => e.toJson()).toList());
  }

  // ── Interview Questions ───────────────────────────────────────

  Future<List<GeneratedInterviewQuestions>>
      getInterviewQuestions() async {
    if (_cachedInterviewQuestions != null) {
      return _cachedInterviewQuestions!;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyInterviewQuestions);
    if (raw == null || raw.isEmpty) {
      _cachedInterviewQuestions = [];
      return [];
    }
    try {
      final list = json.decode(raw) as List<dynamic>;
      _cachedInterviewQuestions = list
          .map((e) => GeneratedInterviewQuestions.fromJson(
              e as Map<String, dynamic>))
          .toList();
      return _cachedInterviewQuestions!;
    } catch (e) {
      _logger.warning(
          'Failed to load interview questions: $e',
          source: 'ContentRepository');
      return [];
    }
  }

  Future<void> saveInterviewQuestions(
      GeneratedInterviewQuestions questions) async {
    final items = await getInterviewQuestions();
    final updated = [questions, ...items];
    _cachedInterviewQuestions = updated;
    await _persistList(_keyInterviewQuestions,
        updated.map((q) => q.toJson()).toList());
  }

  Future<void> deleteInterviewQuestions(String id) async {
    final items = await getInterviewQuestions();
    _cachedInterviewQuestions =
        items.where((q) => q.id != id).toList();
    await _persistList(_keyInterviewQuestions,
        _cachedInterviewQuestions!.map((q) => q.toJson()).toList());
  }

  // ── Generic Content Retrieval ─────────────────────────────────

  /// Returns all generated content items across all types.
  /// Useful for a unified content library view.
  Future<List<ContentLibraryItem>> getAllContent() async {
    final items = <ContentLibraryItem>[];
    final courses = await getCourses();
    for (final c in courses) {
      items.add(ContentLibraryItem(
        id: c.id,
        title: c.title,
        description: c.description,
        type: ContentType.course,
        generatedAt: c.metadata.generatedAt,
        provider: c.metadata.provider,
        metadata: c.metadata,
      ));
    }
    final projects = await getProjects();
    for (final p in projects) {
      items.add(ContentLibraryItem(
        id: p.id,
        title: p.title,
        description: p.description,
        type: ContentType.project,
        generatedAt: p.metadata.generatedAt,
        provider: p.metadata.provider,
        metadata: p.metadata,
      ));
    }
    final enhs = await getPortfolioEnhancements();
    for (final e in enhs) {
      items.add(ContentLibraryItem(
        id: e.id,
        title: e.summary.isNotEmpty
            ? 'Portfolio Enhancement'
            : 'Portfolio Suggestions',
        description: e.summary,
        type: ContentType.portfolioEnhancement,
        generatedAt: e.metadata.generatedAt,
        provider: e.metadata.provider,
        metadata: e.metadata,
      ));
    }
    final resumeEnhs = await getResumeEnhancements();
    for (final r in resumeEnhs) {
      items.add(ContentLibraryItem(
        id: r.id,
        title: 'Resume Enhancement',
        description: r.summary,
        type: ContentType.resumeEnhancement,
        generatedAt: r.metadata.generatedAt,
        provider: r.metadata.provider,
        metadata: r.metadata,
      ));
    }
    final interviews = await getInterviewQuestions();
    for (final i in interviews) {
      items.add(ContentLibraryItem(
        id: i.id,
        title: i.targetRole.isNotEmpty
            ? '${i.targetRole} Interview Prep'
            : 'Interview Questions',
        description:
            '${i.totalQuestions} questions, ~${i.estimatedMinutes} min',
        type: ContentType.interviewQuestions,
        generatedAt: i.metadata.generatedAt,
        provider: i.metadata.provider,
        metadata: i.metadata,
      ));
    }
    // Sort by generation time descending
    items.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    return items;
  }

  /// Deletes a content item by ID and type.
  Future<void> deleteContent(String id, String type) async {
    switch (type) {
      case ContentType.course:
        await deleteCourse(id);
      case ContentType.project:
        await deleteProject(id);
      case ContentType.portfolioEnhancement:
        await deletePortfolioEnhancement(id);
      case ContentType.resumeEnhancement:
        await deleteResumeEnhancement(id);
      case ContentType.interviewQuestions:
        await deleteInterviewQuestions(id);
    }
  }

  /// Count of all generated content items.
  Future<int> get totalCount async {
    final items = await getAllContent();
    return items.length;
  }

  // ── Helpers ──────────────────────────────────────────────────

  Future<void> _persistList(
      String key, List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(list));
  }
}

/// Lightweight item for displaying in content library lists.
class ContentLibraryItem {
  const ContentLibraryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.generatedAt,
    this.provider = '',
    required this.metadata,
  });

  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime generatedAt;
  final String provider;
  final GenerationMetadata metadata;
}
