import 'package:flutter/material.dart';

enum FieldType {
  text,
  table,
  formula,
  image;

  String get label {
    switch (this) {
      case FieldType.text:
        return 'Текст';
      case FieldType.table:
        return 'Таблиця';
      case FieldType.formula:
        return 'Формула';
      case FieldType.image:
        return 'Зображення';
    }
  }

  String get description {
    switch (this) {
      case FieldType.text:
        return 'Рядок, число або дата з документа';
      case FieldType.table:
        return 'Таблиця з вказаними колонками';
      case FieldType.formula:
        return 'Числова формула з підписом';
      case FieldType.image:
        return 'Фото, печатка або підпис';
    }
  }

  Color get color {
    switch (this) {
      case FieldType.text:
        return const Color(0xFF64748B);
      case FieldType.table:
        return const Color(0xFF2563EB);
      case FieldType.formula:
        return const Color(0xFFF59E0B);
      case FieldType.image:
        return const Color(0xFF10B981);
    }
  }

  IconData get icon {
    switch (this) {
      case FieldType.text:
        return Icons.text_fields_rounded;
      case FieldType.table:
        return Icons.table_chart_rounded;
      case FieldType.formula:
        return Icons.functions_rounded;
      case FieldType.image:
        return Icons.image_rounded;
    }
  }
}

class TemplateField {
  const TemplateField({
    required this.name,
    required this.type,
    this.tableColumns = const [],
    this.signatureLabel,
  });

  final String name;
  final FieldType type;
  final List<String> tableColumns;
  final String? signatureLabel;

  TemplateField copyWith({
    String? name,
    FieldType? type,
    List<String>? tableColumns,
    String? signatureLabel,
  }) {
    return TemplateField(
      name: name ?? this.name,
      type: type ?? this.type,
      tableColumns: tableColumns ?? this.tableColumns,
      signatureLabel: signatureLabel ?? this.signatureLabel,
    );
  }
}
