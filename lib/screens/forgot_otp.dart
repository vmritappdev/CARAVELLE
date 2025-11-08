import 'dart:convert';
import 'package:caravelle/screens/confirm_mpin.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotOtpScreen extends StatefulWidget {
  @override
  _ForgotOtpScreenState createState() => _ForgotOtpScreenState();
}

class _ForgotOtpScreenState extends State< ForgotOtpScreen> {
  TextEditingController _otpController = TextEditingController();
  String? _mobileNumber;
  String? _apiOtp; // OTP received from API
  int _timerSeconds = 60; // 60 sec timer
  Timer? _timer;
  bool _showResend = false;

  @override
  void initState() {
    super.initState();
    _loadMobileNumber().then((_) {
      if (_mobileNumber != null && _mobileNumber!.isNotEmpty) {
        _sendOtp(); // send OTP on screen open
        _startTimer();
      }
    });
  }

  Future<void> _loadMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _mobileNumber = prefs.getString('userMobile') ?? '';
    });
    print("Loaded mobile: $_mobileNumber");
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timerSeconds = 60;
      _showResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        timer.cancel();
        setState(() {
          _showResend = true; // allow resend
        });
      } else {
        setState(() {
          _timerSeconds--;
        });
      }
    });
  }

  void _onResendOtp() {
    if (_mobileNumber != null && _mobileNumber!.isNotEmpty && _showResend) {
      _sendOtp();
      _startTimer();
    }
  }

  Future<void> _sendOtp() async {
    if (_mobileNumber == null || _mobileNumber!.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse("${baseUrl}generate_otp.php"),
        body: {'phone': _mobileNumber,'token': token},
      );

      print("HTTP Status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200 || data['response'] == "success") {
          setState(() {
            _apiOtp = (data['otp'] ?? "").toString().trim(); // ensure string
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OTP sent successfully!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Failed to send OTP")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server error!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _verifyOtp() {
    final enteredOtp = _otpController.text.trim();

    if (enteredOtp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter 6-digit OTP")),
      );
      return;
    }

    if (_apiOtp == null || _apiOtp!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP not received yet")),
      );
      return;
    }

    if (enteredOtp == _apiOtp) {
      // OTP correct, navigate
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MpinScreen1()),
      );
    } else {
      // OTP incorrect
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect OTP, try again!")),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color(0xFFF5F7FE),
      ),
      backgroundColor: const Color(0xFFF5F7FE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/authen.png',
                      height: 200.h, width: 300.w),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding:  EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text("OTP sent to",
                        style: TextStyle(fontSize: 16, color: Colors.black87)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_android,
                            color: AppTheme.primaryColor),
                         SizedBox(width: 8.w),
                        Text(
                          _mobileNumber != null && _mobileNumber!.isNotEmpty
                              ? "+91 $_mobileNumber"
                              : "Loading...",
                          style:  TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.sp),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit,
                              size: 18, color: AppTheme.primaryColor),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                     SizedBox(height: 20.h),

                    // Single OTP field
                    SizedBox(
                      height: 45.h,
                      child: TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24),
                        decoration:  InputDecoration(
                          hintText: "Enter OTP",hintStyle: TextStyle(fontSize: 20.sp),
                          counterText: "",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryColor))
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

_apiOtp != null && _apiOtp!.isNotEmpty
  ? Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        "Your OTP: $_apiOtp",
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
        ),
      ),
    )
  : SizedBox.shrink(),

_showResend
  ? TextButton(
      onPressed: _onResendOtp,
      child: const Text("Resend OTP",
          style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold)),
    )
  : Text("Waiting for OTP... $_timerSeconds",
      style: const TextStyle(color: Colors.black54)),


                     SizedBox(height: 20.h),

                    ElevatedButton(
                      onPressed: _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Verify OTP"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
