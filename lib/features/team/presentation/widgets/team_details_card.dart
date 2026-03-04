import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/dashboard/domain/entities/doc_record.dart';
import 'package:rekognita_app/features/team/domain/entities/employee.dart';
import 'package:rekognita_app/shared/widgets/rk_card.dart';

class TeamDetailsCard extends StatelessWidget {
  const TeamDetailsCard({
    required this.employee,
    this.isLoadingDocs = false,
    this.recentDocs,
    this.onShowDocs,
    super.key,
  });

  final Employee? employee;
  final bool isLoadingDocs;
  final List<DocRecord>? recentDocs;
  final VoidCallback? onShowDocs;

  @override
  Widget build(BuildContext context) {
    if (employee == null) {
      return const RkCard(
        child: SizedBox(
          height: 120,
          child: Center(
            child: Text(
              'Оберіть співробітника',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ),
        ),
      );
    }

    return RkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onShowDocs,
            child: Row(
              children: [
                const Text(
                  'ОСТАННІ ДОКУМЕНТИ',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.7,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isLoadingDocs) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                ] else if (onShowDocs != null) ...[
                  const Spacer(),
                  const Icon(
                    Icons.open_in_new_rounded,
                    size: 13,
                    color: AppColors.muted,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (recentDocs == null || (recentDocs!.isEmpty && !isLoadingDocs))
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Немає записів',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            )
          else
            ...recentDocs!.take(5).map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(r.typeIcon,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.docNumber,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                r.timeAgo,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: r.status.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            r.status.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: r.status.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
