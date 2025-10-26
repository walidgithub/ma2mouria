import 'package:shared_preferences/shared_preferences.dart';

const String userLoggedIn = "userLoggedIn";
const String userEmail = "userEmail";
const String userName = "userName";
const String _userEmailKey = 'userEmail';
const String _userPhotoKey = 'userPhoto';

class AppPreferences {
  final SharedPreferences _sharedPreferences;

  AppPreferences(this._sharedPreferences);

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
    String? photoUrl,
  }) async {
    await _sharedPreferences.setString(_userEmailKey, email);
    if (photoUrl != null) await _sharedPreferences.setString(_userPhotoKey, photoUrl);
  }

  Map<String, String?> getUserData() {
    return {
      'email': _sharedPreferences.getString(_userEmailKey),
      'photoUrl': _sharedPreferences.getString(_userPhotoKey),
    };
  }
}
