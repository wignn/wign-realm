import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../config/api_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      return _buildGuestView(context);
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient background
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppTheme.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2D1B69), AppTheme.background],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => _showSettingsSheet(context, authProvider),
              ),
            ],
          ),

          // Profile Content - no transform, avatar starts right below app bar
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Avatar
                _buildAvatar(authProvider),
                const SizedBox(height: 16),

                // Name & Email
                Text(
                  authProvider.user?.username ?? 'User',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authProvider.user?.email ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
                ),

                const SizedBox(height: 24),

                // Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('0', 'Novels Read'),
                      _buildStatDivider(),
                      _buildStatItem('0', 'Chapters'),
                      _buildStatDivider(),
                      _buildStatItem('0', 'Bookmarks'),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Bio Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildBioSection(authProvider),
                ),

                const SizedBox(height: 24),

                // Menu Items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        subtitle: 'Update your username and bio',
                        onTap: () =>
                            _showEditProfileSheet(context, authProvider),
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your security credentials',
                        onTap: () => _showChangePasswordSheet(context),
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.bookmark_outline,
                        title: 'My Bookmarks',
                        subtitle: 'View your saved novels',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.history,
                        title: 'Reading History',
                        subtitle: 'Track your reading progress',
                        onTap: () {},
                      ),
                      const SizedBox(height: 24),
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        subtitle: 'Sign out of your account',
                        isDestructive: true,
                        onTap: () => _showLogoutConfirm(context, authProvider),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: AppTheme.primaryShadow,
                ),
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to Wign Realm',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to track your reading progress,\nsave your favorite novels, and more.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text('Create Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(AuthProvider authProvider) {
    final profilePic = authProvider.user?.profilePic;
    final initial =
        authProvider.user?.username.substring(0, 1).toUpperCase() ?? 'U';

    return Stack(
      children: [
        GestureDetector(
          onTap: () => _showAvatarOptions(context, authProvider),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
              boxShadow: AppTheme.primaryShadow,
            ),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surface,
                border: Border.all(color: AppTheme.background, width: 4),
              ),
              child: profilePic != null && profilePic.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: profilePic,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (_, __, ___) =>
                            _buildInitialAvatar(initial),
                      ),
                    )
                  : _buildInitialAvatar(initial),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _showAvatarOptions(context, authProvider),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.background, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialAvatar(String initial) {
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 40, color: AppTheme.border);
  }

  Widget _buildBioSection(AuthProvider authProvider) {
    final bio = authProvider.user?.bio;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppTheme.textMuted),
              const SizedBox(width: 8),
              Text('About', style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            bio != null && bio.isNotEmpty
                ? bio
                : 'No bio yet. Tap Edit Profile to add one.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: bio != null && bio.isNotEmpty
                  ? AppTheme.textPrimary
                  : AppTheme.textMuted,
              fontStyle: bio != null && bio.isNotEmpty
                  ? FontStyle.normal
                  : FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isDestructive
                ? AppTheme.error.withOpacity(0.3)
                : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppTheme.error.withOpacity(0.1)
                    : AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDestructive ? AppTheme.error : AppTheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? AppTheme.error
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              trailing: Switch(value: true, onChanged: (_) {}),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              trailing: Switch(value: true, onChanged: (_) {}),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, AuthProvider authProvider) {
    final usernameController = TextEditingController(
      text: authProvider.user?.username ?? '',
    );
    final bioController = TextEditingController(
      text: authProvider.user?.bio ?? '',
    );
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setModalState(() => isLoading = true);
                          try {
                            await ApiService().put(
                              ApiConfig.baseUrl + '/api/auth/profile',
                              data: {
                                'username': usernameController.text.isNotEmpty
                                    ? usernameController.text
                                    : null,
                                'bio': bioController.text.isNotEmpty
                                    ? bioController.text
                                    : null,
                              },
                            );
                            await authProvider.initialize();
                            if (context.mounted) Navigator.pop(context);
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile updated!'),
                                ),
                              );
                            }
                          } catch (e) {
                            setModalState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    bool isLoading = false;
    String? error;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Change Password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              if (error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error!,
                    style: const TextStyle(color: AppTheme.error),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (newController.text != confirmController.text) {
                            setModalState(
                              () => error = 'Passwords do not match',
                            );
                            return;
                          }
                          if (newController.text.length < 6) {
                            setModalState(
                              () => error =
                                  'Password must be at least 6 characters',
                            );
                            return;
                          }
                          setModalState(() {
                            isLoading = true;
                            error = null;
                          });
                          try {
                            await ApiService().put(
                              ApiConfig.baseUrl + '/api/auth/password',
                              data: {
                                'current_password': currentController.text,
                                'new_password': newController.text,
                              },
                            );
                            if (context.mounted) Navigator.pop(context);
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password changed!'),
                                ),
                              );
                            }
                          } catch (e) {
                            setModalState(() {
                              isLoading = false;
                              error = 'Invalid current password';
                            });
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Change Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showAvatarOptions(BuildContext context, AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change Profile Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt, color: AppTheme.primary),
              ),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.camera, authProvider);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library, color: AppTheme.primary),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.gallery, authProvider);
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(
    ImageSource source,
    AuthProvider authProvider,
  ) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Uploading photo...')));
      }

      // Read file bytes
      final bytes = await pickedFile.readAsBytes();
      final fileName = pickedFile.name;
      final mimeType = pickedFile.mimeType ?? 'image/jpeg';

      // Create multipart form data
      final formData = FormData.fromMap({
        'avatar': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: DioMediaType.parse(mimeType),
        ),
      });

      // Upload using ApiService (which has the auth token)
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          headers: {'x-api-key': ApiConfig.apiKey},
        ),
      );

      // Get token from storage service
      final storage = StorageService();
      final token = await storage.getAccessToken();
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      await dio.post('/api/auth/avatar', data: formData);

      // Refresh user data
      await authProvider.initialize();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Photo updated!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload: $e')));
      }
    }
  }
}
