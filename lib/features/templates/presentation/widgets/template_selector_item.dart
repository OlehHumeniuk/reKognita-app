import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/templates/domain/entities/parsing_template.dart';

class TemplateSelectorItem extends StatelessWidget {
  const TemplateSelectorItem({
    required this.template,
    required this.active,
    required this.onTap,
    super.key,
  });

  final ParsingTemplate template;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.brand : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppColors.brand : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              template.docType,
              style: TextStyle(
                color: active ? Colors.white : AppColors.dark,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${template.fields.length} полів',
              style: TextStyle(
                color: active
                    ? Colors.white.withValues(alpha: 0.75)
                    : AppColors.muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
