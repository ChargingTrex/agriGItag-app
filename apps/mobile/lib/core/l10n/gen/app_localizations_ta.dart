// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'அக்ரிட்ரேஸ்';

  @override
  String get signIn => 'உள்நுழை';

  @override
  String get roleFarmer => 'விவசாயி';

  @override
  String get roleFieldOfficer => 'கள அலுவலர்';

  @override
  String get roleQc => 'தர ஆய்வாளர்';

  @override
  String assistFor(String farmerId) {
    return 'உதவி: $farmerId';
  }

  @override
  String get switchLanguage => 'English';

  @override
  String get playVoice => 'குரல் கேள்';
}
