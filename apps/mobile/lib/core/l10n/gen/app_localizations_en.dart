// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AgriTrace';

  @override
  String get signIn => 'Sign in';

  @override
  String get roleFarmer => 'Farmer';

  @override
  String get roleFieldOfficer => 'Field officer';

  @override
  String get roleQc => 'QC officer';

  @override
  String assistFor(String farmerId) {
    return 'Helping $farmerId';
  }

  @override
  String get switchLanguage => 'தமிழ்';

  @override
  String get playVoice => 'Play voice';
}
