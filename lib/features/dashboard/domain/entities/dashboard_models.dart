import 'package:flutter/material.dart';

class DashboardStat {
  const DashboardStat({required this.value, required this.label, this.delta});

  final String value;
  final String label;
  final String? delta;
}

class ActivityItem {
  const ActivityItem({
    required this.name,
    required this.action,
    required this.time,
    required this.type,
  });

  final String name;
  final String action;
  final String time;
  final String type;
}

class DistributionItem {
  const DistributionItem({
    required this.name,
    required this.percent,
    required this.color,
  });

  final String name;
  final int percent;
  final Color color;
}
