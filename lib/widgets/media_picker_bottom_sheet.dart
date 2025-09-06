import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/theme.dart';

class MediaPickerBottomSheet extends StatelessWidget {
  final Function(List<File>) onMediaSelected;

  const MediaPickerBottomSheet({
    super.key,
    required this.onMediaSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Select Media',
              style: AppTextStyles.headline5,
            ),
          ),
          
          // Media Options Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMediaOption(
                        context,
                        icon: Icons.photo_camera,
                        label: 'Camera',
                        color: AppColors.primary,
                        onTap: () => _pickFromCamera(context, ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMediaOption(
                        context,
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        color: AppColors.secondary,
                        onTap: () => _pickFromGallery(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMediaOption(
                        context,
                        icon: Icons.videocam,
                        label: 'Video',
                        color: AppColors.accent,
                        onTap: () => _pickVideo(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMediaOption(
                        context,
                        icon: Icons.insert_drive_file,
                        label: 'File',
                        color: AppColors.textSecondary,
                        onTap: () => _pickFile(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMediaOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromCamera(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        Navigator.of(context).pop();
        onMediaSelected([File(image.path)]);
      }
    } catch (e) {
      _showError(context, 'Failed to capture image: $e');
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        Navigator.of(context).pop();
        onMediaSelected(images.map((image) => File(image.path)).toList());
      }
    } catch (e) {
      _showError(context, 'Failed to pick images: $e');
    }
  }

  Future<void> _pickVideo(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
      
      if (video != null) {
        Navigator.of(context).pop();
        onMediaSelected([File(video.path)]);
      }
    } catch (e) {
      _showError(context, 'Failed to pick video: $e');
    }
  }

  Future<void> _pickFile(BuildContext context) async {
    // TODO: Implement file picker
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File picker coming soon!')),
    );
  }

  void _showError(BuildContext context, String message) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}