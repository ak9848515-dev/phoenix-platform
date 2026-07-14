/// A section of content within a lesson.
///
/// Immutable. Lessons are composed of multiple content sections
/// that can be text, code, or image blocks.
class LessonContentSection {
  const LessonContentSection({
    required this.id,
    required this.type,
    required this.data,
    this.language,
    this.caption,
  });

  /// Unique identifier within the lesson.
  final String id;

  /// The type of content section.
  final LessonContentType type;

  /// The content data (markdown text, code, or image URL).
  final String data;

  /// Programming language (for code sections, e.g. 'dart', 'java').
  final String? language;

  /// Optional caption (for image sections).
  final String? caption;

  LessonContentSection copyWith({
    String? id,
    LessonContentType? type,
    String? data,
    String? language,
    String? caption,
  }) {
    return LessonContentSection(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      language: language ?? this.language,
      caption: caption ?? this.caption,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'data': data,
      'language': language,
      'caption': caption,
    };
  }

  factory LessonContentSection.fromMap(Map<String, dynamic> map) {
    return LessonContentSection(
      id: map['id'] as String,
      type: LessonContentType.values.firstWhere(
        (t) => t.name == (map['type'] as String),
        orElse: () => LessonContentType.text,
      ),
      data: map['data'] as String,
      language: map['language'] as String?,
      caption: map['caption'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonContentSection && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// The type of content in a lesson section.
enum LessonContentType {
  /// Markdown-formatted text.
  text,

  /// Code block with syntax highlighting.
  code,

  /// Image with optional caption.
  image,
}
