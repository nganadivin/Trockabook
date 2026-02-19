import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trocabook_front/core/widgets/buttons/primary_button.dart';
import 'package:trocabook_front/core/widgets/buttons/custom_icon_box.dart';
import 'package:trocabook_front/core/services/auth_service.dart';
import 'package:trocabook_front/core/services/user_service.dart';
import 'package:trocabook_front/core/config/app_colors.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  late Future<Map<String, dynamic>> _userProfileFuture;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _userProfileFuture = _userService.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/edit-profile'),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading profile: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _userProfileFuture = _userService.getCurrentUser();
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = snapshot.data ?? {};
          final firstName = user['firstName'] ?? user['prenom'] ?? 'User';
          final lastName = user['lastName'] ?? user['nom'] ?? '';
          final ville = user['ville'] ?? user['localisation'] ?? 'Unknown City';
          final profileImage =
              user['profileImage'] ??
              user['photo'] ??
              'https://via.placeholder.com/150x150?text=Profile';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _TopPortion(profileImage: profileImage),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        '$firstName $lastName',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ville,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconBox(
                            icon: Icons.person_add_alt_1,
                            backgroundColor: Colors.green.withOpacity(0.3),
                            onTap: () => context.go('/my-books'),
                            borderRadius: 15,
                          ),
                          const SizedBox(width: 16.0),
                          CustomIconBox(
                            icon: Icons.message_rounded,
                            backgroundColor: Colors.green.withOpacity(0.3),
                            onTap: () => context.go("/chats"),
                            borderRadius: 15,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _ProfileInfoRow(user: user),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'My Books',
                        onPressed: () => context.go('/my-books'),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        text: 'Exchange History',
                        onPressed: () => context.go('/exchanges-history'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final authService = context.read<AuthService>();
                          await authService.logout();
                          if (mounted) {
                            context.go('/login');
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopPortion extends StatelessWidget {
  final String profileImage;

  const _TopPortion({required this.profileImage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 50),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xff0043ba), Color(0xff006df1)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
          ),
          // Centered profile picture
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(profileImage),
                            onError: (exception, stackTrace) {},
                          ),
                        ),
                        child: profileImage.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: Container(
                            margin: const EdgeInsets.all(3.0),
                            decoration: const BoxDecoration(
                              color: Color(0xff2196F3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final Map<String, dynamic> user;

  const _ProfileInfoRow({required this.user});

  @override
  Widget build(BuildContext context) {
    final booksCount = user['booksCount'] ?? 0;
    final rating = user['rating'] ?? 0.0;
    final exchangesCount = user['exchangesCount'] ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoItem('Books', booksCount.toString(), context),
        _buildInfoItem('Rating', '$rating⭐', context),
        _buildInfoItem('Exchanges', exchangesCount.toString(), context),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
