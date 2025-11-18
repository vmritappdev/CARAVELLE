import 'package:caravelle/screens/login_screen.dart';
import 'package:caravelle/screens/termsandconditon.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen2 extends StatefulWidget {
  @override
  _SplashScreen2State createState() => _SplashScreen2State();
}

class _SplashScreen2State extends State<SplashScreen2> {
  final Color primaryGold = const Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    
    _navigateNext();
  }

  _navigateNext() async {
  await Future.delayed(const Duration(seconds: 3));

  final prefs = await SharedPreferences.getInstance();
  final acceptedTerms = prefs.getBool('accepted_terms') ?? false;

  if (acceptedTerms) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen()),
    );
  }
}

  @override
  Widget build(BuildContext context) {

     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppTheme.primaryColor, // Status bar color
      statusBarIconBrightness: Brightness.light, // Icons white
    ));
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/caravelle.png',
              height: 150.h,
              width: 150.w,
              color: Colors.white,
            ),
            SizedBox(height: 10.h),
            Text(
              'CARAVELLE',
              style: 
                 TextStyle(
                fontSize: AppTheme.logoSize,
               // fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 3,
              ),
              ),
            
            SizedBox(height: 5.h),
           Text(
  'Gold | CZ | Lab Diamonds',
  style: TextStyle(
    fontSize: AppTheme.fontSize,
    fontStyle: FontStyle.italic,
   // fontWeight: FontWeight.bold,
    color: const Color(0xFFD4AF37),
  ),
),
          ],
        ),
      ),
    );
  }
}
