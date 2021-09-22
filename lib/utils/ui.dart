import 'package:flutter/material.dart';

class UI with ChangeNotifier {
  double _fontSize = 0.5;
  bool _refresh = false;

  set fontSize(newValue) {
    _fontSize = newValue;
    notifyListeners();
  }

  void setRefresh(newValue) {
    _refresh = newValue;
    notifyListeners();
  }

  double get fontSize => _fontSize * 30;

  bool get refresh => _refresh;

  double get sliderFontSize => _fontSize;
}