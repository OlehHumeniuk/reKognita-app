import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/integrations/domain/entities/integration.dart';
import 'package:rekognita_app/features/integrations/presentation/widgets/integration_status_badge.dart';
import 'package:rekognita_app/shared/widgets/rk_badge.dart';
import 'package:rekognita_app/shared/widgets/rk_card.dart';

class IntegrationCard extends StatelessWidget {
  const IntegrationCard({required this.integration, super.key});

  final Integration integration;

  @override
  Widget build(BuildContext context) {
    return RkCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: integration.color.withValues(alpha: 0.15),
            ),
            alignment: Alignment.center,
            child: Text(integration.icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Text(
                      integration.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                    IntegrationStatusBadge(status: integration.status),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: integration.types
                      .map((type) => RkBadge(text: type))
                      .toList(growable: false),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.brand.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'api.rekognita.io/wh/...',
              style: TextStyle(
                color: AppColors.brand,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(onPressed: () {}, child: const Text('Налаштувати')),
        ],
      ),
    );
  }
}
