import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/document_types/domain/entities/document_type.dart';
import 'package:rekognita_app/shared/widgets/rk_badge.dart';

class DocumentTypeCard extends StatelessWidget {
  const DocumentTypeCard({
    required this.documentType,
    required this.active,
    required this.onTap,
    super.key,
  });

  final DocumentType documentType;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? documentType.color : AppColors.border,
            width: active ? 2 : 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: documentType.color.withValues(alpha: 0.2),
                    blurRadius: 26,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: documentType.color.withValues(alpha: 0.15),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    documentType.icon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const Spacer(),
                RkBadge(
                  text: documentType.integration,
                  color: documentType.color,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              documentType.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _Metric(
                  value: '${documentType.fields}',
                  label: 'полів',
                  color: documentType.color,
                ),
                const SizedBox(width: 16),
                _Metric(value: '${documentType.workers}', label: 'працівників'),
              ],
            ),
            if (active) ...[
              const Spacer(),
              const Divider(color: AppColors.border),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: documentType.color,
                      ),
                      child: const Text('Редагувати'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Шаблон'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    this.color = AppColors.dark,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }
}
