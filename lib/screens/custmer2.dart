import 'dart:convert';

import 'package:caravelle/screens/otpscreen.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CustomerForm extends StatefulWidget {
  @override
  _CustomerFormState createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final Color primaryColor = Color(0xFF0094B0);
  final Color accentColor = Color(0xFFFF6B35);
  final Color backgroundColor = Color(0xFFF8F9FA);
  final Color cardColor = Colors.white;
  final Color textPrimary = Color(0xFF2D3748);
  final Color textSecondary = Color(0xFF718096);
  final Color errorColor = Color(0xFFD32F2F);
  
  // Text Editing Controllers
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController phone1Controller = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController panController = TextEditingController();
  TextEditingController adharController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController occupationController = TextEditingController();
  TextEditingController shopNameController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
  
  // Form Variables
  String? gender;
  DateTime? selectedDate;
  DateTime? anniversaryDate;
  String? customerType;
  List<String> jewelleryPreferences = [];

  // Options
  final List<String> genderOptions = ['Male', 'Female'];

  bool _isLoading = false;
  bool _isFetchingPincode = false;

  // Validation flags
  Map<String, bool> fieldErrors = {
    'fullName': false,
    'phone': false,
    'dateOfBirth': false,
    'address': false,
    'pincode': false,
    'state': false,
    'city': false,
  };

  @override
  void initState() {
    super.initState();

    // Pincode listener for auto-fill
    pincodeController.addListener(() {
      final pincode = pincodeController.text.trim();
      if (pincode.length == 6) {
        _fetchLocationDetails(pincode);
      } else {
        // Clear state & city if pincode is incomplete
        stateController.text = '';
        cityController.text = '';
        // Clear validation error when pincode is being edited
        setState(() {
          fieldErrors['pincode'] = false;
          fieldErrors['state'] = false;
          fieldErrors['city'] = false;
        });
      }
    });
  }

  Future<void> _fetchLocationDetails(String pincode) async {
    setState(() {
      _isFetchingPincode = true;
    });

    try {
      final response = await http.get(Uri.parse('https://api.postalpincode.in/pincode/$pincode'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List && data.isNotEmpty && data[0]['Status'] == 'Success') {
          final postOffice = data[0]['PostOffice'][0];
          final city = postOffice['District'] ?? '';
          final state = postOffice['State'] ?? '';

          setState(() {
            cityController.text = city;
            stateController.text = state;
            // Clear validation errors for auto-filled fields
            fieldErrors['pincode'] = false;
            fieldErrors['state'] = false;
            fieldErrors['city'] = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid Pincode or no data found'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            fieldErrors['pincode'] = true;
          });
        }
      } else {
        print('Server error fetching pincode data');
        setState(() {
          fieldErrors['pincode'] = true;
        });
      }
    } catch (e) {
      print('Error fetching pincode data: $e');
      setState(() {
        fieldErrors['pincode'] = true;
      });
    } finally {
      setState(() {
        _isFetchingPincode = false;
      });
    }
  }

  // Real-time validation when user types
  void _validateField(String fieldName, String value) {
    setState(() {
      switch (fieldName) {
        case 'fullName':
          fieldErrors['fullName'] = value.isEmpty;
          break;
        case 'phone':
          fieldErrors['phone'] = value.length != 10;
          break;
        case 'dateOfBirth':
          fieldErrors['dateOfBirth'] = value.isEmpty;
          break;
        case 'address':
          fieldErrors['address'] = value.isEmpty;
          break;
        case 'pincode':
          fieldErrors['pincode'] = value.length != 6;
          break;
      }
    });
  }

  // Validate auto-filled fields
  void _validateAutoFilledFields() {
    setState(() {
      fieldErrors['state'] = stateController.text.isEmpty;
      fieldErrors['city'] = cityController.text.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: Container(
                margin: EdgeInsets.all(8.r),
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
                  icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              title: Text(
                'Customer Registration',
                style: TextStyle(
                  fontSize: AppTheme.headerSize,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: false,
              floating: true,
              snap: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    _buildHeaderCard(),
                    SizedBox(height: 24.h),
                    
                    // Form Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Personal Details Section
                            _buildSectionTitle('Basic Information'),
                            SizedBox(height: 16.h),
                            
                            _buildPremiumTextField(
                              'Full Name*', 
                              Icons.person_outline, 
                              fullNameController,
                              hint: 'Enter customer full name',
                              isRequired: true,
                              hasError: fieldErrors['fullName']!,
                              onChanged: (value) => _validateField('fullName', value),
                            ),
                            SizedBox(height: 20.h),

                            _buildPremiumTextField(
                              'Phone*', 
                              Icons.phone_iphone, 
                              phoneController,
                              hint: '+91 9876543210', 
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              isRequired: true,
                              hasError: fieldErrors['phone']!,
                              onChanged: (value) => _validateField('phone', value),
                            ),
                            SizedBox(height: 20.h),

                            _buildPremiumTextField(
                              'Phone1', 
                              Icons.phone_iphone, 
                              phone1Controller,
                              hint: '+91 9876543210', 
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                            ),
                            SizedBox(height: 20.h),
                            
                            _buildPremiumTextField(
                              'Email', 
                              Icons.email_outlined, 
                              emailController,
                              hint: 'customer@example.com', 
                              keyboardType: TextInputType.emailAddress
                            ),
                            SizedBox(height: 20.h),
                            

                            /*
                            _buildPremiumTextField(
                              'PAN', 
                              Icons.credit_card, 
                              panController,
                              hint: 'ABCDE1234F', 
                              keyboardType: TextInputType.text, 
                              maxLength: 10
                            ),
                            SizedBox(height: 20.h),

                            _buildPremiumTextField(
                              'Aadhar', 
                              Icons.badge_outlined, 
                              adharController,
                              hint: '1234 5678 9012', 
                              keyboardType: TextInputType.number, 
                              maxLength: 12
                            ),
                            SizedBox(height: 20.h),
                            */
                            _buildPremiumTextField(
                              'Date of Birth*', 
                              Icons.cake_outlined, 
                              dateOfBirthController,
                              hint: 'DD/MM/YYYY', 
                              readOnly: true, 
                              onTap: _selectDate,
                              isRequired: true,
                              hasError: fieldErrors['dateOfBirth']!,
                              onChanged: (value) => _validateField('dateOfBirth', value),
                            ),
                            SizedBox(height: 20.h),
                            
                            _buildPremiumTextField(
                              'Address*',
                              Icons.location_on_outlined,
                              addressController,
                              hint: 'Enter full address',
                              isRequired: true,
                              hasError: fieldErrors['address']!,
                              maxLines: 3,
                              onChanged: (value) => _validateField('address', value),
                            ),
                            SizedBox(height: 20.h),
                            
                            // Pincode, State, City Section
                            _buildAddressDetailsSection(),
                            SizedBox(height: 20.h),
                            
                            // Submit Button
                            _buildPremiumButton(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, Color(0xFF006685)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_add_alt_1, color: Colors.white, size: 24.w),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Onboarding',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Start Your Journey With Us Today',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildPremiumTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    String hint = '',
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    bool readOnly = false,
    VoidCallback? onTap,
    Function(String)? onChanged,
    bool isRequired = false,
    bool hasError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Label with red star
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label.replaceAll('*', '').trim(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            if (isRequired) ...[
              SizedBox(width: 4.w),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 8.h),

        // 🔹 Text Field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            maxLength: maxLength,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: 14.sp,
              color: textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: cardColor,
              hintText: hint,
              hintStyle: TextStyle(
                color: const Color.fromARGB(255, 177, 170, 170),
                fontSize: 9.sp,
              ),
              counterText: '',
              prefixIcon: Container(
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1.5,
                    ),
                  ),
                ),
                child: Icon(
                  icon, 
                  color: hasError ? errorColor : primaryColor, 
                  size: 20.w
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: hasError ? errorColor : Colors.grey.shade200, 
                  width: 1.5
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: hasError ? errorColor : primaryColor, 
                  width: 2
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              errorText: hasError ? 'This field is required' : null,
              errorStyle: TextStyle(
                fontSize: 12.sp,
                color: errorColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Address Details',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(height: 16.h),

        // Pincode Field
        _buildPincodeField(),
        SizedBox(height: 20.h),

        // State Field
        _buildPremiumTextField(
          'State*', 
          Icons.map_outlined, 
          stateController,
          hint: 'State will auto-fill',
          readOnly: true,
          isRequired: true,
          hasError: fieldErrors['state']!,
        ),
        SizedBox(height: 20.h),

        // City Field
        _buildPremiumTextField(
          'City*', 
          Icons.location_city_outlined, 
          cityController,
          hint: 'City will auto-fill',
          readOnly: true,
          isRequired: true,
          hasError: fieldErrors['city']!,
        ),
      ],
    );
  }

  Widget _buildPincodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Pincode',
              style: TextStyle(
              //  fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '*',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              TextField(
                controller: pincodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (value) {
                  _validateField('pincode', value);
                  if (value.length == 6) {
                    _fetchLocationDetails(value);
                  } else {
                    setState(() {
                      stateController.clear();
                      cityController.clear();
                      _validateAutoFilledFields();
                    });
                  }
                },
                style: TextStyle(
                  fontSize: 14.sp,
                  color: textPrimary,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cardColor,
                  hintText: 'Enter 6-digit pincode',
                  hintStyle: TextStyle(
                    color: const Color.fromARGB(255, 187, 177, 177),
                    fontSize: 9.sp,
                  ),
                  counterText: '',
                  prefixIcon: Container(
                    margin: EdgeInsets.only(right: 12.w),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.pin_drop_outlined, 
                      color: fieldErrors['pincode']! ? errorColor : primaryColor, 
                      size: 20.w
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: fieldErrors['pincode']! ? errorColor : Colors.grey.shade200, 
                      width: 1.5
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: fieldErrors['pincode']! ? errorColor : primaryColor, 
                      width: 2
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  errorText: fieldErrors['pincode']! ? 'Please enter valid 6-digit pincode' : null,
                  errorStyle: TextStyle(
                    fontSize: 12.sp,
                    color: errorColor,
                  ),
                ),
              ),

              if (_isFetchingPincode)
                Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                ),
            ],
          ),
        ),

        if (_isFetchingPincode)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              "Fetching address details...",
              style: TextStyle(
                fontSize: 12.sp,
                color: primaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPremiumButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20.h,
                width: 30.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_alt_1, color: Colors.white, size: 18.w),
                  SizedBox(width: 8.w),
                  Text(
                    'CREATE CUSTOMER ACCOUNT',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String? formattedDobForApi;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;

        // UI display format (DD/MM/YYYY)
        dateOfBirthController.text =
            "${picked.day}/${picked.month}/${picked.year}";

        // Backend format (YYYY/MM/DD)
        formattedDobForApi =
            "${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}";

        // Clear validation error
        fieldErrors['dateOfBirth'] = false;
      });

      // 🔹 Debug prints
      print("Selected Date (UI): ${dateOfBirthController.text}");
      print("Formatted Date for API: $formattedDobForApi");
    }
  }

  bool _validateRequiredFields() {
    // Reset all errors first
    setState(() {
      fieldErrors = {
        'fullName': fullNameController.text.trim().isEmpty,
        'phone': phoneController.text.trim().length != 10,
        'dateOfBirth': dateOfBirthController.text.trim().isEmpty,
        'address': addressController.text.trim().isEmpty,
        'pincode': pincodeController.text.trim().length != 6,
        'state': stateController.text.trim().isEmpty,
        'city': cityController.text.trim().isEmpty,
      };
    });

    // Check if any field has error
    bool hasErrors = fieldErrors.values.any((error) => error);

    if (hasErrors) {
      _showSnack('Please fill all required fields correctly');
      
      // Scroll to first error field
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToFirstError();
      });
      
      return false;
    }

    return true;
  }

  void _scrollToFirstError() {
    // You can implement scroll to first error field here
    // For now, just show the snackbar
  }

  Future<void> _submitForm() async {
    if (!_validateRequiredFields()) return;

    String fullName = fullNameController.text.trim();
    String pan = panController.text.trim();
    String aadhar = adharController.text.trim();
    String email = emailController.text.trim();
    String phone = phoneController.text.trim();
    String address = addressController.text.trim();
    //String dateOfBirth = dateOfBirthController.text.trim();
    String pincode = pincodeController.text.trim();
    String state = stateController.text.trim();
    String city = cityController.text.trim();
    String phone1 = phone1Controller.text.trim();
    String area = areaController.text.trim();
    String landmark = landmarkController.text.trim();
    String builiding_no = addressController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      var response = await http.post(
        Uri.parse("${baseUrl}save_clients.php"),
        body: {
          'company_name': '',
          'name': fullName,
          'phone': phone,
          'email': email,
          'address': address,
          'dateofbirth': formattedDobForApi ?? '',
          'pin_code': pincode,
          'state': state,
          'city': city,
          'pan': pan,
          "aadhar": aadhar,
          'builiding_no':  builiding_no,
          'phone1': phone1,
          'area': area,
          'landmark': landmark,
          'shopname': builiding_no,
          'token': token
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print("API Response: $jsonResponse");

        dynamic successValue = jsonResponse["success"];
        bool isSuccess = successValue == true ||
            successValue == "true" ||
            successValue == 1 ||
            successValue == "1" ||
            jsonResponse["status"] == "success";

        String message = jsonResponse["message"] ?? "Operation completed.";

        if (isSuccess) {
          _showSnack(message, success: true);

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("userMobile", phone);
          await prefs.setString("fullName", fullName);

          await Future.delayed(Duration(seconds: 1));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => OtpScreen()),
          );
        } else {
          _showSnack(message, success: false);
        }
      } else {
        _showSnack("Server error! Please try again later.", success: false);
      }
    } catch (e) {
      print("Error: $e");
      _showSnack("No internet connection or server error.", success: false);
    } finally {
      setState(() {
        _isLoading = false;
      });
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
}