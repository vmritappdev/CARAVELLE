import 'dart:convert';
import 'package:caravelle/screens/confirm_mpin.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class OtpScreen extends StatefulWidget {
  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController _otpController = TextEditingController();
  String? _mobileNumber;
  String? _apiOtp;
  int _timerSeconds = 60;
  Timer? _timer;
  bool _showResend = false;
  DateTime? _otpSentTime;
  final int otpValidityMinutes = 10;
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _loadMobileNumber().then((_) {
      if (_mobileNumber != null && _mobileNumber!.isNotEmpty) {
        _sendOtp();
        _startTimer();
      }
    });
  }

  Future<void> _loadMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _mobileNumber = prefs.getString('userMobile') ?? '';
    });
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
          _showResend = true;
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
        body: {'phone': _mobileNumber, 'token': token},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200 || data['response'] == "success") {
          setState(() {
            _apiOtp = (data['otp'] ?? "").toString().trim();
            _otpSentTime = DateTime.now();
          });
          _showSnack("OTP sent successfully!", success: true);
        } else {
          _showSnack(data['message'] ?? "Failed to send OTP");
        }
      } else {
        _showSnack("Server error!");
      }
    } catch (e) {
      _showSnack("Error: $e");
    }
  }

  void _verifyOtp() {
    final enteredOtp = _otpController.text.trim();

    if (enteredOtp.length != 6) {
      _showSnack("Please enter 6-digit OTP");
      return;
    }

    if (_apiOtp == null || _apiOtp!.isEmpty) {
      _showSnack("OTP not received yet");
      return;
    }

    if (_otpSentTime != null) {
      final now = DateTime.now();
      final difference = now.difference(_otpSentTime!).inMinutes;
      if (difference >= otpValidityMinutes) {
        _showSnack("OTP expired, please resend");
        setState(() {
          _apiOtp = null;
          _showResend = true;
        });
        return;
      }
    }

    if (enteredOtp == _apiOtp) {
      _showSnack("OTP verified successfully!", success: true);
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MpinScreen1()),
        );
      });
    } else {
      _showSnack("Incorrect OTP, try again");
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // New OTP field method
 Widget _buildOtpField(int index) {
  return Container(
    width: 45.w,
    height: 45.h,
    margin: EdgeInsets.symmetric(horizontal: 4.w),
    child: TextField(
      controller: _otpControllers[index],
      focusNode: _focusNodes[index],
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 1,
      style: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
      decoration: InputDecoration(
        counterText: "",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) {
        // ✅ Move focus forward when user types
        if (value.isNotEmpty && index < 5) {
          _focusNodes[index + 1].requestFocus();
        }
        // ✅ Stay in same box when user deletes (don’t auto-jump back)
        else if (value.isEmpty) {
          _focusNodes[index].requestFocus();
        }

        // ✅ Update main OTP string
        String fullOtp = "";
        for (int i = 0; i < 6; i++) {
          fullOtp += _otpControllers[i].text;
        }
        _otpController.text = fullOtp;
      },
    ),
  );
}


  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Column(
            children: [
               Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                color: AppTheme.primaryColor,
                                size: 20.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 50.w),
                          Text(
                            "OTP Verification",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFF5F7FE),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header Section

             //   SizedBox(height: 20.h,),
                Container(
                 padding: EdgeInsets.symmetric(horizontal: 24.w, ),
                  child: Column(
                    children: [
                     // SizedBox(height: 20.h),
                     
                  //    SizedBox(height: 10.h),
                      Image.asset(
                        'assets/images/authen.png',
                        height: 180.h,
                        width: 250.w,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),

                // OTP Card
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 0.w),
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Enter the OTP sent to",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.phone_android,
                              color: AppTheme.primaryColor,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              _mobileNumber != null && _mobileNumber!.isNotEmpty
                                  ? "+91 $_mobileNumber"
                                  : "Loading...",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30.h),

                      // OTP Input Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) => _buildOtpField(index)),
                      ),
                      SizedBox(height: 20.h),

                      // OTP Display
                      _apiOtp != null && _apiOtp!.isNotEmpty
                          ? Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.green,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "Your OTP: $_apiOtp",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox.shrink(),

                      SizedBox(height: 20.h),

                      // Timer/Resend
                      _showResend
                           ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Didn't receive OTP? ",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14.sp,
            ),
          ),
          TextButton(
            onPressed: _onResendOtp,
            child: Text(
              "Resend OTP",
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
          ),
        ],
      )
    : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "You can resend OTP in ",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14.sp,
            ),
          ),
          Text(
            "$_timerSeconds s",
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),

                      SizedBox(height: 30.h),

                      // Verify Button
                      Container(
                        width: 300.w,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            "Verify OTP",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
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