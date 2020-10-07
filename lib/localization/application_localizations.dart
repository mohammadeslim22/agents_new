import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ApplicationLocalizations {
  ApplicationLocalizations(this.appLocale);
  final Locale appLocale;

  static ApplicationLocalizations of(BuildContext context) {
    return Localizations.of<ApplicationLocalizations>(
        context, ApplicationLocalizations);
  }

  Map<String, String> _localizedStrings;

  Future<void> load() async {
    // Load JSON file from the "language" folder
    final String jsonString =
        await rootBundle.loadString('assets/languages/$appLocale.json');
    final Map<String, dynamic> jsonLanguageMap =
        json.decode(jsonString) as Map<String, dynamic>;
    _localizedStrings = jsonLanguageMap.map((String key, dynamic value) {
      return MapEntry<String, String>(key, value.toString());
    });
  }

  // called from every widget which needs a localized text
  String translate(String jsonkey) {
    return _localizedStrings[jsonkey] ?? jsonkey;
  }
}
