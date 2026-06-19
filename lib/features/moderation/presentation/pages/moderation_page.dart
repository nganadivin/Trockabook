import 'package:flutter/material.dart';
import 'package:trocabook_front/core/services/additional_services.dart';

class ModerationPage extends StatefulWidget {
  const ModerationPage({super.key});

  @override
  State<ModerationPage> createState() => _ModerationPageState();
}

class _ModerationPageState extends State<ModerationPage> {
  final SignalmentService _signalmentService = SignalmentService();
  late Future<List<Map<String, dynamic>>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _signalmentService.getSignalements();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() => _reportsFuture = _signalmentService.getSignalements());
  }

  String _status(Map<String, dynamic> report) =>
      (report['status'] ?? report['statut'] ?? 'Pending').toString();

  String _type(Map<String, dynamic> report) =>
      (report['type'] ?? report['reason'] ?? 'Signalement').toString();

  String _description(Map<String, dynamic> report) =>
      (report['description'] ?? '').toString();

  String? _id(Map<String, dynamic> report) =>
      report['id']?.toString() ?? report['_id']?.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moderation Panel')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reportsFuture,
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

          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
            return const Center(child: Text('Aucun signalement'));
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  title: Text('${_type(report)} - ${_id(report) ?? index}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_description(report)),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${_status(report)}',
                        style: TextStyle(
                          color: _getStatusColor(_status(report)),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) => _handleAction(value, report),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'review',
                        child: Text('Review'),
                      ),
                      const PopupMenuItem(
                        value: 'resolve',
                        child: Text('Resolve'),
                      ),
                      const PopupMenuItem(
                        value: 'dismiss',
                        child: Text('Dismiss'),
                      ),
                    ],
                  ),
                  onTap: () => _showReportDetails(context, report),
                ),
              );
            },
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

  Future<void> _handleAction(
    String action,
    Map<String, dynamic> report,
  ) async {
    final id = _id(report);
    if (id == null) return;
    try {
      await _signalmentService.moderateSignalement(
        signalementId: id,
        action: action,
      );
      _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Report ${action}d')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  void _showReportDetails(BuildContext context, Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_type(report)} Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${_id(report) ?? 'N/A'}'),
            Text('Description: ${_description(report)}'),
            Text('Status: ${_status(report)}'),
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
