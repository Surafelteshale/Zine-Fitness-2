import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IdProvider with ChangeNotifier {
  String _customerId = '';
  String get getData => _customerId;

  IdProvider() {
    _loadCustomerId();
  }

  Future<void> _loadCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    _customerId = prefs.getString('customerid') ?? '';
    print('Loaded customerId: $_customerId');
    notifyListeners();
  }

  Future<void> setCustomerId(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("customerid", uid);
    _customerId = uid;
    print('Customer ID saved: $_customerId');
    notifyListeners();
  }

  Future<void> clearCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("customerid");
    _customerId = '';
    print('Customer ID cleared');
    notifyListeners();
  }
}
