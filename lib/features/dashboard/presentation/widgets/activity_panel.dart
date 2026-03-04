import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/dashboard/domain/entities/dashboard_models.dart';
import 'package:rekognita_app/features/dashboard/presentation/pages/activity_list_page.dart';
import 'package:rekognita_app/shared/widgets/initials_avatar.dart';
import 'package:rekognita_app/shared/widgets/rk_badge.dart';
import 'package:rekognita_app/shared/widgets/rk_card.dart';

class ActivityPanel extends StatelessWidget {
  const ActivityPanel({required this.items, super.key});

  final List<ActivityItem> items;

  @override
  Widget build(BuildContext context) {
    // Show at most 4 items in the dashboard preview
    final preview = items.take(4).toList();

    return RkCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Остання активність',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ActivityListPage(items: items),
                    fullscreenDialog: true,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Усі записи',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brand,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: AppColors.brand,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...preview.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: index == preview.length - 1
                        ? Colors.transparent
                        : AppColors.bg,
                    width: 1.2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  InitialsAvatar(name: item.name, size: 34, radius: 9),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: '${item.name} ',
                            style: const TextStyle(
                              fontSize: 13,
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
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
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
