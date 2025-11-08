import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/offerscreen.dart';

class Cart {
  static final Cart _instance = Cart._internal();
  factory Cart() => _instance;
  Cart._internal();

  List<Offer> items = [];

  // Add item & save
  Future<void> addItem(Offer offer) async {
    items.add(offer);
    await _saveToPrefs();
  }

  // Remove item
  Future<void> removeItem(int index) async {
    items.removeAt(index);
    await _saveToPrefs();
  }

  // Load items from SharedPreferences
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartData = prefs.getString('cart_items');
    if (cartData != null) {
      List<dynamic> jsonList = jsonDecode(cartData);
      items = jsonList.map((json) => Offer.fromJson(json)).toList();
    }
  }

  // Save items to SharedPreferences
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList = items.map((e) => e.toJson()).toList();
    await prefs.setString('cart_items', jsonEncode(jsonList));
  }

  // Clear cart manually
  Future<void> clear() async {
    items.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart_items');
  }
}
