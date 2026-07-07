import 'dart:convert';

/// Immutable representation of progress tracking for a user.
class Progress {
  const Progress({
    required this.id,
    required this.label,
    required this.value,
  });

  final String id;
  final String label;
  final double value;

  Progress copyWith({String? id, String? label, double? value}) {
    return Progress(
      id: id ?? this.id,
      label: label ?? this.label,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'value': value,
    };
  }

  factory Progress.fromMap(Map<String, dynamic> map) {
    return Progress(
      id: map['id'] as String,
      label: map['label'] as String,
      value: (map['value'] as num).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Progress.fromJson(String source) => Progress.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Progress && other.id == id && other.label == label && other.value == value;
  }

  @override
  int get hashCode => Object.hash(id, label, value);

  @override
  String toString() {
    return 'Progress(id: $id, label: $label, value: $value)';
  }
}
