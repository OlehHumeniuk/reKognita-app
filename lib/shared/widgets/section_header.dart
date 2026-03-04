import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.subtitle,
    this.buttonLabel,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? buttonLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (subtitle == null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.dark,
              ),
            ),
          ),
          if (buttonLabel != null)
            FilledButton(
              onPressed: onTap ?? () {},
              style: FilledButton.styleFrom(backgroundColor: AppColors.brand),
              child: Text(buttonLabel!),
            ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
        if (buttonLabel != null)
          FilledButton(
            onPressed: onTap ?? () {},
            style: FilledButton.styleFrom(backgroundColor: AppColors.brand),
            child: Text(buttonLabel!),
          ),
      ],
    );
  }
}
