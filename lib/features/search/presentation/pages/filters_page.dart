import 'package:flutter/material.dart';
import 'package:trocabook_front/core/widgets/buttons/primary_button.dart';

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key});

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  String _selectedGrade = 'All';
  String _selectedSubject = 'All';
  String _selectedCondition = 'All';
  double _maxDistance = 10.0;

  final List<String> _grades = [
    'All',
    '6e',
    '5e',
    '4e',
    '3e',
    '2nde',
    '1ère',
    'Terminale',
  ];
  final List<String> _subjects = [
    'All',
    'Mathématiques',
    'Français',
    'SVT',
    'Histoire-Géo',
    'Anglais',
    'Physique-Chimie',
  ];
  final List<String> _conditions = ['All', 'Neuf', 'Très bon', 'Bon', 'Moyen'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        actions: [
          TextButton(
            onPressed: () {
              // Reset filters
              setState(() {
                _selectedGrade = 'All';
                _selectedSubject = 'All';
                _selectedCondition = 'All';
                _maxDistance = 10.0;
              });
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grade',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _grades
                  .map(
                    (grade) => FilterChip(
                      label: Text(grade),
                      selected: _selectedGrade == grade,
                      onSelected: (selected) {
                        setState(() => _selectedGrade = grade);
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Subject',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _subjects
                  .map(
                    (subject) => FilterChip(
                      label: Text(subject),
                      selected: _selectedSubject == subject,
                      onSelected: (selected) {
                        setState(() => _selectedSubject = subject);
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Condition',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _conditions
                  .map(
                    (condition) => FilterChip(
                      label: Text(condition),
                      selected: _selectedCondition == condition,
                      onSelected: (selected) {
                        setState(() => _selectedCondition = condition);
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Maximum Distance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _maxDistance,
              min: 1,
              max: 50,
              divisions: 49,
              label: '${_maxDistance.round()} km',
              onChanged: (value) {
                setState(() => _maxDistance = value);
              },
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Apply Filters',
              onPressed: () {
                Navigator.of(context).pop({
                  'grade': _selectedGrade,
                  'subject': _selectedSubject,
                  'condition': _selectedCondition,
                  'distance': _maxDistance.toString(),
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
