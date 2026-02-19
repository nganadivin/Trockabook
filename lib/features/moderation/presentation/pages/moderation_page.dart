import 'package:flutter/material.dart';

class ModerationPage extends StatefulWidget {
  const ModerationPage({super.key});

  @override
  State<ModerationPage> createState() => _ModerationPageState();
}

class _ModerationPageState extends State<ModerationPage> {
  final List<Map<String, dynamic>> _reports = [
    {
      'id': '1',
      'type': 'User Report',
      'description': 'Inappropriate behavior in chat',
      'reportedUser': 'John Doe',
      'status': 'Pending',
    },
    {
      'id': '2',
      'type': 'Book Report',
      'description': 'Book description contains offensive content',
      'reportedBook': 'Offensive Book Title',
      'status': 'Under Review',
    },
    {
      'id': '3',
      'type': 'Exchange Report',
      'description': 'Exchange not completed as agreed',
      'reportedExchange': 'Exchange #123',
      'status': 'Resolved',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moderation Panel')),
      body: ListView.builder(
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('${report['type']} - ${report['id']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(report['description']),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${report['status']}',
                    style: TextStyle(
                      color: _getStatusColor(report['status']),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) => _handleAction(value, report),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'review', child: Text('Review')),
                  const PopupMenuItem(value: 'resolve', child: Text('Resolve')),
                  const PopupMenuItem(value: 'dismiss', child: Text('Dismiss')),
                ],
              ),
              onTap: () => _showReportDetails(context, report),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Under Review':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _handleAction(String action, Map<String, dynamic> report) {
    setState(() {
      switch (action) {
        case 'review':
          report['status'] = 'Under Review';
          break;
        case 'resolve':
          report['status'] = 'Resolved';
          break;
        case 'dismiss':
          report['status'] = 'Dismissed';
          break;
      }
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Report ${action}d')));
  }

  void _showReportDetails(BuildContext context, Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${report['type']} Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${report['id']}'),
            Text('Description: ${report['description']}'),
            Text('Status: ${report['status']}'),
            if (report.containsKey('reportedUser'))
              Text('Reported User: ${report['reportedUser']}'),
            if (report.containsKey('reportedBook'))
              Text('Reported Book: ${report['reportedBook']}'),
            if (report.containsKey('reportedExchange'))
              Text('Reported Exchange: ${report['reportedExchange']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
