import 'package:flutter/material.dart';

enum AppSection {
  dashboard('/app/dashboard', 'Дашборд', Icons.grid_view_rounded),
  team('/app/team', 'Команда', Icons.groups_rounded),
  documentTypes(
    '/app/document-types',
    'Типи документів',
    Icons.description_rounded,
  ),
  templates('/app/templates', 'Шаблони', Icons.dataset_rounded),
  integrations('/app/integrations', 'Інтеграції', Icons.hub_rounded);

  const AppSection(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;
}
