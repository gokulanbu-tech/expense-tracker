import 'package:google_sign_in/google_sign_in.dart';
import 'package:expense_tracker_mobile/services/gmail_service.dart';
import 'package:expense_tracker_mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoggedIn = false;
  final GmailService _gmailService = GmailService();
  final ApiService _apiService = ApiService();

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('user_data')) return;

    final String? userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      _user = User.fromJson(jsonDecode(userDataString));
      _isLoggedIn = true;
      notifyListeners();
      // Auto-sync emails in background if logged in
      if (_user != null) {
        _gmailService.syncExpenses(_user!.id).then((_) => notifyListeners());
      }
    }
  }

  Future<void> loginWithGoogle() async {
    final account = await _gmailService.signIn();
    if (account != null) {
      final names = (account.displayName ?? "").split(" ");
      final firstName = names.isNotEmpty ? names[0] : "";
      final lastName = names.length > 1 ? names[1] : "";
      
      final user = await _apiService.loginWithGoogle(
        account.email, 
        firstName, 
        lastName
      );
      
      await setUser(user);
    }
  }

  Future<void> syncEmails() async {
    if (_user != null) {
      await _gmailService.syncExpenses(_user!.id);
      notifyListeners();
    }
  }

  Future<void> setUser(User user) async {
    _user = user;
    _isLoggedIn = true;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
    await prefs.setString('user_mobile', user.mobileNumber);
    await prefs.setString('user_id', user.id);
    
    notifyListeners();

    // Trigger initial sync on login
    syncEmails();
  }

  Future<void> logout() async {
    _user = null;
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await GoogleSignIn().signOut();
    notifyListeners();
  }
}

