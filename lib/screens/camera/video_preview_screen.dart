import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/video_provider.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_alert_dialog.dart';
import '../../widgets/custom_text_field.dart';
import '../main/main_screen.dart';

class VideoPreviewScreen extends StatefulWidget {
  final String videoPath;

  const VideoPreviewScreen({
    super.key,
    required this.videoPath,
  });

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;
  bool _isPlaying = false;
  
  final TextEditingController _captionController = TextEditingController();
  final FocusNode _captionFocusNode = FocusNode();
  
  bool _allowComments = true;
  bool _allowDownload = true;
  List<String> _hashtags = [];

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _videoController = VideoPlayerController.file(File(widget.videoPath));
    
    try {
      await _videoController.initialize();
      _videoController.setLooping(true);
      _videoController.play();
      
      setState(() {
        _isInitialized = true;
        _isPlaying = true;
      });
    } catch (e) {
      _showError('Failed to load video: $e');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Error',
        content: message,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _videoController.pause();
        _isPlaying = false;
      } else {
        _videoController.play();
        _isPlaying = true;
      }
    });
  }

  void _extractHashtags(String text) {
    final hashtagRegex = RegExp(r'#\w+');
    final matches = hashtagRegex.allMatches(text);
    _hashtags = matches.map((match) => match.group(0)!.substring(1).toLowerCase()).toList();
  }

  Future<void> _uploadVideo() async {
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    
    _extractHashtags(_captionController.text);
    
    final result = await videoProvider.uploadVideo(
      videoPath: widget.videoPath,
      caption: _captionController.text.trim(),
      hashtags: _hashtags,
      allowComments: _allowComments,
      allowDownload: _allowDownload,
    );
    
    if (result['success']) {
      _showSuccessDialog();
    } else {
      _showError(result['error']);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomAlertDialog(
        title: 'Success!',
        content: 'Your video has been uploaded successfully!',
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainScreen()),
                (route) => false,
              );
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _captionController.dispose();
    _captionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Preview
          if (_isInitialized)
            Positioned.fill(
              child: Center(
                child: AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              ),
            )
          else
            Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),

          // Play/Pause Overlay
          if (_isInitialized && !_isPlaying)
            Positioned.fill(
              child: Center(
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),

          // Top Controls
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: _buildTopControls(),
          ),

          // Bottom Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          // Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Preview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Save Button
          GestureDetector(
            onTap: () {
              // Save to gallery functionality
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.download,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Caption Input
                 Text(
                  'Add a caption',
                  style: AppTextStyles.headline5,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _captionController,
                  focusNode: _captionFocusNode,
                  hintText: 'Write a caption...',
                  maxLines: 3,
                  maxLength: AppConstants.maxCaptionLength,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),

                const SizedBox(height: 24),

                // Privacy Settings
                 Text(
                  'Privacy Settings',
                  style: AppTextStyles.headline5,
                ),
                const SizedBox(height: 12),

                // Allow Comments
                _buildSettingTile(
                  title: 'Allow comments',
                  subtitle: 'Let people comment on your video',
                  value: _allowComments,
                  onChanged: (value) {
                    setState(() {
                      _allowComments = value;
                    });
                  },
                ),

                // Allow Download
                _buildSettingTile(
                  title: 'Allow download',
                  subtitle: 'Let people download your video',
                  value: _allowDownload,
                  onChanged: (value) {
                    setState(() {
                      _allowDownload = value;
                    });
                  },
                ),

                const SizedBox(height: 32),

                // Upload Button
                Consumer<VideoProvider>(
                  builder: (context, videoProvider, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: videoProvider.uploading ? null : _uploadVideo,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: videoProvider.uploading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                      value: videoProvider.uploadProgress,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Uploading... ${(videoProvider.uploadProgress * 100).toInt()}%',
                                    style: AppTextStyles.buttonMedium,
                                  ),
                                ],
                              )
                            :  Text(
                                'Post',
                                style: AppTextStyles.buttonLarge,
                              ),
                      ),
                    );
                  },
                ),

                // Bottom padding for safe area
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}