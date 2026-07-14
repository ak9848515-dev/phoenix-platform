import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../theme/spacing.dart';
import '../models/entity_type.dart';
import '../models/memory_entity.dart';
import '../services/memory_graph_service.dart';
import '../widgets/entity_card.dart';
import 'entity_detail_screen.dart';

/// Full-text search across all memory graph entities.
class MemorySearchScreen extends StatefulWidget {
  const MemorySearchScreen({super.key});

  @override
  State<MemorySearchScreen> createState() => _MemorySearchScreenState();
}

class _MemorySearchScreenState extends State<MemorySearchScreen> {
  MemoryGraphService? _service;
  final _searchController = TextEditingController();
  List<MemoryEntity> _results = [];
  EntityType? _typeFilter;
  bool _isSearching = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _service = AppBootstrap.maybeMemoryGraphService;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    final svc = _service;
    if (svc == null) return;
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _results = svc.search(query, typeFilter: _typeFilter);
    });
  }

  @override
  Widget build(BuildContext context) {
    final svc = _service;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Graph'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search entities...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _search('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _search,
              autofocus: true,
            ),
          ),
          // Type filter chips
          if (svc != null)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  _buildFilterChip(theme, 'All', null),
                  ...EntityType.values.map((type) =>
                      _buildFilterChip(theme, type.label, type)),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          // Results
          Expanded(
            child: _isSearching
                ? (_results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(height: AppSpacing.sm),
                            Text('No results found',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final entity = _results[index];
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: EntityCard(
                              entity: entity,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EntityDetailScreen(entity: entity),
                                ),
                              ),
                            ),
                          );
                        },
                      ))
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_rounded,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Search across all entities',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ThemeData theme, String label, EntityType? type) {
    final isSelected = _typeFilter == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (v) {
          setState(() => _typeFilter = type);
          _search(_searchController.text);
        },
      ),
    );
  }
}
