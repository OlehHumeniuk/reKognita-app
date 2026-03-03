import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';

class RkCard extends StatelessWidget {
  const RkCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 16,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
