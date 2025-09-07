import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/story_provider.dart';
import '../../utils/theme.dart';
import '../../models/story_model.dart';

class StoryCreatorScreen extends StatefulWidget {
  const StoryCreatorScreen({super.key});

  @override
  State<StoryCreatorScreen> createState() => _StoryCreatorScreenState();
}

class _StoryCreatorScreenState extends State<StoryCreatorScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  String _selectedType = 'text'; // 'text', 'photo', 'video'
  Color _textColor = Colors.white;
  Color _backgroundColor = Colors.black;
  File? _selectedMedia;
  String _privacy = 'public';
  
  final List<Color> _backgroundColors = [
    Colors.black,
    const Color(0xFF1a1a2e),
    const Color(0xFF16213e),
    const Color(0xFF0f3460),
    const Color(0xFF533483),
    const Color(0xFF7209b7),
    const Color(0xFF2d1b69),
    const Color(0xFF11698e),
    const Color(0xFF19a7ce),
    const Color(0xFF13005a),
    const Color(0xFF00337c),
    const Color(0xFF1c82ad),
    const Color(0xFF03c6c7),
  ];
  
  final List<Color> _textColors = [
    Colors.white,
    Colors.black,
    const Color(0xFFff6b6b),
    const Color(0xFF4ecdc4),
    const Color(0xFF45b7d1),
    const Color(0xFF96ceb4),
    const Color(0xFFffeaa7),
    const Color(0xFFdda0dd),
    const Color(0xFFffa8b6),
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedType == 'text' ? _backgroundColor : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        title: const Text('Create Story', style: TextStyle(color: Colors.white)),
        actions: [
          Consumer<StoryProvider>(
            builder: (context, storyProvider, child) {
              return TextButton(
                onPressed: storyProvider.creatingStory ? null : _createStory,
                child: storyProvider.creatingStory
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    :  Text(
                        'Share',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Story Preview
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _selectedType == 'text' ? _backgroundColor : AppColors.surface,
              ),
              child: _buildStoryPreview(),
            ),
          ),
          
          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Story Type Selector
                Row(
                  children: [
                    _buildTypeButton('Text', 'text', Icons.text_fields),
                    const SizedBox(width: 12),
                    _buildTypeButton('Photo', 'photo', Icons.photo_camera),
                    const SizedBox(width: 12),
                    _buildTypeButton('Video', 'video', Icons.videocam),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Text Input (for text stories)
                if (_selectedType == 'text') ...[
                  TextField(
                    controller: _textController,
                    maxLines: 3,
                    maxLength: 500,
                    style: TextStyle(color: _textColor, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts...',
                      hintStyle: TextStyle(color: _textColor.withOpacity(0.6)),
                      filled: true,
                      fillColor: _backgroundColor.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Color Pickers
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text('Background', style: AppTextStyles.labelMedium),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 40,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _backgroundColors.length,
                                itemBuilder: (context, index) {
                                  final color = _backgroundColors[index];
                                  return GestureDetector(
                                    onTap: () => setState(() => _backgroundColor = color),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _backgroundColor == color
                                              ? AppColors.primary
                                              : AppColors.border,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text('Text Color', style: AppTextStyles.labelMedium),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 40,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _textColors.length,
                                itemBuilder: (context, index) {
                                  final color = _textColors[index];
                                  return GestureDetector(
                                    onTap: () => setState(() => _textColor = color),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _textColor == color
                                              ? AppColors.primary
                                              : AppColors.border,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Media Selection (for photo/video stories)
                if (_selectedType != 'text') ...[
                  if (_selectedMedia == null)
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: InkWell(
                        onTap: _pickMedia,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedType == 'photo' ? Icons.photo_library : Icons.video_library,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to select ${_selectedType}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(_selectedMedia!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedMedia = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
                
                const SizedBox(height: 16),
                
                // Privacy Selector
                Row(
                  children: [
                     Text('Who can see this:', style: AppTextStyles.labelMedium),
                    const Spacer(),
                    DropdownButton<String>(
                      value: _privacy,
                      dropdownColor: AppColors.surface,
                      items: const [
                        DropdownMenuItem(value: 'public', child: Text('Everyone')),
                        DropdownMenuItem(value: 'friends', child: Text('Friends')),
                        DropdownMenuItem(value: 'close_friends', child: Text('Close Friends')),
                      ],
                      onChanged: (value) => setState(() => _privacy = value ?? 'public'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryPreview() {
    if (_selectedType == 'text') {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            _textController.text.isEmpty ? 'Your text will appear here...' : _textController.text,
            style: TextStyle(
              color: _textColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (_selectedMedia != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _selectedMedia!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedType == 'photo' ? Icons.photo : Icons.videocam,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Select a ${_selectedType} to preview',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTypeButton(String label, String type, IconData icon) {
    final isSelected = _selectedType == type;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickMedia() async {
    try {
      final XFile? file = _selectedType == 'photo'
          ? await _imagePicker.pickImage(source: ImageSource.gallery)
          : await _imagePicker.pickVideo(source: ImageSource.gallery);
      
      if (file != null) {
        setState(() {
          _selectedMedia = File(file.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking media: $e')),
      );
    }
  }

  Future<void> _createStory() async {
    final storyProvider = context.read<StoryProvider>();
    
    if (_selectedType == 'text') {
      if (_textController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter some text')),
        );
        return;
      }
      
      final result = await storyProvider.createTextStory(
        text: _textController.text.trim(),
        textColor: '#${_textColor.value.toRadixString(16).substring(2)}',
        backgroundColor: '#${_backgroundColor.value.toRadixString(16).substring(2)}',
        privacy: _privacy,
      );
      
      if (result['success']) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'])),
        );
      }
    } else {
      if (_selectedMedia == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a media file')),
        );
        return;
      }
      
      final result = await storyProvider.createMediaStory(
        filePath: _selectedMedia!.path,
        privacy: _privacy,
      );
      
      if (result['success']) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'])),
        );
      }
    }
  }
}