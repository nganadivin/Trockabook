import 'package:flutter/material.dart';
import 'package:trocabook_front/core/widgets/buttons/primary_button.dart';
import 'package:trocabook_front/core/widgets/inputs/custom_text_field.dart';
import 'package:trocabook_front/core/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:trocabook_front/core/services/auth_service.dart';
import 'package:trocabook_front/core/errors/exceptions.dart';
import 'package:trocabook_front/core/widgets/app_snackbar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isLoading = false;

  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final auth = context.read<AuthService>();
      final user = auth.currentUser ?? await _userService.getCurrentUser();
      if (!mounted) return;
      _nameController.text =
          '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
      _emailController.text = user['email'] ?? '';
      _phoneController.text = user['telephone'] ?? user['phone'] ?? '';
      _cityController.text = user['ville'] ?? user['location'] ?? '';
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        'Impossible de charger votre profil: $e',
        error: true,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final names = _nameController.text.split(' ');
      final first = names.isNotEmpty ? names.first : null;
      final last = names.length > 1 ? names.sublist(1).join(' ') : null;
      await _userService.updateProfile(
        firstName: first,
        lastName: last,
        email: _emailController.text,
        phone: _phoneController.text,
        ville: _cityController.text,
      );
      if (!mounted) return;
      AppSnackbar.show(context, 'Profile updated successfully', error: false);
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      AppSnackbar.show(context, 'Update failed: ${e.message}', error: true);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.show(context, 'Unexpected error: $e', error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // Handle image picker
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(controller: _nameController, label: 'Full Name'),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CustomTextField(controller: _cityController, label: 'City'),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Save Changes',
              onPressed: _saveProfile,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
