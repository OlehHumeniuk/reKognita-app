import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/dashboard/domain/entities/doc_record.dart';
import 'package:rekognita_app/features/dashboard/presentation/pages/doc_record_page.dart';

class DocProcessCard extends StatelessWidget {
  const DocProcessCard({required this.record, super.key});

  final DocRecord record;

  @override
  Widget build(BuildContext context) {
    final status = record.status;
    final color = record.typeColor;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DocRecordPage(record: record),
        ),
      ),
      child: Container(
        width: 210,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main row: icon + doc info + status dot
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    record.typeIcon,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 9),

                // Doc number + person name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.docNumber,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.uploadedBy,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.muted,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // Status: icon only, no text
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(status.icon, size: 11, color: status.color),
                ),
              ],
            ),

            const SizedBox(height: 9),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 7),

            // ── Footer: time + arrow link
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 11,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 3),
                Text(
                  record.timeAgo,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.muted,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: AppColors.muted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
