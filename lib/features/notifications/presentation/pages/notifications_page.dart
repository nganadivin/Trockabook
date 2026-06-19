import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trocabook_front/core/services/additional_services.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _notificationService.getNotifications();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _notificationsFuture = _notificationService.getNotifications();
    });
  }

  bool _isRead(Map<String, dynamic> n) =>
      n['isRead'] == true || n['lu'] == true || n['read'] == true;

  String _title(Map<String, dynamic> n) =>
      (n['title'] ?? n['titre'] ?? 'Notification').toString();

  String _message(Map<String, dynamic> n) =>
      (n['message'] ?? n['contenu'] ?? n['body'] ?? '').toString();

  String _time(Map<String, dynamic> n) =>
      (n['time'] ?? n['createdAt'] ?? n['date'] ?? '').toString();

  String? _id(Map<String, dynamic> n) =>
      n['id']?.toString() ?? n['_id']?.toString();

  Future<void> _markAsRead(Map<String, dynamic> notification) async {
    final id = _id(notification);
    if (id == null || _isRead(notification)) return;
    try {
      await _notificationService.markAsRead(id);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de marquer comme lu: $e')),
      );
    }
  }

  Future<void> _markAllAsRead(List<Map<String, dynamic>> notifications) async {
    final unread = notifications.where((n) => !_isRead(n)).toList();
    if (unread.isEmpty) return;
    try {
      for (final n in unread) {
        final id = _id(n);
        if (id != null) await _notificationService.markAsRead(id);
      }
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _notificationsFuture,
            builder: (context, snapshot) {
              final notifications = snapshot.data ?? [];
              return TextButton(
                onPressed: notifications.isEmpty
                    ? null
                    : () => _markAllAsRead(notifications),
                child: const Text('Mark all read'),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erreur: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const Center(child: Text('Aucune notification'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final isRead = _isRead(notification);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isRead
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Theme.of(context).colorScheme.primary,
                  child: Icon(
                    isRead ? Icons.notifications : Icons.notifications_active,
                    color: isRead
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                title: Text(_title(notification)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_message(notification)),
                    const SizedBox(height: 4),
                    Text(
                      _time(notification),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                trailing: isRead
                    ? null
                    : Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                onTap: () => _markAsRead(notification),
              );
            },
          );
        },
      ),
    );
  }
}
