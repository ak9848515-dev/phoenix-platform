import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../engine/notification_engine.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../shared/widgets/phoenix_empty_state.dart';
import '../../../shared/widgets/phoenix_error_state.dart';
import '../../../shared/widgets/phoenix_loading_widget.dart';
import '../models/notification_filter.dart';
import '../models/notification_item.dart';

/// Notification Center Screen — the central hub for all Phoenix notifications.
///
/// **Purpose:** Replace the previous placeholder SnackBar with a full
/// notification center that allows users to view, filter, dismiss, and
/// act on notifications derived from engine snapshots.
///
/// **Architecture:**
/// ```text
/// NotificationEngine → NotificationItem list → NotificationCenterScreen
/// ```
///
/// **States:** Loading → [Empty | Error | Notifications]
class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  NotificationEngine? get _engine =>
      AppBootstrap.maybeNotificationEngine;

  NotificationFilter _activeFilter = NotificationFilter.all;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      await _engine?.refresh();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  List<NotificationItem> get _filteredNotifications {
    final all = _engine?.notifications ?? [];
    if (_activeFilter == NotificationFilter.all) return all;
    if (_activeFilter == NotificationFilter.unread) {
      return all.where((n) => !n.isRead).toList();
    }
    return all
        .where((n) => n.category.name == _activeFilter.key)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const PhoenixLoadingWidget(
        icon: Icons.notifications_outlined,
        title: 'Loading notifications...',
        subtitle: 'Checking your latest updates',
      );
    }

    if (_hasError) {
      return PhoenixErrorState(
        category: PhoenixErrorCategory.data,
        onAction: _loadNotifications,
        actionLabel: 'Retry',
      );
    }

    final filtered = _filteredNotifications;

    if (filtered.isEmpty) {
      return Column(
        children: [
          _buildFilterBar(),
          const Expanded(
            child: PhoenixEmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'All caught up!',
              message:
                  'You have no notifications in this category right now.',
              positiveMessage:
                  'Complete missions to generate notifications.',
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildFilterBar(),
        Expanded(child: _buildNotificationList(filtered)),
      ],
    );
  }

  // ── Filter Bar ────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    final theme = Theme.of(context);
    final filters = NotificationFilter.values;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PhoenixSpacing.lg,
        vertical: PhoenixSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Notifications',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600)),
              const Spacer(),
              if (_engine != null && _engine!.unreadCount > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: PhoenixColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_engine!.unreadCount} unread',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: PhoenixColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: PhoenixSpacing.sm),
              ],
              TextButton(
                onPressed: _engine != null && _engine!.hasUnread
                    ? () {
                        _engine!.markAllRead();
                        setState(() {});
                      }
                    : null,
                child: const Text('Mark all read'),
              ),
            ],
          ),
          const SizedBox(height: PhoenixSpacing.md),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: PhoenixSpacing.sm),
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isActive = _activeFilter == filter;
                return FilterChip(
                  label: Text(filter.displayName),
                  selected: isActive,
                  onSelected: (selected) {
                    setState(() {
                      _activeFilter = selected ? filter : NotificationFilter.all;
                    });
                  },
                  selectedColor:
                      PhoenixColors.primary.withValues(alpha: 0.15),
                  checkmarkColor: PhoenixColors.primary,
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    color: isActive
                        ? PhoenixColors.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Notification List ─────────────────────────────────────────────

  Widget _buildNotificationList(List<NotificationItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: PhoenixSpacing.lg),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final notification = items[index];
        return _buildNotificationTile(context, notification);
      },
    );
  }

  Widget _buildNotificationTile(
      BuildContext context, NotificationItem notification) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        _engine?.dismiss(notification.id);
        setState(() {});
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: PhoenixSpacing.lg),
        color: PhoenixColors.error.withValues(alpha: 0.1),
        child: const Icon(Icons.delete_outline, color: PhoenixColors.error),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: PhoenixSpacing.sm),
        decoration: BoxDecoration(
          color: isUnread
              ? PhoenixColors.primary.withValues(alpha: 0.03)
              : theme.colorScheme.surface,
          borderRadius: PhoenixRadius.lgRadius,
          border: isUnread
              ? Border.all(
                  color: PhoenixColors.primary.withValues(alpha: 0.1))
              : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: PhoenixSpacing.md, vertical: 4),
          leading: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: notification.category.icon == Icons.rocket_launch_outlined
                      ? PhoenixColors.info.withValues(alpha: 0.1)
                      : notification.category.icon == Icons.work_outlined
                          ? PhoenixColors.warning.withValues(alpha: 0.1)
                          : notification.category.icon == Icons.emoji_events_outlined
                              ? PhoenixColors.success.withValues(alpha: 0.1)
                              : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  notification.category.icon,
                  color: notification.category.icon == Icons.rocket_launch_outlined
                      ? PhoenixColors.info
                      : notification.category.icon == Icons.work_outlined
                          ? PhoenixColors.warning
                          : notification.category.icon == Icons.emoji_events_outlined
                              ? PhoenixColors.success
                              : theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              if (isUnread)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: PhoenixColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            notification.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                notification.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    notification.timeAgo,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: PhoenixSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: notification.priority.color
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      notification.priority.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: notification.priority.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: isUnread
              ? Icon(Icons.circle, size: 8, color: PhoenixColors.primary)
              : Icon(Icons.check_circle_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.5)),
          onTap: () {
            // Mark as read
            if (!notification.isRead) {
              _engine?.markRead(notification.id);
              setState(() {});
            }

            // Navigate
            if (notification.action != null) {
              Navigator.of(context).pushNamed(
                notification.action!.route,
                arguments: notification.action!.arguments,
              );
            }
          },
        ),
      ),
    );
  }
}
