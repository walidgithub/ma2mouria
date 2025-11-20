import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constant/language_manager.dart';

const String userLoggedIn = "userLoggedIn";
const String _userEmailKey = 'userEmail';
const String _userNameKey = 'userName';
const String _userPhotoKey = 'userPhoto';
const String _keyLang = "PREFS_KEY_LANG";

class AppPreferences {
  final SharedPreferences _sharedPreferences;
  static bool isLangChanged = false;

  AppPreferences(this._sharedPreferences);

  Future<String> getAppLanguage() async {
    String? language = _sharedPreferences.getString(_keyLang);
    if (language != null && language.isNotEmpty) {
      return language;
    } else {
      // return default lang
      return LanguageType.ENGLISH.getValue();
    }
  }

  Future<void> changeAppLanguage() async {
    String currentLang = await getAppLanguage();

    if (currentLang == LanguageType.ARABIC.getValue()) {
      // set english
      _sharedPreferences.setString(
          _keyLang, LanguageType.ENGLISH.getValue());
      isLangChanged = false;
    } else {
      // set arabic
      _sharedPreferences.setString(
          _keyLang, LanguageType.ARABIC.getValue());
      isLangChanged = true;
    }
  }

  Future<Locale> getLocal() async {
    String currentLang = await getAppLanguage();

    if (currentLang == LanguageType.ARABIC.getValue()) {
      isLangChanged = true;
      return ARABIC_LOCAL;
    } else {
      isLangChanged = false;
      return ENGLISH_LOCAL;
    }
  }

  Future<void> setUserLoggedIn() async {
    _sharedPreferences.setBool(userLoggedIn, true);
  }

  Future<bool> isUserLoggedIn() async {
    return _sharedPreferences.getBool(userLoggedIn) ?? false;
  }

  Future<void> setUserLoggedOut() async {
    _sharedPreferences.remove(userLoggedIn);
    await _sharedPreferences.clear();
  }

  Future<void> saveUserData({
    required String email,
    required String name,
    String? photoUrl,
  }) async {
    await _sharedPreferences.setString(_userEmailKey, email);
    await _sharedPreferences.setString(_userNameKey, name);
    if (photoUrl != null) await _sharedPreferences.setString(_userPhotoKey, photoUrl);
  }

  Map<String, String?> getUserData() {
    return {
      'email': _sharedPreferences.getString(_userEmailKey),
      'name': _sharedPreferences.getString(_userNameKey),
      'photoUrl': _sharedPreferences.getString(_userPhotoKey),
    };
  }
}
