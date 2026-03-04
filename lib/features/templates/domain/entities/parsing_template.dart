import 'package:rekognita_app/features/templates/domain/entities/template_field.dart';

class ParsingTemplate {
  const ParsingTemplate({
    required this.id,
    required this.docType,
    required this.fields,
  });

  final int id;
  final String docType;
  final List<TemplateField> fields;
}
