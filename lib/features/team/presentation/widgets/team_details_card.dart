import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/team/domain/entities/employee.dart';
import 'package:rekognita_app/shared/widgets/initials_avatar.dart';
import 'package:rekognita_app/shared/widgets/rk_card.dart';

class TeamDetailsCard extends StatelessWidget {
  const TeamDetailsCard({
    required this.employee,
    this.isSaving = false,
    this.onEdit,
    this.onToggleStatus,
    this.onAddDoc,
    this.onRemoveDoc,
    super.key,
  });

  final Employee? employee;
  final bool isSaving;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onAddDoc;
  final void Function(String docType)? onRemoveDoc;

  @override
  Widget build(BuildContext context) {
    if (employee == null) {
      return const RkCard(
        child: SizedBox(
          height: 280,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 36,
                  color: AppColors.muted,
                ),
                SizedBox(height: 10),
                Text(
                  'Оберіть співробітника',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isActive = employee!.isActive;

    return RkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(name: employee!.name, size: 56, radius: 16),
              const Spacer(),
              if (isSaving)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else ...[
                _ActionChip(
                  text: 'Редагувати',
                  onTap: onEdit,
                ),
                const SizedBox(width: 8),
                _ActionChip(
                  text: isActive ? 'Заблокувати' : 'Розблокувати',
                  isDanger: isActive,
                  onTap: onToggleStatus,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee!.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${employee!.role} • ${employee!.dept}',
                      style: const TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              if (!isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Заблокований',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border),
          const SizedBox(height: 10),
          const Text(
            'ДОСТУП ДО ТИПІВ',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 0.7,
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...employee!.docs.map(
            (doc) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      doc,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Text(
                    '● Активно',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  IconButton(
                    onPressed: isSaving ? null : () => onRemoveDoc?.call(doc),
                    icon: const Icon(Icons.close_rounded, size: 17),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              side: const BorderSide(color: AppColors.border, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: isSaving ? null : onAddDoc,
            child: const Text('+ Додати тип документа'),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.text,
    this.isDanger = false,
    this.onTap,
  });

  final String text;
  final bool isDanger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDanger ? const Color(0xFFFEE2E2) : AppColors.bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isDanger ? AppColors.danger : AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
