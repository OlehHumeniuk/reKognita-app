enum TemplateFieldType { text, number, date, table }

class TemplateField {
  const TemplateField({required this.name, required this.type});

  final String name;
  final TemplateFieldType type;
}
