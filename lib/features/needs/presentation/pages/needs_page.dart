import 'package:flutter/material.dart';

class NeedsPage extends StatefulWidget {
  const NeedsPage({super.key});

  @override
  State<NeedsPage> createState() => _NeedsPageState();
}

class _NeedsPageState extends State<NeedsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Fiction';
  final List<String> _categories = [
    'Fiction',
    'Non-Fiction',
    'Children',
    'Educational',
    'Science',
    'History',
    'Biography',
    'Other',
  ];

  final List<Map<String, dynamic>> _needs = [
    {
      'title': 'Harry Potter and the Philosopher\'s Stone',
      'author': 'J.K. Rowling',
      'category': 'Fiction',
      'description': 'Looking for a good condition copy for my child.',
      'postedBy': 'Jane Smith',
      'postedDate': '2 days ago',
    },
    {
      'title': 'Introduction to Algorithms',
      'author': 'Cormen et al.',
      'category': 'Educational',
      'description': 'Need this for my computer science studies.',
      'postedBy': 'John Doe',
      'postedDate': '1 week ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Needs')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _needs.length,
              itemBuilder: (context, index) {
                final need = _needs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(need['title']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Author: ${need['author']}'),
                        Text('Category: ${need['category']}'),
                        Text(need['description']),
                        const SizedBox(height: 4),
                        Text(
                          'Posted by ${need['postedBy']} • ${need['postedDate']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Offer book
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Book offered!')),
                        );
                      },
                      child: const Text('Offer'),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _showAddNeedDialog,
              child: const Text('Post a Need'),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddNeedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Post a Book Need'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Book Title'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a title' : null,
                ),
                TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(labelText: 'Author'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter an author' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter a description'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(onPressed: _submitNeed, child: const Text('Post')),
        ],
      ),
    );
  }

  void _submitNeed() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _needs.insert(0, {
          'title': _titleController.text,
          'author': _authorController.text,
          'category': _selectedCategory,
          'description': _descriptionController.text,
          'postedBy': 'You',
          'postedDate': 'Just now',
        });
      });

      _titleController.clear();
      _authorController.clear();
      _descriptionController.clear();

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book need posted successfully!')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
