import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/company_context/domain/entities/company.dart';

class CompanySwitcher extends StatelessWidget {
  const CompanySwitcher({
    required this.currentCompany,
    required this.companies,
    required this.onChanged,
    super.key,
  });

  final Company currentCompany;
  final List<Company> companies;
  final ValueChanged<Company> onChanged;

  @override
  Widget build(BuildContext context) {
    final pct = currentCompany.limit == null
        ? null
        : (currentCompany.pages / currentCompany.limit! * 100).round();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Компанія',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.8,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentCompany.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentCompany.plan == CompanyPlan.cloud
                          ? 'Хмара • ${currentCompany.pages} / ${currentCompany.limit} стор.'
                          : 'Self-Hosted',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: currentCompany.plan == CompanyPlan.cloud
                            ? AppColors.brandLight
                            : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<Company>(
                iconColor: Colors.white.withValues(alpha: 0.45),
                tooltip: 'Змінити компанію',
                color: AppColors.mid,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                onSelected: onChanged,
                itemBuilder: (_) => companies.map((company) {
                  final selected = company.id == currentCompany.id;
                  return PopupMenuItem<Company>(
                    value: company,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            company.name,
                            style: TextStyle(
                              color: selected ? AppColors.brand : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check_rounded,
                            color: AppColors.brand,
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          if (pct != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 3,
                value: pct / 100,
                color: pct > 85 ? AppColors.warning : AppColors.brandLight,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
