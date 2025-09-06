import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/theme.dart';

class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  final bool showBorder;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.imageUrl,
    this.size = 48,
    this.showBorder = false,
    this.borderColor = AppColors.primary,
    this.borderWidth = 2,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: showBorder
              ? Border.all(
                  color: borderColor,
                  width: borderWidth,
                )
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: imageUrl.isEmpty
              ? Container(
                  color: AppColors.surfaceVariant,
                  child: Icon(
                    Icons.person,
                    size: size * 0.6,
                    color: AppColors.textSecondary,
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surfaceVariant,
                    child: Icon(
                      Icons.person,
                      size: size * 0.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.surfaceVariant,
                    child: Icon(
                      Icons.person,
                      size: size * 0.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}