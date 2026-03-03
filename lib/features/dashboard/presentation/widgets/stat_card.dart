import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/dashboard/domain/entities/dashboard_models.dart';
import 'package:rekognita_app/shared/widgets/rk_card.dart';

class StatCard extends StatelessWidget {
  const StatCard({required this.stat, super.key});

  final DashboardStat stat;

  @override
  Widget build(BuildContext context) {
    return RkCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          if (stat.delta != null) ...[
            const SizedBox(height: 8),
            Text(
              '↑ ${stat.delta}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
