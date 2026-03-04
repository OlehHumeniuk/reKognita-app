import 'package:rekognita_app/features/templates/domain/entities/template_field.dart';

class ParsingTemplate {
  const ParsingTemplate({
    required this.id,
    required this.docType,
    required this.fields,
    this.integration,
  });

  final int id;
  final String docType;
  final String? integration;
  final List<TemplateField> fields;

  ParsingTemplate copyWith({String? integration}) {
    return ParsingTemplate(
      id: id,
      docType: docType,
      integration: integration ?? this.integration,
      fields: fields,
    );
  }
}
