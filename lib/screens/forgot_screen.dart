
import 'package:caravelle/screens/congragilation.dart';

import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotScreen extends StatefulWidget {
  @override
  _ForgotScreenState createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final Color primaryBlue = Color.fromRGBO(0, 148, 176, 1);
  final Color backgroundColor = Color(0xFFF8F9FA);
  final Color cardColor = Colors.white;
  final Color textColor = Color(0xFF2D3748);

  TextEditingController mpinController = TextEditingController();
  TextEditingController confirmMpinController = TextEditingController();

  String? mobileNumber;

  TextEditingController mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMobileNumber();
   
  }

 
 // full mpin ని build చేయడానికి helper
String _getFullMpin(List<TextEditingController> controllers) {
  return controllers.map((c) => c.text).join();
}

void _submit() async {
  String mpin = _getFullMpin(_mpinControllers);
  String confirmMpin = _getFullMpin(_confirmMpinControllers);

  // 4 digits check
  if (mpin.length != 4 || confirmMpin.length != 4) {
    _showSnack("Please enter 4 digit MPIN");
    return;
  }

  // mismatch check
  if (mpin != confirmMpin) {
    _showSnack("MPIN & Confirm MPIN do not match");
    return;
  }

  // save to SharedPreferences
  await _saveMpin(mpin);

  // Navigate to Congrats Screen

  
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => CongratsScreen()),
  );

  
}


Future<void> _loadMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      mobileNumber = prefs.getString('userMobile') ?? '';
    });
    print("Loaded mobile: $mobileNumber");
  }

Future<void> _saveMpin(String mpin) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userMpin', mpin);
}

void _showSnack(String msg, {bool success = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        msg,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      backgroundColor: success ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.all(16),
    ),
  );
}


 // TOP LEVEL లో initialize చేయాలి
List<TextEditingController> _mpinControllers = List.generate(4, (i) => TextEditingController());
List<TextEditingController> _confirmMpinControllers = List.generate(4, (i) => TextEditingController());

List<FocusNode> _mpinFocus = List.generate(4, (i) => FocusNode());
List<FocusNode> _confirmFocus = List.generate(4, (i) => FocusNode());

Widget _buildMpinField(
  String label,
  List<TextEditingController> controllers,
  List<FocusNode> focusNodes, {
  bool isConfirm = false,
  FocusNode? nextFocusNode, // 🔹 కొత్త parameter (Confirm MPIN మొదటి focus కోసం)
}) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 8.r),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.r, bottom: 12.r),
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppTheme.subHeaderSize,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return Container(
              height: 50.h,
              width: 45.w,
              margin: EdgeInsets.symmetric(horizontal: 6.r),
              child: TextField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                obscureText: !isConfirm, // 🔹 Enter MPIN → dots, Confirm MPIN → digits
                maxLength: 1,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppTheme.headerSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: Colors.grey[50],
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                ),
                onChanged: (val) {
                  if (val.isNotEmpty && index < 3) {
                    FocusScope.of(context)
                        .requestFocus(focusNodes[index + 1]);
                  } 
                  // ✅ 4 digits complete అయిన తర్వాత Confirm MPIN కి వెళ్లాలి
                  else if (val.isNotEmpty && index == 3) {
                    if (!isConfirm && nextFocusNode != null) {
                      FocusScope.of(context).requestFocus(nextFocusNode);
                    } else {
                      FocusScope.of(context).unfocus();
                    }
                  } 
                  else if (val.isEmpty && index > 0) {
                    FocusScope.of(context)
                        .requestFocus(focusNodes[index - 1]);
                  }
                },
              ),
            );
          }),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      
      child: Scaffold(
    
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(
         // physics: NeverScrollableScrollPhysics(), 
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 32.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              //  SizedBox(height: 20),
                
                // App Logo with enhanced design
                Container(
                  width: 70.w,
                  height: 70.h,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Image.asset(
  "assets/images/sequer.png",
  width: 48.w,
  height: 48.h,
  //color: primaryBlue, // optional color overlay
),
                ),
                
                SizedBox(height: 6.h),
                
                // Title Section
                Text(
                  "Set Your MPIN",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                
                SizedBox(height: 10.h),
                
                // Mobile Number
                
                
               // SizedBox(height: 15.h),
                
                // MPIN Fields Card
               Container(
  width: double.infinity,
  padding: EdgeInsets.all(24.r),
  decoration: BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    children: [
      // 🔹 Readonly Mobile Number Field (inside card, above Enter MPIN)
     
     // SizedBox(height: 24.h),

      // Enter MPIN
      _buildMpinField("Enter MPIN", _mpinControllers, _mpinFocus, isConfirm: false,nextFocusNode: _confirmFocus[0],),
      SizedBox(height: 5.h),

      // Confirm MPIN
      _buildMpinField("Confirm MPIN", _confirmMpinControllers, _confirmFocus, isConfirm: true, ),
    ],
  ),
),

                
                SizedBox(height: 10.h),
                
                // Info Text
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 16.r),
                  child: Text(
                    "Your MPIN will be used to secure your account and authorize transactions",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTheme.fontSize,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ),
                
                SizedBox(height: 30.h),
                
                // Submit Button
                Container(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.r),
                    ),
                    child: Text(
                      "SET MPIN",
                      style: TextStyle(
                        fontSize: AppTheme.headerSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}