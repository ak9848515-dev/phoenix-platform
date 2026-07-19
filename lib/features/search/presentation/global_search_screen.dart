import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../services/global_search_service.dart';

/// AI-Powered Global Search Screen.
///
/// Search uses the full AI pipeline:
/// AI Context → Prompt Builder → Provider Intelligence → Capability Router
/// → Response Gateway → Knowledge Update → Recommendation Update → Dashboard Update
class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen>
    with SingleTickerProviderStateMixin {
  final GlobalSearchService _searchService = GlobalSearchService();
  final TextEditingController _searchController = TextEditingController();
  List<SearchResultGroup> _results = [];
  bool _hasSearched = false;
  bool _isAiSearching = false;
  String? _aiAnswer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _onSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isAiSearching = true;
      _hasSearched = true;
      _aiAnswer = null;
    });
    // 1. Local engine search
    final localResults = _searchService.search(query);
    setState(() => _results = localResults);
    // 2. AI-powered search through full AI pipeline
    try {
      final phoenixAssistant = AppBootstrap.maybePhoenixAssistantService;
      if (phoenixAssistant != null) {
        final response = await phoenixAssistant.chat(
          userMessage: 'Search for: $query. '
              'Provide a comprehensive answer with connections to my goals, '
              'knowledge gaps, career impact, and recommended next steps.',
        );
        if (mounted && response.message.isNotEmpty) {
          setState(() => _aiAnswer = response.message);
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isAiSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(child: _buildResults(context)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PhoenixSpacing.md, PhoenixSpacing.xs, PhoenixSpacing.md, PhoenixSpacing.md,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Ask anything...',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                _isAiSearching ? Icons.auto_awesome_rounded : Icons.search_rounded,
                size: 24,
                color: _isAiSearching
                    ? PhoenixColors.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Clear search',
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _results = [];
                        _hasSearched = false;
                        _aiAnswer = null;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: PhoenixSpacing.lg, vertical: PhoenixSpacing.md,
            ),
          ),
          style: theme.textTheme.bodyLarge,
          onChanged: _onSearch,
          textInputAction: TextInputAction.search,
        ),
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: PhoenixColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.search_rounded,
                size: 40,
                color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: PhoenixSpacing.lg),
            Text(
              'Search across your entire growth journey',
              style: t.textTheme.bodyLarge?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: PhoenixSpacing.sm),
            Text(
              'AI-powered search with knowledge connections',
              style: t.textTheme.bodySmall?.copyWith(
                color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: PhoenixSpacing.md),
      children: [
        if (_isAiSearching)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: PhoenixSpacing.lg),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) => Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: PhoenixColors.primary.withValues(
                      alpha: 0.5 + _pulseController.value * 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: PhoenixSpacing.sm),
                Text(
                  'AI is analyzing your question...',
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: t.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        if (_aiAnswer != null && !_isAiSearching)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: PhoenixSpacing.md),
            padding: const EdgeInsets.all(PhoenixSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PhoenixColors.primary.withValues(alpha: 0.08),
                  PhoenixColors.info.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: PhoenixColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 16, color: PhoenixColors.primary),
                    const SizedBox(width: PhoenixSpacing.xs),
                    Text(
                      'AI Answer',
                      style: t.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: PhoenixColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PhoenixSpacing.sm),
                Text(_aiAnswer!, style: t.textTheme.bodyMedium?.copyWith(height: 1.5)),
              ],
            ),
          ),
        if (_results.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: PhoenixSpacing.sm),
            child: Text(
              '${_results.fold<int>(0, (sum, g) => sum + g.count)} results found',
              style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
            ),
          ),
        ..._results.map((group) => _buildResultGroup(context, group)),
        const SizedBox(height: PhoenixSpacing.xxl),
      ],
    );
  }

  Widget _buildResultGroup(BuildContext context, SearchResultGroup group) {
    final theme = Theme.of(context);
    final iconData = _iconForGroup(group.icon);
    return Padding(
      padding: const EdgeInsets.only(bottom: PhoenixSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: PhoenixSpacing.xs),
            child: Row(
              children: [
                Icon(iconData, size: 18, color: PhoenixColors.primary),
                const SizedBox(width: PhoenixSpacing.sm),
                Text(
                  group.label,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: PhoenixSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: PhoenixColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${group.count}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: PhoenixColors.primary, fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
        leading: Icon(_iconForGroup(result.icon ?? 'search'), size: 20, color: PhoenixColors.primary),
        title: Text(
          result.title,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: (result.description != null && result.description!.isNotEmpty)
            ? Text(
                result.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              )
            : null,
        trailing: result.subtitle != null
            ? Text(
                result.subtitle!,
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              )
            : null,
        onTap: () => Navigator.of(context).pushNamed(result.route),
      ),
    );
  }

  IconData _iconForGroup(String icon) {
    switch (icon) {
      case 'rocket_launch': return Icons.rocket_launch_rounded;
      case 'school': return Icons.school_rounded;
      case 'folder': return Icons.folder_rounded;
      case 'description': return Icons.description_rounded;
      case 'record_voice_over': return Icons.record_voice_over_rounded;
      case 'work': return Icons.work_rounded;
      case 'timeline': return Icons.timeline_rounded;
      case 'checklist': return Icons.checklist_rounded;
      case 'hub': return Icons.hub_rounded;
      case 'psychology': return Icons.psychology_rounded;
      case 'account_tree': return Icons.account_tree_rounded;
      default: return Icons.search_rounded;
    }
  }
}
