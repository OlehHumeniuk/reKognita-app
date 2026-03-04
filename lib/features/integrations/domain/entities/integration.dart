import 'package:flutter/material.dart';

enum IntegrationStatus { connected, pending, disconnected }

class Integration {
  const Integration({
    required this.id,
    required this.name,
    required this.status,
    required this.types,
    required this.icon,
    required this.color,
    this.webhookUrl,
  });

  final int id;
  final String name;
  final IntegrationStatus status;
  final List<String> types;
  final String icon;
  final Color color;
  final String? webhookUrl;

  Integration copyWith({
    int? id,
    String? name,
    IntegrationStatus? status,
    List<String>? types,
    String? icon,
    Color? color,
    String? webhookUrl,
  }) {
    return Integration(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      types: types ?? this.types,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      webhookUrl: webhookUrl ?? this.webhookUrl,
    );
  }

  static IntegrationStatus _statusFromString(String s) => switch (s) {
        'connected' => IntegrationStatus.connected,
        'disconnected' => IntegrationStatus.disconnected,
        _ => IntegrationStatus.pending,
      };

  static Color _colorFromHex(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  factory Integration.fromJson(Map<String, dynamic> json) {
    return Integration(
      id: json['id'] as int,
      name: json['name'] as String,
      status: _statusFromString(json['status'] as String),
      types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
      icon: json['icon'] as String,
      color: _colorFromHex(json['color'] as String),
      webhookUrl: json['webhookUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'status': status.name,
        'types': types,
        'icon': icon,
        'color': '#${color.toARGB32().toRadixString(16).substring(2)}',
        'webhookUrl': webhookUrl,
      };
}
