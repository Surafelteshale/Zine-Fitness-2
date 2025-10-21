// lib/providers/filter_provider.dart
import 'package:flutter/material.dart';

class FilterProvider extends ChangeNotifier {
  String? gender;      // "ወንድ" or "ሴት"
  String? ageGroup;    // ">12", "12-18", "18-40", "40<"
  String? category;    // "ብረት", "ኤሮቢክስ", etc.

  // set filters at once
  void setFilters({String? gender, String? ageGroup, String? category}) {
    this.gender = gender;
    this.ageGroup = ageGroup;
    this.category = category;
    notifyListeners();
  }

  // clear a single filter
  void clearGender() {
    gender = null;
    notifyListeners();
  }

  void clearAgeGroup() {
    ageGroup = null;
    notifyListeners();
  }

  void clearCategory() {
    category = null;
    notifyListeners();
  }

  // clear all
  void clearAll() {
    gender = null;
    ageGroup = null;
    category = null;
    notifyListeners();
  }
}
