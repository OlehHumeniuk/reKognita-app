import 'package:flutter/material.dart';

enum IntegrationStatus { connected, pending, disconnected }

class Integration {
  const Integration({
    required this.name,
    required this.status,
    required this.types,
    required this.icon,
    required this.color,
  });

  final String name;
  final IntegrationStatus status;
  final List<String> types;
  final String icon;
  final Color color;
}
