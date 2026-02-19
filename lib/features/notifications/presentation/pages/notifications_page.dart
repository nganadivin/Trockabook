import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notifications data
    final notifications = [
      {
        'title': 'New exchange proposal',
        'message':
            'John Doe proposed an exchange for your book "Harry Potter".',
        'time': '2 hours ago',
        'isRead': false,
      },
      {
        'title': 'Exchange accepted',
        'message': 'Your exchange with Jane Smith has been accepted.',
        'time': '1 day ago',
        'isRead': true,
      },
      {
        'title': 'Book rating received',
        'message': 'You received a 5-star rating from Michael Johnson.',
        'time': '3 days ago',
        'isRead': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read
            },
            child: const Text('Mark all read'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show options
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: notification['isRead'] as bool
                  ? Colors.grey
                  : Theme.of(context).primaryColor,
              child: Icon(
                notification['isRead'] as bool
                    ? Icons.notifications
                    : Icons.notifications_active,
                color: Colors.white,
              ),
            ),
            title: Text(notification['title'] as String),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification['message'] as String),
                const SizedBox(height: 4),
                Text(
                  notification['time'] as String,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: notification['isRead'] as bool
                ? null
                : Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
            onTap: () {
              // Navigate to relevant page
            },
          );
        },
      ),
    );
  }
}
