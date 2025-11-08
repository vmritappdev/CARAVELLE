import 'dart:async';
import 'dart:convert';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;




class GoldRateValidityWidget extends StatefulWidget {
  

  const GoldRateValidityWidget({
    Key? key,
  
  }) : super(key: key);

  @override
  State<GoldRateValidityWidget> createState() => _GoldRateValidityWidgetState();
}

class _GoldRateValidityWidgetState extends State<GoldRateValidityWidget> {
  String? goldRate;
  String? validityDate;
  Duration remainingTime = Duration.zero;
  Timer? countdownTimer;
  bool isLoadingValidity = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchGoldRate();
     _timer = Timer.periodic(Duration(minutes: 1), (_) => fetchGoldRate());
    _loadMobileAndFetchValidity();
  }


@override
void dispose() {
  // ✅ stop both timers when widget is removed
  _timer?.cancel();
  countdownTimer?.cancel();
  super.dispose();
}

  Future<void> _loadMobileAndFetchValidity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mobileNumber = prefs.getString('mobile_number') ?? '';

      if (mobileNumber.isNotEmpty) {
        print('📱 Saved Mobile Number: $mobileNumber');
        fetchValidityDate(mobileNumber);
      } else {
        print('⚠️ No mobile number found in SharedPreferences');
        setState(() => isLoadingValidity = false);
      }
    } catch (e) {
      print('⚠️ SharedPreferences Error: $e');
      setState(() => isLoadingValidity = false);
    }
  }

  Future<void> fetchGoldRate() async {
  final url = '${baseUrl}gold_rate_display.php';

  try {
    print('🌐 GOLD RATE API CALL STARTED');
    print('📬 URL: $url');
    print('🔑 Token Sent: $token');

    final response = await http.post(
      Uri.parse(url),
      body: {'token': token},
    );

    print('🔵 Status Code: ${response.statusCode}');
    print('📩 Raw Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['response'] == 'success' &&
          data['data'] != null &&
          data['data'].isNotEmpty) {
        final rate = data['data'][0]['gold_rate']?.toString() ?? "0.00";

        // ✅ Prevent setState if widget is disposed
        if (!mounted) return;

        setState(() {
          goldRate = rate;
        });

        print('🏅 Current Gold Rate: ₹$goldRate per gram');
      } else {
        print('❌ Error Message: ${data['message']}');
      }
    } else {
      print('🔴 Server Error: ${response.statusCode}');
    }
  } catch (e) {
    print('⚠️ Exception: $e');
  }
}

Future<void> fetchValidityDate(String mobileNumber) async {
  final url = '${baseUrl}expiry_date.php';

  try {
    print('==============================');
    print('🌐 VALIDITY API CALL STARTED');
    print('📬 URL: $url');
    print('🔑 Token Sent: $token');
    print('📱 Mobile Sent: $mobileNumber');
    print('==============================');

    final response = await http.post(
      Uri.parse(url),
      body: {
        'token': token,
        'phone': mobileNumber,
      },
    );

    print('🔵 Status Code: ${response.statusCode}');
    print('📩 Raw Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['response'] == 'success' && data['validity_date'] != null) {
        final dateStr = data['validity_date'];
        final expiry = DateTime.tryParse(dateStr);

        if (expiry != null) {
          // ✅ expiry day full valid, expire from next day 00:00
          final expiryWithGrace = expiry.add(const Duration(days: 1));

          print('📆 Expiry Date: $expiry');
          print('🕒 Valid Till (next day): $expiryWithGrace');

          if (!mounted) return;
          setState(() {
            validityDate = expiryWithGrace.toIso8601String();
            isLoadingValidity = false;
          });

          // countdown start for next-day expiry
          startCountdown(expiryWithGrace);
        } else {
          print('⚠️ Invalid date format from API');
          if (!mounted) return;
          setState(() => isLoadingValidity = false);
        }
      } else {
        print('❌ Error: ${data['message']}');
        if (!mounted) return;
        setState(() => isLoadingValidity = false);
      }
    } else {
      print('🔴 Server Error: ${response.statusCode}');
      if (!mounted) return;
      setState(() => isLoadingValidity = false);
    }
  } catch (e) {
    print('⚠️ Exception: $e');
    if (!mounted) return;
    setState(() => isLoadingValidity = false);
  }
}

void startCountdown(DateTime expiryWithGrace) {
  countdownTimer?.cancel();

  countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    final now = DateTime.now();
    final diff = expiryWithGrace.difference(now);

    if (!mounted) return;

    if (diff.isNegative) {
      timer.cancel();
      setState(() => remainingTime = Duration.zero);
      print('⛔ Subscription expired.');
    } else {
      setState(() => remainingTime = diff);
    }
  });
}

// Helper functions
String twoDigits(int n) => n.toString().padLeft(2, '0');
String get days => remainingTime.inDays.toString();
String get hours => twoDigits(remainingTime.inHours.remainder(24));
String get minutes => twoDigits(remainingTime.inMinutes.remainder(60));
String get seconds => twoDigits(remainingTime.inSeconds.remainder(60));

  Widget _buildTimeBox(String value, String label) {
    return Column(
      children: [
        Container(
          width: 50.w,
          height: 35.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppTheme.primaryColor,
                Color(0xFF00B3B3),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

 

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0.w),
      child: Container(
        padding: EdgeInsets.all(10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 🟡 Gold Rate Section
            Column(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Gold Rate",
                    style: TextStyle(
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Icon(Icons.currency_rupee,
                          color: Colors.amber.shade700, size: 17),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      goldRate != null ? "₹$goldRate / gm" : "Loading...",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ⏰ Countdown Section
            isLoadingValidity
                ? const Center()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTimeBox(days, 'Days'),
                      SizedBox(width: 10.w),
                      _buildTimeBox(hours, 'Hrs'),
                      SizedBox(width: 10.w),
                      _buildTimeBox(minutes, 'Min'),
                      SizedBox(width: 10.w),
                      _buildTimeBox(seconds, 'Sec'),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
