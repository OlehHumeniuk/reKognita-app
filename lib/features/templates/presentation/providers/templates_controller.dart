import 'package:flutter/foundation.dart';

class TemplatesController extends ChangeNotifier {
  int _activeIndex = 0;

  int get activeIndex => _activeIndex;

  void select(int index) {
    if (_activeIndex == index) {
      return;
    }
    _activeIndex = index;
    notifyListeners();
  }
}
