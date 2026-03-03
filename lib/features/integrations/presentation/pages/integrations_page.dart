import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/core/data/mock_data.dart';
import 'package:rekognita_app/features/integrations/presentation/widgets/integration_card.dart';
import 'package:rekognita_app/shared/widgets/rk_card.dart';
import 'package:rekognita_app/shared/widgets/section_header.dart';

class IntegrationsPage extends StatelessWidget {
  const IntegrationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(
          title: 'Інтеграції',
          subtitle: 'Підключення зовнішніх систем та Webhook-маршрутизація',
          buttonLabel: '+ Нова інтеграція',
        ),
        const SizedBox(height: 12),
        ...seedIntegrations.map(
          (integration) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IntegrationCard(integration: integration),
          ),
        ),
        const RkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Безпека передачі даних',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Дані передаються по TLS 1.3. Фото після обробки не зберігаються. '
                'Self-Hosted контур ізольований від публічних LLM, а Webhook підписується HMAC-SHA256.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
