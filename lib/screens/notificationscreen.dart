import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final DateTime time;
  final IconData icon;
  bool read;

  NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    this.read = false,
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

enum NotiFilter { all, unread, updates, alerts }

class _NotificationsPageState extends State<NotificationsPage> {
  NotiFilter _filter = NotiFilter.all;

  final List<NotificationItem> _items = [
    NotificationItem(
      id: '1',
      title: 'Road damage reported',
      subtitle: 'Your report was submitted successfully.',
      time: DateTime.now().subtract(const Duration(minutes: 8)),
      icon: Icons.check_circle,
      read: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Verification needed',
      subtitle: 'Add a short description to finish the report.',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      icon: Icons.verified_user,
      read: false,
    ),
    NotificationItem(
      id: '3',
      title: 'New app update',
      subtitle: 'Version 1.2.0 brings performance improvements.',
      time: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      icon: Icons.system_update_alt,
      read: true,
    ),
  ];

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {});
  }

  List<NotificationItem> get _filtered {
    return _items.where((n) {
      switch (_filter) {
        case NotiFilter.unread:
          return !n.read;
        case NotiFilter.updates:
          return n.icon == Icons.system_update_alt;
        case NotiFilter.alerts:
          return n.icon == Icons.warning_amber_rounded;
        case NotiFilter.all:
        default:
          return true;
      }
    }).toList();
  }

  void _toggleRead(NotificationItem n) {
    setState(() => n.read = !n.read);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = _filtered.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            onPressed: () => setState(() {
              for (final n in _items) {
                n.read = true;
              }
            }),
            icon: const Icon(Icons.done_all),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Wrap(
              spacing: 8,
              children: [
                _filterChip('All', NotiFilter.all),
                _filterChip('Unread', NotiFilter.unread),
                _filterChip('Updates', NotiFilter.updates),
                _filterChip('Alerts', NotiFilter.alerts),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: isEmpty
                  ? ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 96),
                          child: _EmptyState(
                            title: 'You’re all caught up!',
                            subtitle: 'New notifications will appear here.',
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final n = _filtered[index];
                        return Dismissible(
                          key: ValueKey(n.id),
                          direction: DismissDirection.endToStart,
                          background: _DismissBg(
                            icon: Icons.delete_outline,
                            label: 'Delete',
                            color: theme.colorScheme.errorContainer,
                            fg: theme.colorScheme.onErrorContainer,
                          ),
                          onDismissed: (_) {
                            setState(
                              () => _items.removeWhere((e) => e.id == n.id),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notification deleted'),
                              ),
                            );
                          },
                          child: _NotificationCard(
                            item: n,
                            onTap: () => _toggleRead(n),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, NotiFilter value) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      pressElevation: 0,
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const _NotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBadge(icon: item.icon, unread: !item.read),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: item.read
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _timeAgo(item.time),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: onSurface.withOpacity(0.8),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        TextButton(
                          onPressed: onTap,
                          child: Text(
                            item.read ? 'Mark as unread' : 'Mark as read',
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'More',
                          onPressed: () {},
                          icon: const Icon(Icons.more_horiz),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    if (d.inDays < 7) return '${d.inDays}d';
    final weeks = (d.inDays / 7).floor();
    return '${weeks}w';
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final bool unread;
  const _IconBadge({required this.icon, required this.unread});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.primaryContainer;
    final fg = theme.colorScheme.onPrimaryContainer;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: fg),
        ),
        if (unread)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _DismissBg extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color fg;
  const _DismissBg({
    required this.icon,
    required this.label,
    required this.color,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(label, style: TextStyle(color: fg)),
          const SizedBox(width: 8),
          Icon(icon, color: fg),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          Icons.notifications_none,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
