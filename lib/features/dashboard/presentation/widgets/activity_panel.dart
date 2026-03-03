import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/dashboard/domain/entities/dashboard_models.dart';
import 'package:rekognita_app/shared/widgets/initials_avatar.dart';
import 'package:rekognita_app/shared/widgets/rk_badge.dart';
import 'package:rekognita_app/shared/widgets/rk_card.dart';

class ActivityPanel extends StatelessWidget {
  const ActivityPanel({required this.items, super.key});

  final List<ActivityItem> items;

  @override
  Widget build(BuildContext context) {
    return RkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Остання активність',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: index == items.length - 1
                        ? Colors.transparent
                        : AppColors.bg,
                  ),
                ),
              ),
              child: Row(
                children: [
                  InitialsAvatar(name: item.name, size: 36, radius: 10),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: '${item.name} ',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dark,
                            ),
                            children: [
                              TextSpan(
                                text: item.action,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.time,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RkBadge(text: item.type),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
