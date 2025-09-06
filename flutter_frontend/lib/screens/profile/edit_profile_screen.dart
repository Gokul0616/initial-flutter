import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/custom_alert_dialog.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    _displayNameController = TextEditingController(text: user.displayName);
    _bioController = TextEditingController(text: user.bio);
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showError('Failed to take photo: $e');
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Select Photo',
        content: 'Choose how you want to select your profile picture',
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _pickImage();
            },
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _takePhoto();
            },
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final result = await userProvider.updateProfile(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
        profilePicturePath: _selectedImage?.path,
      );

      if (result['success']) {
        // Update auth provider with new user data
        await authProvider.updateUserProfile(result['user']);
        
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        _showError(result['error']);
      }
    } catch (e) {
      _showError('Failed to update profile: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Error',
        content: message,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile', style: AppTextStyles.headline5),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              )
                            : UserAvatar(
                                imageUrl: user.profileImageUrl,
                                size: 116,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surface,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Username (read-only)
              CustomTextField(
                controller: TextEditingController(text: user.username),
                hintText: 'Username',
                labelText: 'Username',
                prefixIcon: Icons.alternate_email,
                readOnly: true,
                enabled: false,
              ),

              const SizedBox(height: 16),

              // Display Name
              CustomTextField(
                controller: _displayNameController,
                hintText: 'Enter your display name',
                labelText: 'Display Name',
                prefixIcon: Icons.person_outline,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return AppStringsErrors.displayNameRequired;
                  }
                  if (value!.length > AppConstants.maxDisplayNameLength) {
                    return AppStringsErrors.displayNameTooLong;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Bio
              CustomTextField(
                controller: _bioController,
                hintText: 'Tell us about yourself...',
                labelText: 'Bio',
                prefixIcon: Icons.info_outline,
                maxLines: 4,
                maxLength: AppConstants.maxBioLength,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value != null && value.length > AppConstants.maxBioLength) {
                    return AppStringsErrors.bioTooLong;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Privacy Settings Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Privacy Settings',
                      style: AppTextStyles.headline5,
                    ),
                    const SizedBox(height: 16),
                    
                    // Private Account
                    _buildSettingTile(
                      title: 'Private Account',
                      subtitle: 'Only followers can see your videos',
                      value: user.isPrivate,
                      onChanged: (value) {
                        // TODO: Update privacy setting
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Privacy settings coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Account Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account',
                      style: AppTextStyles.headline5,
                    ),
                    const SizedBox(height: 16),
                    
                    // Change Password
                    ListTile(
                      leading: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Change password feature coming soon!')),
                        );
                      },
                    ),
                    
                    const Divider(),
                    
                    // Delete Account
                    ListTile(
                      leading: const Icon(Icons.delete_outline, color: AppColors.error),
                      title: const Text(
                        'Delete Account',
                        style: TextStyle(color: AppColors.error),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _showDeleteAccountDialog();
                      },
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

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Delete Account',
        content: 'Are you sure you want to delete your account? This action cannot be undone.',
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion feature coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}