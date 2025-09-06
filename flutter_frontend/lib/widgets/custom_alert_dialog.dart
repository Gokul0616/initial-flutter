import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget> actions;
  final Widget? icon;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon (if provided)
            if (icon != null) ...[
              icon!,
              const SizedBox(height: 16),
            ],

            // Title
            Text(
              title,
              style: AppTextStyles.headline4,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Content
            Text(
              content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: actions.length == 1
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceEvenly,
              children: actions.map((action) {
                return Flexible(child: action);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}