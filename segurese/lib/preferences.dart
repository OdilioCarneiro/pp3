import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static late SharedPreferences _preferences;

  static const _keyOnboardingViewed = 'onboarding_viewed';

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future setOnboardingViewed(bool viewed) async {
    await _preferences.setBool(_keyOnboardingViewed, viewed);
  }

  static bool get isOnboardingViewed {
    // Retorna false por padrão se a chave não existir
    return _preferences.getBool(_keyOnboardingViewed) ?? false;
  }
}