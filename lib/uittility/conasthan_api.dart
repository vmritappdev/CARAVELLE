


 import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String get baseUrl => "https://caravelle.in/barcode/app/";
 String get token => "mrbzjBkT-Wo7J-0Xev-Em0P-ixCo8kcG";



Future<bool> fetchValidityStatus() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final mobileNumber = prefs.getString('mobile_number') ?? '';

    if (mobileNumber.isEmpty || token.isEmpty) {
      print('⚠️ No mobile number or token found in SharedPreferences');
      return false;
    }

    final url = Uri.parse('${baseUrl}expiry_date.php');
    print('📡 API URL: $url');
    print('📱 Mobile: $mobileNumber');
    print('🔑 Token: $token');

    final response = await http.post(
      url,
      body: {
        'phone': mobileNumber,
        'token': token,
      },
    );

    print('🌐 Status Code: ${response.statusCode}');
    print('🌐 Raw Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // ✅ Case 1: API returns a date like "validity_date": "2025-11-05"
      if (data['validity_date'] != null) {
        final dateStr = data['validity_date'].toString().trim();

        // ❌ Invalid or placeholder date
        if (dateStr.isEmpty || dateStr == "0000-00-00") {
          print('⚠️ Invalid expiry date: $dateStr');
          return false;
        }

        final expiryDate = DateTime.parse(dateStr);
        final today = DateTime.now();

        // Current date (without time)
        final currentDate = DateTime(today.year, today.month, today.day);

        // Expiry day valid until 12 AM next day
        final expiryValidTill = expiryDate.add(const Duration(days: 1));

        print('📆 Expiry Date: $expiryDate');
        print('📅 Today: $currentDate');
        print('🕒 Valid Till: $expiryValidTill');

        // ✅ Active if current date is before expiryValidTill
        return currentDate.isBefore(expiryValidTill);
      }

      // ✅ Case 2: API returns days left
      if (data['days_left'] != null) {
        final int daysLeft = int.tryParse(data['days_left'].toString()) ?? 0;
        print('📆 Days left from API: $daysLeft');
        return daysLeft > 0;
      }

      print('⚠️ No valid date or days info in API response');
      return false;
    } else {
      print('❌ Server Error: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('⚠️ Exception: $e');
    return false;
  }
}





//const String schemeApiUrl = "${baseUrl}scheme";
