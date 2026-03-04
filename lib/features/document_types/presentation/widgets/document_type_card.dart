import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/document_types/domain/entities/document_type.dart';

class DocumentTypeCard extends StatelessWidget {
  const DocumentTypeCard({
    required this.documentType,
    required this.active,
    required this.onTap,
    this.onEdit,
    this.onTemplate,
    super.key,
  });

  final DocumentType documentType;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onTemplate;

  @override
  Widget build(BuildContext context) {
    final color = documentType.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? color : AppColors.border,
            width: active ? 2 : 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + name (right side reserved for badge)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: color.withValues(alpha: 0.12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          documentType.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          documentType.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Gap so name doesn't overlap badge
                      const SizedBox(width: 48),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Metrics
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MetricChip(
                          icon: Icons.layers_rounded,
                          value: '${documentType.fields}',
                          label: 'полів',
                          color: color,
                        ),
                        const SizedBox(width: 12),
                        _MetricChip(
                          icon: Icons.people_alt_rounded,
                          value: '${documentType.workers}',
                          label: 'прац.',
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Divider + buttons
                  const Divider(height: 20, color: AppColors.border),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: 'Редагувати',
                          color: color,
                          filled: true,
                          onPressed: onEdit ?? () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ActionButton(
                          label: 'Шаблон',
                          color: color,
                          filled: false,
                          onPressed: onTemplate ?? () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Integration badge flush to top-right corner
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Text(
                  documentType.integration,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 25, color: color),
        const SizedBox(width: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );
    const textStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    const size = Size(0, 36);

    if (filled) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: size,
          padding: EdgeInsets.zero,
          textStyle: textStyle,
          shape: shape,
          elevation: 0,
        ),
        child: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        minimumSize: size,
        padding: EdgeInsets.zero,
        textStyle: textStyle,
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        shape: shape,
      ),
      child: Text(label),
    );
  }
}
