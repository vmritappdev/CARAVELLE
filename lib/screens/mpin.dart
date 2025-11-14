import 'dart:convert';
import 'package:caravelle/screens/main_screen.dart';

import 'package:caravelle/uittility/app_theme.dart';
import 'package:caravelle/uittility/conasthan_api.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- CARAVELLE TEAL & WHITE COLOR PALETTE ---
const Color primaryTeal = Color.fromRGBO(0, 148, 176, 1);
const Color backgroundLight = Colors.white;
const Color textOnTeal = Colors.white;
const Color textOnLight = Color(0xFF333333);
const Color keypadButtonColor = Color(0xFFE0F7FA);

class MpinScreen extends StatefulWidget {
  const MpinScreen({super.key});

  @override
  State<MpinScreen> createState() => _MpinScreenState();
}

class _MpinScreenState extends State<MpinScreen> {

    final LocalAuthentication auth = LocalAuthentication();


  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  
  final FocusNode _focusNode = FocusNode();

  int currentIndex = 0;
  String? _mobileNumber;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMobileNumber();
    _focusNode.requestFocus();
     _authenticateUser(); 
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _onKeyboardTap(String value) {
    setState(() {
      if (value == "X") {
        if (currentIndex > 0) {
          currentIndex--;
          _controllers[currentIndex].clear();
        }
      } else {
        if (currentIndex < 4) {
          _controllers[currentIndex].text = value;
          currentIndex++;
        }
      }
    });

    if (currentIndex == 4) {
      _verifyMpin();
    }
  }

  Future<void> _loadMobileNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _mobileNumber = prefs.getString('mobile_number');
    });
  }

 Future<void> _verifyMpin() async {
  String mpin = _controllers.map((controller) => controller.text).join().trim();
  if (mpin.length != 4) {
    _showSnack("Please enter 4-digit MPIN");
    return;
  }
  if (_mobileNumber == null || _mobileNumber!.isEmpty) {
    _showSnack("Mobile number not found");
    return;
  }

  setState(() => _isLoading = true);

  try {
    var url = Uri.parse("${baseUrl}verify_mpin.php");
    var response = await http.post(url, body: {
      'phone': _mobileNumber!,
      'mpin': mpin,
      'token': token,
    });

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      if (data['response'] == 'success') {
        _showSnack(data['message'] ?? "Login successful", success: true);

       Future.delayed(const Duration(milliseconds: 600), () {
  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const MainScreen()),
  );
});

      } else {
        _showSnack(data['message'] ?? "Invalid MPIN or mobile number");
        _clearMpinFields();
      }
    } else {
      _showSnack("Server error: ${response.statusCode}");
      _clearMpinFields();
    }
  } catch (e) {
    _showSnack("Error: $e");
    _clearMpinFields();
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  void _clearMpinFields() {
    setState(() {
      for (var controller in _controllers) {
        controller.clear();
      }
      currentIndex = 0;
    });
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





Future<void> _authenticateUser() async {
  try {
    bool canCheck = await auth.canCheckBiometrics;
    bool supported = await auth.isDeviceSupported();

    if (!canCheck || !supported) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fingerprint not supported on this device')),
        );
      }
      return;
    }

    // 🔒 Authenticate user with fingerprint
    bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Please verify your fingerprint to continue',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );

    // 👇 Navigate only if authentication succeeded
    if (didAuthenticate) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } 
  } catch (e) {
    print('Auth error: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}



  // --- COMPACT WIDGET BUILDER METHODS ---

  Widget _buildPinInput() {
    return Container(
      alignment: Alignment.center,
      height: 30, // Smaller height
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          bool filled = _controllers[index].text.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 8), // Reduced margin
            height: 16, // Smaller dots
            width: 16,
            decoration: BoxDecoration(
              color: filled ? backgroundLight : Colors.white54,
              shape: BoxShape.circle,
              border: Border.all(
                color: currentIndex == index ? backgroundLight : Colors.transparent,
                width: 1.5, // Thinner border
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: .0), // Less padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: numbers.map((num) {
          return _buildKeypadButton(
            label: num,
            onTap: num.isNotEmpty ? () => _onKeyboardTap(num) : null,
            isDelete: num == "X",
            isTransparent: num.isEmpty,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeypadButton({
    required String label,
    VoidCallback? onTap,
    bool isDelete = false,
    bool isTransparent = false,
  }) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 10.r), // Reduced padding
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          height: 55.h, // Smaller buttons
          width: 55.w,
          decoration: BoxDecoration(
            color: isTransparent
                ? Colors.transparent
                : keypadButtonColor,
            shape: BoxShape.circle,
            boxShadow: [
              if (!isTransparent)
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2, // Reduced blur
                  offset: const Offset(0, 1), // Smaller offset
                ),
            ],
          ),
          child: Center(
            child: isDelete
                ? Icon(
                    Icons.backspace_outlined,
                    size: 22, // Smaller icon
                    color: primaryTeal,
                  )
                : Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp, // Smaller font
                      fontWeight: FontWeight.w500,
                      color: isTransparent ? Colors.transparent : textOnLight,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
 


     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppTheme.primaryColor, // Status bar color
      statusBarIconBrightness: Brightness.light, // Icons white
    ));

    return Scaffold(
      backgroundColor:AppTheme.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- COMPACT TOP SECTION ---
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:  EdgeInsets.only(top: 30.r, left: 20.r, right: 20.r), // Reduced padding
                  child: Column(
                    children: [
                      // Compact Branding
                       Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 20.r),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/caravelle.png',
                            height: 60.h, width: 70.w,color: Colors.white,),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                'Caravelle',
                                style: TextStyle(
                                  color: Colors.white,
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
                
                      
                       SizedBox(height: 25.h), // Reduced spacing

                      // Compact Title Section
                      Text(
                        "Secure Login",
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp, // Smaller title
                          fontWeight: FontWeight.bold,
                          color: textOnTeal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Enter your 4-digit MPIN", // Shorter text
                        style: GoogleFonts.roboto(
                          fontSize: 14.sp, // Smaller font
                          color: Colors.white70,
                        ),
                      ),
                      if (_mobileNumber != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: Text(
                            "for Mobile: **** ${ _mobileNumber!.length > 4 ? _mobileNumber!.substring(_mobileNumber!.length - 4) : _mobileNumber!}",
                            style: GoogleFonts.roboto(
                              fontSize: 12.sp, // Smaller font
                              color: Colors.white70,
                            ),
                          ),
                        ),

                      const SizedBox(height: 30), // Reduced spacing

                      // MPIN Input Dots
                      _buildPinInput(),

                       SizedBox(height: 15.h), // Reduced spacing

                      // Forgot MPIN & Biometric Section in Row
                     Text(
                                "Forgot MPIN?",
                                style: GoogleFonts.roboto(
                                  fontSize: 14.h, // Smaller font
                                  color: backgroundLight,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: backgroundLight,
                                ),
                              ),
                            
                            
                            // Thumb Icon (Biometric)
                           
                           GestureDetector(
                               onTap: _authenticateUser,
                              child: Container(
                                padding:  EdgeInsets.all(8.r),
                                child: Icon(Icons.fingerprint, // Thumb icon instead of fingerprint
                                    size: 48, color: backgroundLight),
                              ),
                            ),
                        
                      
                      
                    //  const SizedBox(height: 20), // Reduced spacing

                      // Loading Indicator
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: CircularProgressIndicator(
                            color: backgroundLight,
                            strokeWidth: 2.5, // Thinner stroke
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // --- COMPACT BOTTOM KEYPAD ---
            Container(
              padding:  EdgeInsets.symmetric(vertical: .0.r), // Reduced padding
              child: Column(
                children: [
                  _buildNumberRow(["1", "2", "3"]),
                  _buildNumberRow(["4", "5", "6"]),
                  _buildNumberRow(["7", "8", "9"]),
                  _buildNumberRow(["", "0", "X"]), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}