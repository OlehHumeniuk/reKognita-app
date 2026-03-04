import 'package:flutter/foundation.dart';
import 'package:rekognita_app/core/data/mock_data.dart';
import 'package:rekognita_app/features/templates/domain/entities/parsing_template.dart';

class TemplatesController extends ChangeNotifier {
  final List<ParsingTemplate> _templates = List.of(seedTemplates);
  int? _activeIndex;

  List<ParsingTemplate> get templates => List.unmodifiable(_templates);
  int? get activeIndex => _activeIndex;

  void select(int index) {
    _activeIndex = _activeIndex == index ? null : index;
    notifyListeners();
  }

  void createTemplate(String docType) {
    final newId = _templates.isEmpty ? 1 : _templates.last.id + 1;
    _templates.add(ParsingTemplate(id: newId, docType: docType, fields: []));
    _activeIndex = _templates.length - 1;
    notifyListeners();
  }
}
