// lib/model/wishlist.dart

import 'package:caravelle/model/offerscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Wishlist {
  static final Wishlist _instance = Wishlist._internal();
  factory Wishlist() => _instance;
  Wishlist._internal();

  final List<Offer> _items = [];

  List<Offer> get items => _items;

  // 🔹 Add Item
  void addItem(Offer item) {
    if (!_items.any((e) => e.title == item.title)) {
      _items.add(item);
      _saveWishlist();
    }
  }

  // 🔹 Remove Item
  void removeItem(Offer item) {
    _items.removeWhere((e) => e.title == item.title);
    _saveWishlist();
  }

  // 🔹 Toggle Item (Add/Remove)
  void toggleItem(Offer item) {
    if (contains(item)) {
      removeItem(item);
    } else {
      addItem(item);
    }
  }

  bool contains(Offer item) {
    return _items.any((e) => e.title == item.title);
  }

  void clear() {
    _items.clear();
    _saveWishlist();
  }

  // ✅ Save wishlist to SharedPreferences
  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedItems =
        _items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('wishlist_items', encodedItems);
  }

  // ✅ Load wishlist from SharedPreferences
  Future<void> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedData = prefs.getStringList('wishlist_items');
    if (savedData != null) {
      _items
        ..clear()
        ..addAll(savedData.map((e) => Offer.fromJson(jsonDecode(e))).toList());
    }
  }
}
