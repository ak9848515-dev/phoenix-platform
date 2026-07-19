import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_empty_state.dart';
import '../../../shared/widgets/phoenix_loading_widget.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/generation_metadata.dart';
import '../services/content_repository.dart';

/// Content Library — browse all AI-generated content organized by type.
///
/// Supports filtering by content type and deleting individual items.
class ContentLibraryScreen extends StatefulWidget {
  const ContentLibraryScreen({super.key});

  @override
  State<ContentLibraryScreen> createState() => _ContentLibraryScreenState();
}

class _ContentLibraryScreenState extends State<ContentLibraryScreen> {
  ContentRepository? _repository;
  List<ContentLibraryItem> _allItems = [];
  List<ContentLibraryItem> _filteredItems = [];
  String _activeFilter = 'all';
  bool _isLoading = true;

  static const _filters = [
    ('all', 'All'),
    (ContentType.course, 'Courses'),
    (ContentType.project, 'Projects'),
    (ContentType.portfolioEnhancement, 'Portfolio'),
    (ContentType.resumeEnhancement, 'Resume'),
    (ContentType.interviewQuestions, 'Interview'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final coordinator = AppBootstrap.maybeContentGeneratorCoordinator;
    _repository = coordinator?.repository;
    _loadContent();
  }

  Future<void> _loadContent() async {
    if (_repository == null) return;
    setState(() => _isLoading = true);
    try {
      final items = await _repository!.getAllContent();
      setState(() {
        _allItems = items;
        _applyFilter();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    if (_activeFilter == 'all') {
      _filteredItems = List.from(_allItems);
    } else {
      _filteredItems =
          _allItems.where((i) => i.type == _activeFilter).toList();
    }
  }

  Future<void> _deleteItem(ContentLibraryItem item) async {
    await _repository?.deleteContent(item.id, item.type);
    await _loadContent();
  }

  void _confirmDelete(BuildContext context, ContentLibraryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Content'),
        content: Text(
            'Are you sure you want to delete "${item.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteItem(item);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const PhoenixLoadingWidget(
        icon: Icons.folder_open_rounded,
        title: 'Content Library',
        subtitle: 'Loading your generated content...',
      );
    }

    return Column(
      children: [
        // Filter chips
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((f) {
                final isActive = _activeFilter == f.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(f.$2),
                    selected: isActive,
                    onSelected: (_) {
                      setState(() {
                        _activeFilter = f.$1;
                        _applyFilter();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Content list
        Expanded(
          child: _filteredItems.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadContent,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return _buildItemCard(context, item);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    if (_activeFilter == 'all') {
      return const PhoenixEmptyState(
        icon: Icons.folder_open_outlined,
        title: 'No generated content yet',
        message:
            'Head to the Content Generation Hub to create your first '
            'AI-powered course, project, resume enhancement, or interview prep.',
      );
    }
    final filterName =
        _filters.firstWhere((f) => f.$1 == _activeFilter).$2;
    return PhoenixEmptyState(
      icon: Icons.filter_list_off_rounded,
      title: 'No $filterName found',
      message:
          'Generate some $filterName content to see it here.',
    );
  }

  Widget _buildItemCard(BuildContext context, ContentLibraryItem item) {
    final theme = Theme.of(context);
    final color = _typeColor(item.type);
    final displayName = ContentType.displayName(item.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: PhoenixCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_typeIcon(item.type),
                      color: color, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          )),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDelete(context, item);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              size: 18, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                ),
              ],
            ),
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(item.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 14, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(_formatDate(item.generatedAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
                const Spacer(),
                if (item.provider.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(item.provider,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case ContentType.course:
        return AppColors.primary;
      case ContentType.project:
        return AppColors.secondary;
      case ContentType.portfolioEnhancement:
        return AppColors.info;
      case ContentType.resumeEnhancement:
        return AppColors.warning;
      case ContentType.interviewQuestions:
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case ContentType.course:
        return Icons.school_rounded;
      case ContentType.project:
        return Icons.code_rounded;
      case ContentType.portfolioEnhancement:
        return Icons.folder_special_rounded;
      case ContentType.resumeEnhancement:
        return Icons.description_rounded;
      case ContentType.interviewQuestions:
        return Icons.record_voice_over_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}
