import 'package:flutter/material.dart';

class DocumentType {
  const DocumentType({
    required this.id,
    required this.name,
    required this.icon,
    required this.integration,
    required this.fields,
    required this.workers,
    required this.color,
  });

  final int id;
  final String name;
  final String icon;
  final String integration;
  final int fields;
  final int workers;
  final Color color;
}
