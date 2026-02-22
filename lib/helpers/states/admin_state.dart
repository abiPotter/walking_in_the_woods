import 'package:flutter/material.dart';

class AdminState extends ChangeNotifier {
  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  void setAdmin(bool value) {
    _isAdmin = value;
    notifyListeners();
  }
}
