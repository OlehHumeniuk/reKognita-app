import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/integrations/domain/entities/integration.dart';

class IntegrationStatusBadge extends StatelessWidget {
  const IntegrationStatusBadge({required this.status, super.key});

  final IntegrationStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      IntegrationStatus.connected => AppColors.success,
      IntegrationStatus.pending => AppColors.warning,
      IntegrationStatus.disconnected => AppColors.danger,
    };
    final label = switch (status) {
      IntegrationStatus.connected => 'Підключено',
      IntegrationStatus.pending => 'Очікує',
      IntegrationStatus.disconnected => 'Відключено',
    };
    final textStyle = TextStyle(
      color: color,
      fontSize: 11,
      fontWeight: FontWeight.w700,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(0, -1),
            child: Text('●', style: textStyle),
          ),
          const SizedBox(width: 4),
          Text(label, style: textStyle),
        ],
      ),
    );
  }
}
