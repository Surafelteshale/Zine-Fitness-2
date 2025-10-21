// lib/providers/user_provider.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Simple data model for a user (keep separate from your UserModel widget)
class AppUser {
  final String id;
  final String? name;
  final String? gender;
  final String? category;
  final int? age;
  final bool status; // paid or not
  final Map<String, dynamic> raw;

  AppUser({
    required this.id,
    this.name,
    this.gender,
    this.category,
    this.age,
    required this.status,
    required this.raw,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id']?.toString() ?? '',
      name: (map['name'] as String?) ?? '',
      gender: (map['gender'] as String?) ?? '',
      category: (map['category'] as String?) ?? '',
      age: map['age'] is int ? map['age'] as int : (map['age'] is String ? int.tryParse(map['age']) : null),
      status: map['status'] == true,
      raw: map,
    );
  }
}

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<AppUser> _users = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  bool _isListening = false;

  List<AppUser> get users => List.unmodifiable(_users);
  bool get isListening => _isListening;

  /// Start streaming users from Firestore. Call this once (e.g. in main or on first screen).
  void startListening() {
    if (_isListening) return;
    _isListening = true;

    _subscription = _firestore
        .collection('User')
        .orderBy('registrationDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      _users.clear();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        // include doc id if needed
        final merged = <String, dynamic>{...data};
        if (!merged.containsKey('id')) merged['id'] = doc.id;
        _users.add(AppUser.fromMap(merged));
      }
      notifyListeners();
    }, onError: (err) {
      // optionally handle error
      debugPrint('UserProvider stream error: $err');
    });
  }

  /// Stop listening if needed
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
