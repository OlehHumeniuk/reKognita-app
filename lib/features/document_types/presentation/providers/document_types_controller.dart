import 'package:flutter/foundation.dart';

class DocumentTypesController extends ChangeNotifier {
  int? _activeDocumentTypeId;

  int? get activeDocumentTypeId => _activeDocumentTypeId;

  void toggleSelection(int id) {
    _activeDocumentTypeId = _activeDocumentTypeId == id ? null : id;
    notifyListeners();
  }
}
