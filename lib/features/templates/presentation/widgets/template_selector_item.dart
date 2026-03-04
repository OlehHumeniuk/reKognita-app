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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        color: active ? AppColors.brand : Colors.transparent,
        child: Row(
          children: [
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.docType,
                    style: TextStyle(
                      color: active ? AppColors.white : AppColors.dark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${template.fields.length} полів',
                    style: TextStyle(
                      color: active
                          ? AppColors.white.withValues(alpha: 0.70)
                          : AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: active
                  ? AppColors.white.withValues(alpha: 0.80)
                  : AppColors.muted,
            ),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}
