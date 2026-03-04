import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/dashboard/domain/entities/doc_record.dart';
import 'package:rekognita_app/features/dashboard/presentation/pages/doc_record_page.dart';
import 'package:rekognita_app/shared/widgets/rk_card.dart';

class DocProcessPanel extends StatelessWidget {
  const DocProcessPanel({required this.records, super.key});

  final List<DocRecord> records;

  @override
  Widget build(BuildContext context) {
    final pending = records
        .where((r) => r.status == DocRecordStatus.pending)
        .length;
    final synced = records
        .where((r) => r.status == DocRecordStatus.synced)
        .length;

    return RkCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: title + stat pills
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Обробка',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
              ),
              _StatPill(
                label: 'Обробляється',
                count: pending,
                color: DocRecordStatus.pending.color,
              ),
              const SizedBox(width: 6),
              _StatPill(
                label: 'Синхронізовано',
                count: synced,
                color: DocRecordStatus.synced.color,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Vertical list — same rhythm as ActivityPanel
          ...records.asMap().entries.map((entry) {
            final index = entry.key;
            final record = entry.value;
            final isLast = index == records.length - 1;

            return _DocRecordRow(record: record, isLast: isLast);
          }),
        ],
      ),
    );
  }
}

class _DocRecordRow extends StatelessWidget {
  const _DocRecordRow({required this.record, required this.isLast});

  final DocRecord record;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final status = record.status;
    final color = record.typeColor;

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => DocRecordPage(record: record)),
      ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppColors.bg,
              width: 1.2,
            ),
          ),
        ),
        child: Row(
          children: [
            // Type icon (mirrors InitialsAvatar size from ActivityPanel)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                record.typeIcon,
                style: const TextStyle(fontSize: 17),
              ),
            ),
            const SizedBox(width: 10),

            // Doc number + person + time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.docNumber,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${record.uploadedBy} · ${record.timeAgo}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Status dot (icon only) + arrow
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(status.icon, size: 11, color: status.color),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 11,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
