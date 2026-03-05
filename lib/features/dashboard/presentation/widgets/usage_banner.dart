import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/company_context/domain/entities/company.dart';

class UsageBanner extends StatelessWidget {
  const UsageBanner({required this.company, this.onUpgrade, super.key});

  final Company company;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    if (company.limit == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
        ),
        child: const Text(
          'Self-Hosted • контур ізольований, ліміт сторінок не застосовується',
          style: TextStyle(
            color: AppColors.dark,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final pct = (company.pages / company.limit! * 100).round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: pct > 85
            ? const Color(0xFFFFFBEB)
            : AppColors.brand.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: pct > 85
              ? AppColors.warning.withValues(alpha: 0.4)
              : AppColors.brand.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '${company.pages}/${company.limit} сторінок оброблено',
                  style: const TextStyle(fontSize: 15, color: AppColors.dark),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: onUpgrade,
                style: FilledButton.styleFrom(backgroundColor: AppColors.brand),
                child: const Text('Поповнити'),
              ),
            ],
          ),
          // const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: pct / 100,
              color: pct > 85 ? AppColors.warning : AppColors.brand,
              backgroundColor: AppColors.border,
            ),
          ),
        ],
      ),
    );
  }
}
