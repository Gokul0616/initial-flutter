import 'package:flutter/material.dart';
import '../models/story_model.dart';
import '../utils/theme.dart';

class DraggableStoryElement extends StatefulWidget {
  final StorySticker? sticker;
  final StoryTextElement? textElement;
  final Function(double x, double y) onPositionChanged;
  final Function(double rotation) onRotationChanged;
  final Function(double scale) onScaleChanged;
  final bool isEditMode;

  const DraggableStoryElement({
    super.key,
    this.sticker,
    this.textElement,
    required this.onPositionChanged,
    required this.onRotationChanged,
    required this.onScaleChanged,
    this.isEditMode = false,
  });

  @override
  State<DraggableStoryElement> createState() => _DraggableStoryElementState();
}

class _DraggableStoryElementState extends State<DraggableStoryElement> {
  late double _x;
  late double _y;
  late double _rotation;
  late double _scale;
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    if (widget.sticker != null) {
      _x = widget.sticker!.x;
      _y = widget.sticker!.y;
      _rotation = widget.sticker!.rotation;
      _scale = 1.0;
    } else if (widget.textElement != null) {
      _x = widget.textElement!.x;
      _y = widget.textElement!.y;
      _rotation = widget.textElement!.rotation;
      _scale = 1.0;
    } else {
      _x = 0;
      _y = 0;
      _rotation = 0;
      _scale = 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _x,
      top: _y,
      child: GestureDetector(
        onTap: () {
          if (widget.isEditMode) {
            setState(() {
              _isSelected = !_isSelected;
            });
          }
        },
        onPanUpdate: (details) {
          if (widget.isEditMode && _canDrag()) {
            setState(() {
              _x += details.delta.dx;
              _y += details.delta.dy;
            });
            widget.onPositionChanged(_x, _y);
          }
        },
        onScaleUpdate: (details) {
          if (widget.isEditMode && _canDrag()) {
            setState(() {
              _scale = details.scale;
              _rotation += details.rotation;
            });
            widget.onScaleChanged(_scale);
            widget.onRotationChanged(_rotation);
          }
        },
        child: Transform.rotate(
          angle: _rotation,
          child: Transform.scale(
            scale: _scale,
            child: Container(
              decoration: _isSelected && widget.isEditMode
                  ? BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: _buildElement(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElement() {
    if (widget.sticker != null) {
      return _buildSticker();
    } else if (widget.textElement != null) {
      return _buildTextElement();
    }
    return Container();
  }

  Widget _buildSticker() {
    final sticker = widget.sticker!;
    
    return Container(
      width: sticker.width,
      height: sticker.height,
      child: sticker.url != null && sticker.url!.isNotEmpty
          ? Image.network(
              sticker.url!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _buildStickerFallback(sticker.type);
              },
            )
          : _buildStickerFallback(sticker.type),
    );
  }

  Widget _buildStickerFallback(String type) {
    IconData iconData;
    Color color = Colors.white;

    switch (type.toLowerCase()) {
      case 'heart':
        iconData = Icons.favorite;
        color = AppColors.primary;
        break;
      case 'star':
        iconData = Icons.star;
        color = Colors.yellow;
        break;
      case 'fire':
        iconData = Icons.local_fire_department;
        color = Colors.orange;
        break;
      case 'thumbs_up':
        iconData = Icons.thumb_up;
        color = AppColors.secondary;
        break;
      case 'clap':
        iconData = Icons.emoji_emotions;
        color = Colors.yellow;
        break;
      default:
        iconData = Icons.emoji_emotions;
        color = Colors.white;
    }

    return Icon(
      iconData,
      size: widget.sticker!.width.clamp(24.0, 64.0),
      color: color,
    );
  }

  Widget _buildTextElement() {
    final textElement = widget.textElement!;
    
    Color textColor;
    try {
      textColor = Color(int.parse(textElement.color.replaceFirst('#', '0xff')));
    } catch (e) {
      textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        textElement.text,
        style: TextStyle(
          fontSize: textElement.fontSize,
          color: textColor,
          fontFamily: textElement.fontFamily,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(
              offset: const Offset(1, 1),
              blurRadius: 2,
              color: Colors.black.withOpacity(0.5),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  bool _canDrag() {
    if (widget.sticker != null) {
      return widget.sticker!.isDraggable;
    } else if (widget.textElement != null) {
      return widget.textElement!.isDraggable;
    }
    return false;
  }
}