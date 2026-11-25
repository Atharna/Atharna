import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode mode = ThemeMode.system;
  void toggle(BuildContext c) {
    final dark = Theme.of(c).brightness == Brightness.dark;
    mode = dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

class ListingsProvider extends ChangeNotifier {
  List<Listing> all = [];
  double maxPrice = 500, minRating = 0;
  String? city;

  void listen() => FirebaseFirestore.instance.collection('listings').snapshots().listen((s) {
        all = s.docs.map(Listing.fromDoc).toList();
        notifyListeners();
      });

  List<String> get cities => all.map((l) => l.city).toSet().toList()..sort();
  List<Listing> filtered({required bool hotels}) => all
      .where((l) => l.isHotel == hotels && l.price <= maxPrice && l.rating >= minRating &&
          (city == null || l.city == city))
      .toList();

  void setFilters({double? price, double? rating, String? cityValue, bool clearCity = false}) {
    maxPrice = price ?? maxPrice;
    minRating = rating ?? minRating;
    city = clearCity ? null : (cityValue ?? city);
    notifyListeners();
  }
}
