import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = '';
  String _profilePic =
      'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get profilePic => _profilePic;

  final String _validUser = "Dwiky";
  final String _validPass = "dwiky123";

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    _username = prefs.getString('username') ?? 'Admin';
    _profilePic = prefs.getString('profile_pic') ?? _profilePic;
    notifyListeners();
  }

  Future<bool> login(String user, String pass) async {
    if (user == _validUser && pass == _validPass) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('username', "Dwiky");
      _isLoggedIn = true;
      _username = "Dwiky";
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> updateProfilePic(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_pic', url);
    _profilePic = url;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isLoggedIn = false;
    notifyListeners();
  }
}
