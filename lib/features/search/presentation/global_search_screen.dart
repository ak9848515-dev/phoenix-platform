import 'package:flutter/material.dart';

import '../../../services/global_search_service.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';

/// Global Search Screen — aggregates results from all 11 engines.
///
/// Results are grouped by source engine with expandable sections.
/// Each result navigates to its source screen.
class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final GlobalSearchService _searchService = GlobalSearchService();
  final TextEditingController _searchController = TextEditingController();
  List<SearchResultGroup> _results = [];
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _results = _searchService.search(query);
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search missions, habits, knowledge...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _results = [];
                            _hasSearched = false;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              onChanged: _onSearch,
              textInputAction: TextInputAction.search,
            ),
          ),

          // Results
          Expanded(
            child: _buildResults(context),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final t = Theme.of(context);
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64,
              color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Search across all Phoenix modules',
              style: t.textTheme.bodyLarge?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Missions · Academy · Portfolio · Resume · Interview\n'
              'Opportunities · Timeline · Habits · Memory · Knowledge · Decisions',
              textAlign: TextAlign.center,
              style: t.textTheme.bodySmall?.copyWith(
                color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No results found',
              style: t.textTheme.bodyLarge?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final totalResults = _results.fold<int>(0, (sum, g) => sum + g.count);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            '$totalResults results found',
            style: t.textTheme.bodySmall?.copyWith(
            color: t.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ..._results.map((group) => _buildResultGroup(context, group)),
      ],
    );
  }

  Widget _buildResultGroup(BuildContext context, SearchResultGroup group) {
    final theme = Theme.of(context);
    final iconData = _iconForGroup(group.icon);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                Icon(iconData, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  group.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${group.count}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results
          ...group.results.map((result) => _buildResultTile(context, result)),
        ],
      ),
    );
  }

  Widget _buildResultTile(BuildContext context, SearchResult result) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        leading: Icon(
          _iconForGroup(result.icon ?? 'search'),
          size: 20,
          color: AppColors.primary,
        ),
        title: Text(
          result.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: result.description != null && result.description!.isNotEmpty
            ? Text(
                result.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: result.subtitle != null
            ? Text(
                result.subtitle!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        onTap: () {
          Navigator.of(context).pushNamed(result.route);
        },
      ),
    );
  }

  IconData _iconForGroup(String icon) {
    switch (icon) {
      case 'rocket_launch':
        return Icons.rocket_launch_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'folder':
        return Icons.folder_rounded;
      case 'description':
        return Icons.description_rounded;
      case 'record_voice_over':
        return Icons.record_voice_over_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'timeline':
        return Icons.timeline_rounded;
      case 'checklist':
        return Icons.checklist_rounded;
      case 'hub':
        return Icons.hub_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'account_tree':
        return Icons.account_tree_rounded;
      default:
        return Icons.search_rounded;
    }
  }

  ThemeData get theme => Theme.of(context);
}