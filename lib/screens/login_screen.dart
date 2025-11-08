import 'dart:convert';

import 'package:caravelle/screens/main_screen.dart';

import 'package:caravelle/screens/mobile_otp.dart';
import 'package:caravelle/screens/mpin.dart';
import 'package:caravelle/screens/selection.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _mpinController = TextEditingController();
  bool _obscureMpin = true;
  bool _isLoading = false;


 @override
  void initState() {
    super.initState();
    _loadSavedMobileNumber();
    
     WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkSavedPhoneNumber();
    
  }); // ✅ Load saved number when screen opens
  }

  Future<void> _loadSavedMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNumber = prefs.getString('mobile_number');
    if (savedNumber != null && savedNumber.isNotEmpty) {
      setState(() {
        _mobileController.text = savedNumber;
      });
    }
  }

  // 🔹 Save mobile number to SharedPreferences
  Future<void> _saveMobileNumberAndMpinFlag(String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobile_number', number);
    await prefs.setBool('mpin_set', true);
  }



 Future<void> _checkSavedPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedPhoneNumber = prefs.getString('mobile_number');
    bool? isMpinSet = prefs.getBool('mpin_set');

    if (savedPhoneNumber != null &&
        savedPhoneNumber.length == 10 &&
        isMpinSet == true) {
      print("✅ Mobile Number Found: $savedPhoneNumber");

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MpinScreen()),
      );
    } else {
      print("❌ No valid Mobile Number found");
      // Stay on LoginPage
    }
  }



   void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }



Future<void> _verifyMpin() async {
  String mobile = _mobileController.text.trim();
  String mpin = _mpinController.text.trim();

  // Validation
  if (mobile.isEmpty && mpin.isEmpty) {
    _showSnack("Please enter mobile number and MPIN");
    return;
  } else if (mobile.isEmpty) {
    _showSnack("Please enter mobile number");
    return;
  } else if (mpin.isEmpty) {
    _showSnack("Please enter MPIN");
    return;
  }

  setState(() => _isLoading = true);

    print("🔹 Token: $token");

  try {
    var url = Uri.parse("${baseUrl}verify_mpin.php");
    var response = await http.post(url, body: {
      'phone': mobile,
      'mpin': mpin,
      'token' : token,
    });

    print("API Response: ${response.body}");

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      if (data['response'] == 'success') {
        _showSnack(data['message'] ?? "Login successful", success: true);

        // Save mobile to SharedPreferences
        await _saveMobileNumberAndMpinFlag(mobile);

        // navigate to Dashboard
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        });
      } else {
        _showSnack(data['message'] ?? "Invalid MPIN or mobile number");
      }
    } else {
      _showSnack("Server error: ${response.statusCode}");
    }
  } catch (e) {
    _showSnack("Error: $e");
  } finally {
    setState(() => _isLoading = false);
  }
}





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 32.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),
                
                // Premium App Icon Container
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 20.r),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/caravelle.png',
                            height: 60.h, width: 70.w),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                'Caravelle',
                                style: TextStyle(
                                  color: const Color.fromRGBO(0, 148, 176, 1),
                                  fontStyle: FontStyle.italic,
                                  fontSize: AppTheme.logoSize,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            
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
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 10.h),
                
                // Welcome Text
                Text(
                  "Welcome Back!",
                  style: GoogleFonts.poppins(
                    fontSize: AppTheme.headerSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[900],
                    letterSpacing: -0.5,
                  ),
                ),
                
                 SizedBox(height: 20.h),
                
                Text(
                  "Login to access your account",
                  style: GoogleFonts.poppins(
                    fontSize: AppTheme.subHeaderSize,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                
                SizedBox(height: 30.h),
                
                // Mobile Number Field
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.05),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _mobileController,
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.poppins(
                      fontSize: AppTheme.fontSize,
                      color: Colors.grey[800],
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      counterText: '',
                      hintText: "Mobile Number",
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey[500],
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.phone_rounded,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(0, 148, 176, 1),
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20.r,
                        vertical: 18.r,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // MPIN Field
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.05),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    maxLength: 4,
                    controller: _mpinController,
                    keyboardType: TextInputType.number,
                    obscureText: _obscureMpin,
                    style: GoogleFonts.poppins(
                      fontSize: AppTheme.fontSize,
                      color: Colors.grey[800],
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "MPIN",
                      counterText: '',
                      hintStyle: GoogleFonts.poppins(
                      color: Colors.grey[500],
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: EdgeInsets.symmetric(horizontal: 8.r),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          color: AppTheme.primaryColor,
                          size: AppTheme.headerSize,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureMpin 
                              ? Icons.visibility_off_rounded 
                              : Icons.visibility_rounded,
                          color: Colors.grey[500],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureMpin = !_obscureMpin;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20.r,
                        vertical: 18.r,
                      ),
                    ),
                  ),
                ),
                
                // Forgot MPIN
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => MobileNumberScreen(),
                        )
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.r,
                        vertical: 4.r,
                      ),
                    ),
                    child: Text(
                      "Forgot MPIN?",
                      style: GoogleFonts.poppins(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                
              //  SizedBox(height: 10.h),
                
                // Login Button
                Container(
                  width: double.infinity,
                  height: 49.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyMpin,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            "Login",
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                
                SizedBox(height: 20.h),
                
                // Divider with "or"
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.r),
                      child: Text(
                        "or",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 20.h),
                
                // Login with OTP Button
                Container(
                  width: double.infinity,
                  height: 49.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to OTP login screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MobileNumberScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      "Login with OTP",
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 30.h),
                
                // Signup Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Create an account here ",
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 10.h),
                
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => SelectionScreen(),
                    ));
                  },
                  child: Text(
                    "Register Here",
                    style: GoogleFonts.poppins(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}