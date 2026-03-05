import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/team/domain/entities/employee.dart';
import 'package:rekognita_app/shared/widgets/initials_avatar.dart';

class TeamMemberTile extends StatelessWidget {
  const TeamMemberTile({
    required this.employee,
    required this.selected,
    required this.onTap,
    this.onEdit,
    this.onToggleBlock,
    this.onDelete,
    this.onShowQr,
    super.key,
  });

  final Employee employee;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleBlock;
  final VoidCallback? onDelete;
  final VoidCallback? onShowQr;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: selected ? AppColors.brand.withValues(alpha: 0.06) : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppColors.brand : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Online dot + blocked lock
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: employee.isOnline ? AppColors.success : AppColors.muted,
                    ),
                  ),
                  if (employee.isBlocked) ...[
                    const SizedBox(height: 3),
                    const Icon(
                      Icons.lock_rounded,
                      size: 11,
                      color: AppColors.danger,
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 10),
              // Avatar
              InitialsAvatar(name: employee.name),
              const SizedBox(width: 12),
              // Name + role/dept
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: employee.isBlocked
                            ? AppColors.muted
                            : AppColors.dark,
                        decoration: employee.isBlocked
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      employee.isBlocked
                          ? '${employee.role} • ${employee.dept} • Заблоковано'
                          : '${employee.role} • ${employee.dept}',
                      style: TextStyle(
                        fontSize: 12,
                        color: employee.isBlocked
                            ? AppColors.danger
                            : AppColors.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Action buttons
              if (employee.inviteCode != null)
                _TileAction(icon: Icons.qr_code_rounded, onTap: onShowQr),
              _TileAction(icon: Icons.edit_outlined, onTap: onEdit),
              _TileAction(
                icon: employee.isBlocked
                    ? Icons.lock_open_rounded
                    : Icons.lock_outline_rounded,
                isDanger: !employee.isBlocked,
                isSuccess: employee.isBlocked,
                onTap: onToggleBlock,
              ),
              _TileAction(
                icon: Icons.delete_outline_rounded,
                isDanger: true,
                onTap: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileAction extends StatelessWidget {
  const _TileAction({
    required this.icon,
    this.isDanger = false,
    this.isSuccess = false,
    this.onTap,
  });

  final IconData icon;
  final bool isDanger;
  final bool isSuccess;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isDanger
        ? AppColors.danger
        : isSuccess
            ? AppColors.success
            : AppColors.muted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }
}
