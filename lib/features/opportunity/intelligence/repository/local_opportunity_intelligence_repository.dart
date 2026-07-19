import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/opportunity.dart';
import '../../models/opportunity_gap.dart';
import '../../models/opportunity_match.dart';
import '../../models/opportunity_requirement.dart';
import '../models/opportunity_application.dart';
import '../models/opportunity_application_status.dart';
import '../models/opportunity_company_profile.dart';
import 'opportunity_intelligence_repository_interface.dart';

/// Local implementation of [OpportunityIntelligenceRepositoryInterface]
/// using SharedPreferences for offline-first persistence.
class LocalOpportunityIntelligenceRepository
    implements OpportunityIntelligenceRepositoryInterface {
  LocalOpportunityIntelligenceRepository({this._prefs});

  SharedPreferencesWithCache? _prefs;

  static const String _oppKey = 'phx_opportunity_opportunities';
  static const String _appKey = 'phx_opportunity_applications';
  static const String _matchKey = 'phx_opportunity_matches';
  static const String _companyKey = 'phx_opportunity_companies';

  Future<SharedPreferencesWithCache> get _storage async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    return _prefs!;
  }

  @override
  Future<void> saveOpportunities(List<Opportunity> opportunities) async {
    final prefs = await _storage;
    final json = jsonEncode(opportunities.map((o) => _oppToMap(o)).toList());
    await prefs.setString(_oppKey, json);
  }

  @override
  Future<List<Opportunity>> loadOpportunities() async {
    final prefs = await _storage;
    final raw = prefs.getString(_oppKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => _oppFromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveApplication(OpportunityApplication application) async {
    final prefs = await _storage;
    final apps = await loadApplications();
    final idx = apps.indexWhere((a) => a.id == application.id);
    if (idx >= 0) {
      apps[idx] = application;
    } else {
      apps.add(application);
    }
    final json = jsonEncode(apps.map((a) => _appToMap(a)).toList());
    await prefs.setString(_appKey, json);
  }

  @override
  Future<List<OpportunityApplication>> loadApplications() async {
    final prefs = await _storage;
    final raw = prefs.getString(_appKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => _appFromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveMatch(OpportunityMatch match) async {
    final prefs = await _storage;
    final matches = await loadMatches();
    final idx = matches.indexWhere((m) => m.opportunityId == match.opportunityId);
    if (idx >= 0) {
      matches[idx] = match;
    } else {
      matches.add(match);
    }
    final json = jsonEncode(matches.map((m) => _matchToMap(m)).toList());
    await prefs.setString(_matchKey, json);
  }

  @override
  Future<List<OpportunityMatch>> loadMatches() async {
    final prefs = await _storage;
    final raw = prefs.getString(_matchKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => _matchFromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveCompany(OpportunityCompanyProfile company) async {
    final prefs = await _storage;
    final companies = await loadCompanies();
    final idx = companies.indexWhere((c) => c.id == company.id);
    if (idx >= 0) {
      companies[idx] = company;
    } else {
      companies.add(company);
    }
    final json = jsonEncode(companies.map((c) => _companyToMap(c)).toList());
    await prefs.setString(_companyKey, json);
  }

  @override
  Future<List<OpportunityCompanyProfile>> loadCompanies() async {
    final prefs = await _storage;
    final raw = prefs.getString(_companyKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => _companyFromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> clearAll() async {
    final prefs = await _storage;
    await prefs.remove(_oppKey);
    await prefs.remove(_appKey);
    await prefs.remove(_matchKey);
    await prefs.remove(_companyKey);
  }

  // ── Serialization ──────────────────────────────────────────────

  Map<String, dynamic> _oppToMap(Opportunity o) => o.toMap();
  Opportunity _oppFromMap(Map<String, dynamic> m) =>
      Opportunity.fromMap(m);

  Map<String, dynamic> _appToMap(OpportunityApplication a) => {
        'id': a.id,
        'opportunityId': a.opportunityId,
        'opportunityTitle': a.opportunityTitle,
        'companyName': a.companyName,
        'status': a.status.name,
        'appliedAt': a.appliedAt?.toIso8601String(),
        'interviewAt': a.interviewAt?.toIso8601String(),
        'offerAt': a.offerAt?.toIso8601String(),
        'rejectedAt': a.rejectedAt?.toIso8601String(),
        'acceptedAt': a.acceptedAt?.toIso8601String(),
        'notes': a.notes,
        'isRemote': a.isRemote,
        'location': a.location,
        'salaryRange': a.salaryRange,
      };

  OpportunityApplication _appFromMap(Map<String, dynamic> m) =>
      OpportunityApplication(
        id: m['id'] as String,
        opportunityId: m['opportunityId'] as String,
        opportunityTitle: m['opportunityTitle'] as String? ?? '',
        companyName: m['companyName'] as String? ?? '',
        status: m['status'] != null
            ? ApplicationStatus.values.firstWhere(
                (e) => e.name == m['status'],
                orElse: () => ApplicationStatus.wishlist)
            : ApplicationStatus.wishlist,
        appliedAt: m['appliedAt'] != null
            ? DateTime.tryParse(m['appliedAt'] as String)
            : null,
        interviewAt: m['interviewAt'] != null
            ? DateTime.tryParse(m['interviewAt'] as String)
            : null,
        offerAt: m['offerAt'] != null
            ? DateTime.tryParse(m['offerAt'] as String)
            : null,
        rejectedAt: m['rejectedAt'] != null
            ? DateTime.tryParse(m['rejectedAt'] as String)
            : null,
        acceptedAt: m['acceptedAt'] != null
            ? DateTime.tryParse(m['acceptedAt'] as String)
            : null,
        notes: m['notes'] as String? ?? '',
        isRemote: m['isRemote'] as bool? ?? false,
        location: m['location'] as String? ?? '',
        salaryRange: m['salaryRange'] as String? ?? '',
      );

  Map<String, dynamic> _matchToMap(OpportunityMatch m) => {
        'opportunityId': m.opportunityId,
        'matchScore': m.matchScore,
        'requirements': m.requirements
            .map((r) => {
                  'skill': r.skill,
                  'isRequired': r.isRequired,
                  'isMatched': r.isMatched,
                })
            .toList(),
        'gaps': m.gaps
            .map((g) => {
                  'skill': g.skill,
                  'severity': g.severity,
                  'action': g.action,
                })
            .toList(),
      };

  OpportunityMatch _matchFromMap(Map<String, dynamic> m) =>
      OpportunityMatch(
        opportunityId: m['opportunityId'] as String,
        matchScore: (m['matchScore'] as num?)?.toDouble() ?? 0.0,
        requirements: m['requirements'] != null
            ? (m['requirements'] as List)
                .map((e) => OpportunityRequirement(
                      skill: e['skill'] as String,
                      isRequired: e['isRequired'] as bool? ?? true,
                      isMatched: e['isMatched'] as bool? ?? false,
                    ))
                .toList()
            : [],
        gaps: m['gaps'] != null
            ? (m['gaps'] as List)
                .map((e) => OpportunityGap(
                      skill: e['skill'] as String,
                      severity: (e['severity'] as num?)?.toDouble() ?? 0.5,
                      action: e['action'] as String? ?? '',
                    ))
                .toList()
            : [],
      );

  Map<String, dynamic> _companyToMap(OpportunityCompanyProfile c) => {
        'id': c.id,
        'name': c.name,
        'industry': c.industry,
        'overview': c.overview,
        'requiredSkills': c.requiredSkills,
        'preferredSkills': c.preferredSkills,
        'interviewDifficulty': c.interviewDifficulty,
        'culture': c.culture,
        'growthPotential': c.growthPotential,
        'technologyStack': c.technologyStack,
        'careerFitScore': c.careerFitScore,
        'location': c.location,
        'size': c.size,
        'fundingStage': c.fundingStage,
      };

  OpportunityCompanyProfile _companyFromMap(Map<String, dynamic> m) =>
      OpportunityCompanyProfile(
        id: m['id'] as String,
        name: m['name'] as String,
        industry: m['industry'] as String? ?? '',
        overview: m['overview'] as String? ?? '',
        requiredSkills: m['requiredSkills'] != null
            ? List<String>.from(m['requiredSkills'] as List)
            : [],
        preferredSkills: m['preferredSkills'] != null
            ? List<String>.from(m['preferredSkills'] as List)
            : [],
        interviewDifficulty:
            (m['interviewDifficulty'] as num?)?.toDouble() ?? 0.5,
        culture: m['culture'] as String? ?? '',
        growthPotential: (m['growthPotential'] as num?)?.toDouble() ?? 0.5,
        technologyStack: m['technologyStack'] != null
            ? List<String>.from(m['technologyStack'] as List)
            : [],
        careerFitScore: (m['careerFitScore'] as num?)?.toDouble() ?? 0.0,
        location: m['location'] as String? ?? '',
        size: m['size'] as String? ?? '',
        fundingStage: m['fundingStage'] as String? ?? '',
      );
}
