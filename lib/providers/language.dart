import 'package:flutter/material.dart';

class Language with ChangeNotifier {
  Locale _language;

  Locale get currentLanguage => _language;

  Future<void> setLanguage(Locale language) async {
    _language = language;
    notifyListeners();
  }
}
