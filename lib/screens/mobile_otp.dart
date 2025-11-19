import 'dart:convert';
import 'package:caravelle/screens/otpscreen.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MobileNumberScreen extends StatefulWidget {
  @override
  _MobileNumberScreenState createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mobileController.addListener(_validateMobileNumber);
  }

  void _validateMobileNumber() {
    setState(() {
      _isButtonEnabled = _mobileController.text.length == 10 && 
          RegExp(r'^[6-9]\d{9}$').hasMatch(_mobileController.text);
    });
  }

  void _onContinuePressed() async {
    if (!_isButtonEnabled || _isLoading) return;

    final mobile = _mobileController.text.trim();

    if (mobile.isEmpty) {
      _showSnack("Please enter mobile number");
      return;
    }

    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
      _showSnack("Enter valid 10-digit mobile number");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("${baseUrl}generate_otp.php"),
        body: {
          'phone': mobile,
          'token': token,
        },
      );

      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['response'] == "success" || data['status'] == 200) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userMobile', mobile);

          _showSnack(
            data['message'] ?? "OTP sent successfully!",
            success: true,
          );

          Future.delayed(const Duration(milliseconds: 700), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
              builder: (context) => OtpScreen(),
              ),
            );
          });
        } else {
        _showSnack(data['message'] ?? "Failed to send OTP");
        }
      } else {
        _showSnack("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Back Button
              Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: Colors.black87, size: 20),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  padding: EdgeInsets.zero,
                ),
              ),

              SizedBox(height: 40.h),

              // Premium Header Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter Your Mobile Number",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  
                  SizedBox(height: 12.h),
                  Text(
                    "We'll send you an OTP for verification",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 48.h),

              // Premium Input Section
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "MOBILE NUMBER",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),

                    SizedBox(height: 12),

                    // Premium Input Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: _isButtonEnabled 
                              ? AppTheme.primaryColor.withOpacity(0.3)
                              : Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Premium Country Code
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 20.r),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "+91",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(Icons.arrow_drop_down_rounded, 
                                color: Colors.grey.shade500, size: 20),
                              ],
                            ),
                          ),

                          // Premium Mobile Input Field
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextFormField(
                                controller: _mobileController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  counterText: "",
                                  hintText: "Enter your mobile number",
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  errorStyle: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10.sp,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter mobile number';
                                  } 
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12),

                    // Premium Helper Text
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      child: Text(
                        _mobileController.text.isEmpty 
                            ? "Enter your 10-digit mobile number starting with 6-9"
                            : _isButtonEnabled 
                                ? "✓ Valid mobile number"
                                : "Please enter a valid mobile number",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _mobileController.text.isEmpty 
                              ? Colors.grey.shade500
                              : _isButtonEnabled 
                                  ? Colors.green
                                  : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 48),

              // Premium Continue Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: _isButtonEnabled && !_isLoading
                        ? LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                            AppTheme.primaryColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: !_isButtonEnabled || _isLoading
                        ? Colors.grey.shade300
                        : null,
                    boxShadow: _isButtonEnabled && !_isLoading
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _isButtonEnabled && !_isLoading 
                          ? _onContinuePressed 
                          : null,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 300),
                            opacity: _isLoading ? 0 : 1,
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: _isButtonEnabled && !_isLoading
                                    ? Colors.white
                                    : Colors.grey.shade500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (_isLoading)
                            SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Premium Privacy Note
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.r),
                child: Text(
                  "By continuing, you agree to our Terms of Service and Privacy Policy",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ),

            
              SizedBox(height: 40.h),
              Container(
                width: double.infinity,
                height: 4.h,
                margin: EdgeInsets.symmetric(horizontal: 80),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.grey.shade300,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}