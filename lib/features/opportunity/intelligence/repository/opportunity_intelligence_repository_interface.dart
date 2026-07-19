import '../../models/opportunity.dart';
import '../../models/opportunity_match.dart';
import '../models/opportunity_application.dart';
import '../models/opportunity_company_profile.dart';

/// Interface for persisting opportunity intelligence data.
///
/// Follows the same pattern as Career/Portfolio/Interview repository interfaces.
abstract class OpportunityIntelligenceRepositoryInterface {
  /// Saves a list of opportunities.
  Future<void> saveOpportunities(List<Opportunity> opportunities);

  /// Loads saved opportunities.
  Future<List<Opportunity>> loadOpportunities();

  /// Saves an application entry.
  Future<void> saveApplication(OpportunityApplication application);

  /// Loads all application entries.
  Future<List<OpportunityApplication>> loadApplications();

  /// Saves a match analysis.
  Future<void> saveMatch(OpportunityMatch match);

  /// Loads match analyses.
  Future<List<OpportunityMatch>> loadMatches();

  /// Saves a company profile.
  Future<void> saveCompany(OpportunityCompanyProfile company);

  /// Loads company profiles.
  Future<List<OpportunityCompanyProfile>> loadCompanies();

  /// Clears all opportunity data.
  Future<void> clearAll();
}
