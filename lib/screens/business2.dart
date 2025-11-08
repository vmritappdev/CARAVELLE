import 'package:caravelle/screens/otpscreen.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BusinessForm extends StatefulWidget {
  @override
  _BusinessFormState createState() => _BusinessFormState();
}

class _BusinessFormState extends State<BusinessForm> {
  final Color primaryColor = Color(0xFF0094B0);
  final Color accentColor = Color(0xFFFF6B35);
  final Color backgroundColor = Color(0xFFF8F9FA);
  final Color cardColor = Colors.white;
  final Color textPrimary = Color(0xFF2D3748);
  final Color textSecondary = Color(0xFF718096);
  final Color errorColor = Color(0xFFD32F2F);
  
  TextEditingController companyNameController = TextEditingController();
  TextEditingController NameController = TextEditingController();
  TextEditingController shopNameController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController mobileNumberController1 = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController panController = TextEditingController();
  TextEditingController gstController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController adharController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  bool _isLoading = false;
  bool _isFetchingPincode = false;

  String? selectedState;
  String? selectedDistrict;
  String? selectedCity;

  List<String> states = [];
  List<String> districts = [];
  List<String> cities = [];

  // Validation flags
  Map<String, bool> fieldErrors = {
    'companyName': false,
    'personName': false,
    'mobile': false,
    'gst': false,
    'area': false,
    'pincode': false,
    'state': false,
    'city': false,
  };

  @override
  void initState() {
    super.initState();
    pinCodeController.addListener(_onPincodeChanged);
  }

  void _onPincodeChanged() {
    String pincode = pinCodeController.text.trim();

    if (pincode.length == 6) {
      setState(() {
        _isFetchingPincode = true;
      });
      getPincodeDetails(pincode).then((_) {
        setState(() {
          _isFetchingPincode = false;
        });
      });
    } else {
      setState(() {
        selectedState = null;
        selectedDistrict = null;
        selectedCity = null;
        states.clear();
        districts.clear();
        cities.clear();
        // Clear validation error when pincode is being edited
        fieldErrors['pincode'] = false;
      });
    }
  }

  Future<void> getPincodeDetails(String pincode) async {
    final url = 'https://api.postalpincode.in/pincode/$pincode';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data[0]['Status'] == 'Success') {
          final offices = data[0]['PostOffice'] as List;

          String state = offices[0]['State'].toString().toUpperCase();
          String district = offices[0]['District'].toString().toUpperCase();
          List<String> cityList = offices.map((o) => o['Name'].toString()).toList();

          setState(() {
            states = [state];
            districts = [district];
            cities = cityList;

            selectedState = state;
            selectedDistrict = district;
            selectedCity = cityList.isNotEmpty ? cityList[0] : null;

            stateController.text = state;
            districtController.text = district;
            cityController.text = selectedCity ?? "";
            countryController.text = "INDIA";
            
            // Clear validation errors for auto-filled fields
            fieldErrors['state'] = false;
            fieldErrors['city'] = false;
            fieldErrors['pincode'] = false;
          });
        } else {
          _clearPincodeFields();
          _showSnack('Invalid pincode entered.');
          setState(() {
            fieldErrors['pincode'] = true;
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      _clearPincodeFields();
      _showSnack('No internet connection. Please try again.');
      setState(() {
        fieldErrors['pincode'] = true;
      });
    }
  }

  void _clearPincodeFields() {
    setState(() {
      states.clear();
      districts.clear();
      cities.clear();
      selectedState = null;
      selectedDistrict = null;
      selectedCity = null;
      stateController.clear();
      districtController.clear();
      cityController.clear();
      countryController.clear();
    });
  }

  // Real-time validation when user types
  void _validateField(String fieldName, String value) {
    setState(() {
      switch (fieldName) {
        case 'companyName':
          fieldErrors['companyName'] = value.isEmpty;
          break;
        case 'personName':
          fieldErrors['personName'] = value.isEmpty;
          break;
        case 'mobile':
          fieldErrors['mobile'] = value.length != 10;
          break;
        case 'gst':
          fieldErrors['gst'] = value.isEmpty;
          break;
        case 'area':
          fieldErrors['area'] = value.isEmpty;
          break;
        case 'pincode':
          fieldErrors['pincode'] = value.length != 6;
          break;
      }
    });
  }

  // Validate dropdown fields
  void _validateDropdown(String fieldName, String? value) {
    setState(() {
      switch (fieldName) {
        case 'state':
          fieldErrors['state'] = value == null || value.isEmpty;
          break;
        case 'city':
          fieldErrors['city'] = value == null || value.isEmpty;
          break;
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_validateRequiredFields()) return;

    String companyName = companyNameController.text.trim();
    String name = NameController.text.trim();
    String phone = mobileNumberController.text.trim();
    String pinCode = pinCodeController.text.trim();
    String state = selectedState ?? '';
    String district = selectedDistrict ?? '';
    String city = selectedCity ?? '';
    String buildingNo = shopNameController.text.trim();
    String area = areaController.text.trim();
    String landmark = landmarkController.text.trim();
    String pan = panController.text.trim();
    String aadhar = adharController.text.trim();
    String gst = gstController.text.trim();
    String builiding_no = shopNameController.text.trim();
    String phone1 = mobileNumberController1.text.trim();
    String email = emailController.text.trim();
    String dateOfBirth = '';
    String address = '${area}, ${landmark}, ${city}, ${district}, ${state}, ${pinCode}';

    setState(() {
      _isLoading = true;
    });

    try {
      var response = await http.post(
        Uri.parse("${baseUrl}save_clients.php"),
        body: {
          'company_name': companyName,
          'name': name,
          'phone': phone,
          'pin_code': pinCode,
          'state': state,
          'district': district,
          'city': city,
          'builiding_no': buildingNo,
          'area': area,
          'pan': pan,
          'aadhar': aadhar,
          'landmark': landmark,
          'email': email,
          'phone1': phone1,
          'dateofbirth': dateOfBirth,
          'address': address,
          'gst': gst,
          'shopname': builiding_no,
          'token': token
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == "success" || jsonResponse['success'] == true) {
          _showSnack(jsonResponse['message'] ?? "Company details saved successfully", success: true);

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("userMobile", phone);
          await prefs.setString("companyName", companyName);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => OtpScreen()),
          );
        } else {
          _showSnack(jsonResponse['message'] ?? "Failed to save details. Please try again.");
        }
      } else {
        _showSnack("Server error! Please try again later.");
      }
    } catch (e) {
      _showSnack("No internet connection or server down.");
      print("Error: $e");
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  bool _validateRequiredFields() {
    // Reset all errors first
    setState(() {
      fieldErrors = {
        'companyName': companyNameController.text.trim().isEmpty,
        'personName': NameController.text.trim().isEmpty,
        'mobile': mobileNumberController.text.trim().length != 10,
        'gst': gstController.text.trim().isEmpty,
        'area': areaController.text.trim().isEmpty,
        'pincode': pinCodeController.text.trim().length != 6,
        'state': selectedState == null || selectedState!.isEmpty,
        'city': selectedCity == null || selectedCity!.isEmpty,
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
                'Company Details',
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
                            // Company Name
                            _buildPremiumTextField(
                              'Company Name*', 
                              Icons.business, 
                              companyNameController,
                              isRequired: true,
                              hasError: fieldErrors['companyName']!,
                              onChanged: (value) => _validateField('companyName', value),
                            ),
                            SizedBox(height: 20.h),

                            _buildPremiumTextField(
                              'Authorised Person Name*', 
                              Icons.person, 
                              NameController, 
                              isRequired: true,
                              hasError: fieldErrors['personName']!,
                              onChanged: (value) => _validateField('personName', value),
                            ),
                            SizedBox(height: 20.h),

                            // Mobile Number - Required Field
                            _buildPremiumTextField(
                              'Phone*', 
                              Icons.phone, 
                              mobileNumberController, 
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              isRequired: true,
                              hasError: fieldErrors['mobile']!,
                              onChanged: (value) => _validateField('mobile', value),
                            ),
                            SizedBox(height: 20.h),

                            _buildPremiumTextField(
                              'Phone1', 
                              Icons.phone, 
                              mobileNumberController1, 
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

                            _buildPremiumTextField(
                              'Pan', 
                              Icons.credit_card, 
                              panController, 
                              keyboardType: TextInputType.numberWithOptions(),
                              maxLength: 10,
                            ),
                            SizedBox(height: 20.h),

                            _buildPremiumTextField(
                              'Aadhar', 
                              Icons.credit_card, 
                              adharController, 
                              keyboardType: TextInputType.numberWithOptions(),
                              maxLength: 12,
                            ),
                            SizedBox(height: 20.h),

                            _buildPremiumTextField(
                              'Gst No*', 
                              Icons.verified_user, 
                              gstController, 
                              keyboardType: TextInputType.numberWithOptions(),
                              maxLength: 10,
                              isRequired: true,
                              hasError: fieldErrors['gst']!,
                              onChanged: (value) => _validateField('gst', value),
                            ),
                            SizedBox(height: 20.h),

                           
                            // 🏠 Address Field (single clean input)
_buildPremiumTextField(
  'Address*',
  Icons.location_on_outlined,
  addressController,
  isRequired: true,
  hasError: fieldErrors['address'] ?? false, // ✅ safe null check
  onChanged: (value) => _validateField('address', value),
  maxLines: 3, // allows multiline input for full address
),
SizedBox(height: 20.h),

                            
                            // Pin Code with auto-fetch
                            _buildPincodeField(),
                            SizedBox(height: 20.h),
                            
                            // Select State Dropdown
                            _buildPremiumDropdown(
                              'Select State*', 
                              Icons.location_on, 
                              selectedState, 
                              states, 
                              (value) {
                                setState(() {
                                  selectedState = value;
                                });
                                _validateDropdown('state', value);
                              },
                              isLoading: _isFetchingPincode,
                              hasError: fieldErrors['state']!,
                            ),
                            SizedBox(height: 20.h),
                            
                            // Select City Dropdown
                            _buildPremiumDropdown(
                              'Select City*', 
                              Icons.location_city, 
                              selectedCity, 
                              cities, 
                              (value) {
                                setState(() {
                                  selectedCity = value;
                                });
                                _validateDropdown('city', value);
                              },
                              isLoading: _isFetchingPincode,
                              hasError: fieldErrors['city']!,
                            ),
                            SizedBox(height: 32.h),
                            
                            // Next Button
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

  Widget _buildPincodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Pin Code',
              style: TextStyle(
                fontSize: AppTheme.subHeaderSize,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '*',
              style: TextStyle(
                fontSize: AppTheme.subHeaderSize,
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
                controller: pinCodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (value) {
                  _validateField('pincode', value);
                  if (value.length == 6) {
                    _onPincodeChanged();
                  } else {
                    setState(() {
                      stateController.clear();
                      cityController.clear();
                    });
                  }
                },
                style: TextStyle(
                  fontSize: AppTheme.fontSize,
                  color: textPrimary,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cardColor,
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
                    child: Icon(Icons.pin, color: fieldErrors['pincode']! ? errorColor : primaryColor, size: 20.w),
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  counterText: "",
                  hintText: "Enter 6-digit pincode",
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.grey.shade500,
                  ),
                  errorText: fieldErrors['pincode']! ? 'Please enter valid 6-digit pincode' : null,
                  errorStyle: TextStyle(
                    fontSize: AppTheme.fontSize - 2,
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
                fontSize: AppTheme.fontSize,
                color: primaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
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
            child: Icon(Icons.business_center, color: Colors.white, size: 24.w),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register Your Company',
                  style: TextStyle(
                    fontSize: AppTheme.subHeaderSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Complete your company details to get started',
                  style: TextStyle(
                    fontSize: AppTheme.fontSize,
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

  Widget _buildPremiumTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String hint = '',
    int? maxLength,
    Function(String)? onChanged,
    bool isRequired = false,
    bool hasError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label.replaceAll('*', '').trim(),
              style: TextStyle(
                fontSize: AppTheme.subHeaderSize,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            if (isRequired) ...[
              SizedBox(width: 4.w),
              Text(
                '*',
                style: TextStyle(
                  fontSize: AppTheme.subHeaderSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
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
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            maxLength: maxLength,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: AppTheme.subHeaderSize,
              color: textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: AppTheme.subHeaderSize - 2,
              ),
              counterText: '',
              filled: true,
              fillColor: cardColor,
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
                child: Icon(icon, color: hasError ? errorColor : primaryColor, size: 20.w),
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              errorText: hasError ? 'This field is required' : null,
              errorStyle: TextStyle(
                fontSize: AppTheme.fontSize - 2,
                color: errorColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumDropdown(
    String label,
    IconData icon,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    bool isLoading = false,
    bool hasError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label.replaceAll('*', '').trim(),
              style: TextStyle(
                fontSize: AppTheme.subHeaderSize,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '*',
              style: TextStyle(
                fontSize: AppTheme.subHeaderSize,
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
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError ? errorColor : (value == null ? Colors.grey.shade200 : primaryColor),
                width: hasError ? 2 : (value == null ? 1.5 : 2),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  icon: isLoading 
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        )
                      : Icon(Icons.arrow_drop_down, color: hasError ? errorColor : primaryColor, size: 24.w),
                  hint: Row(
                    children: [
                      Icon(icon, color: hasError ? errorColor : AppTheme.primaryColor, size: 20.w),
                      SizedBox(width: 12.w),
                      Text(
                        isLoading ? "Loading..." : label,
                        style: TextStyle(
                          fontSize: AppTheme.subHeaderSize,
                          fontWeight: FontWeight.w300,
                          color: hasError ? errorColor : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  items: items.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: AppTheme.fontSize,
                          color: textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: isLoading ? null : onChanged,
                ),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              'This field is required',
              style: TextStyle(
                fontSize: AppTheme.fontSize - 2,
                color: errorColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPremiumButton() {
    return Container(
      width: double.infinity,
      height: 51.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
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
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NEXT',
                    style: TextStyle(
                      fontSize: AppTheme.headerSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20.w),
                ],
              ),
      ),
    );
  }
}