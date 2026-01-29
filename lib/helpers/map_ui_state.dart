import 'package:flutter/material.dart';

class MapUiState extends ChangeNotifier {
  bool keyboardOpen = false;

  void openKeyboard() {
    keyboardOpen = true;
    notifyListeners();
  }

  void closeKeyboard() {
    keyboardOpen = false;
    notifyListeners();
  }
}
