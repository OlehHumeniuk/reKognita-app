import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/dashboard/domain/entities/dashboard_models.dart';

class StatCard extends StatelessWidget {
  const StatCard({required this.stat, required this.index, super.key});

  final DashboardStat stat;
  final int index;

  static const _icons = [
    Icons.description_rounded,
    Icons.people_rounded,
    Icons.category_rounded,
    Icons.verified_rounded,
  ];

  static const _colors = [
    Color(0xFF2563EB),
    Color(0xFF059669),
    Color(0xFF7C3AED),
    Color(0xFF0891B2),
  ];

  static const _bgColors = [
    Color(0xFFEFF6FF),
    Color(0xFFF0FDF4),
    Color(0xFFF5F3FF),
    Color(0xFFECFEFF),
  ];

  static const _borderColors = [
    Color(0xFFBFDBFE),
    Color(0xFFBBF7D0),
    Color(0xFFDDD6FE),
    Color(0xFFA5F3FC),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    final icon = _icons[index % _icons.length];
    final bgColor = _bgColors[index % _bgColors.length];
    final borderColor = _borderColors[index % _borderColors.length];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Icon — top-right corner
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(19),
                  bottomLeft: Radius.circular(9),
                ),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  stat.label.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.3,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  stat.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -3.0,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
