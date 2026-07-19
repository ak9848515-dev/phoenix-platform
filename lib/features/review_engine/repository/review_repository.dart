import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/review_snapshot.dart';

/// Repository interface for Review Engine persistence.
abstract class ReviewRepositoryInterface {
  Future<ReviewSnapshot?> loadLatest();
  Future<void> save(ReviewSnapshot snapshot);
  Future<void> clear();
}

/// Local implementation using SharedPreferences.
class LocalReviewRepository implements ReviewRepositoryInterface {
  static const String _key = 'review_latest';

  @override
  Future<ReviewSnapshot?> loadLatest() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return ReviewSnapshot(
        reviewType: ReviewType.values.firstWhere(
          (e) => e.name == (map['reviewType'] as String? ?? 'daily'),
        ),
        title: map['title'] as String? ?? '',
        overallScore: (map['overallScore'] as num?)?.toDouble() ?? 0.0,
        items: (map['items'] as List<dynamic>?)
                ?.map((e) => ReviewItem.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
        date: map['date'] as String? ?? '',
        periodLabel: map['periodLabel'] as String? ?? '',
        overallSummary: map['overallSummary'] as String? ?? '',
        topRecommendation: map['topRecommendation'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(ReviewSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode({
      'reviewType': snapshot.reviewType.name,
      'title': snapshot.title,
      'overallScore': snapshot.overallScore,
      'items': snapshot.items.map((i) => i.toMap()).toList(),
      'date': snapshot.date,
      'periodLabel': snapshot.periodLabel,
      'overallSummary': snapshot.overallSummary,
      'topRecommendation': snapshot.topRecommendation,
    }));
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
