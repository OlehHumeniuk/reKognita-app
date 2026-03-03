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
    final text = switch (status) {
      IntegrationStatus.connected => '● Підключено',
      IntegrationStatus.pending => '◌ Очікує',
      IntegrationStatus.disconnected => '○ Відключено',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
