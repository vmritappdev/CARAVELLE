import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class EditCompanyScreen extends StatefulWidget {
  const EditCompanyScreen({super.key});

  @override
  State<EditCompanyScreen> createState() => _EditCompanyScreenState();
}

class _EditCompanyScreenState extends State<EditCompanyScreen> {
  // Controllers
  TextEditingController companyNameController = TextEditingController();
  TextEditingController contactPersonController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController shopNameController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();

  // Dropdown values
  String? selectedState;
  String? selectedDistrict;

  final List<String> states = ['Telangana', 'Andhra Pradesh', 'Karnataka'];
  final Map<String, List<String>> districts = {
    'Telangana': ['Hyderabad', 'Ranga Reddy', 'Warangal'],
    'Andhra Pradesh': ['Vijayawada', 'Guntur', 'Visakhapatnam'],
    'Karnataka': ['Bangalore', 'Mysore', 'Mangalore'],
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Edit Company",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.teal.shade600,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.w,color: Colors.white,),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              SizedBox(height: 24.h),
              
              // Form Fields
              _buildCompactTextField("Company Name", Icons.business_rounded, companyNameController),
              _buildCompactTextField("Contact Person", Icons.person_rounded, contactPersonController),
              _buildCompactTextField("Mobile", Icons.phone_rounded, mobileController, 
                  keyboardType: TextInputType.phone, maxLength: 10),
              _buildCompactTextField("Pincode", Icons.location_on_rounded, pincodeController, 
                  keyboardType: TextInputType.number, maxLength: 6),
              
              _buildCompactDropdown("State", Icons.map_rounded, states, selectedState, (val) {
                setState(() {
                  selectedState = val;
                  selectedDistrict = null;
                });
              }),
              
              _buildCompactDropdown(
                "District", 
                Icons.location_city_rounded,
                selectedState != null ? districts[selectedState!]! : [],
                selectedDistrict,
                (val) => setState(() => selectedDistrict = val),
              ),
              
              _buildCompactTextField("City", Icons.location_city_rounded, cityController),
              _buildCompactTextField("Shop Name", Icons.store_rounded, shopNameController),
              _buildCompactTextField("Area", Icons.place_rounded, areaController),
              _buildCompactTextField("Landmark", Icons.flag_rounded, landmarkController),
              
              SizedBox(height: 32.h),
              
              // Save Button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: Colors.teal.shade600,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          "Company Information",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

 Widget _buildCompactTextField(
  String label,
  IconData icon,
  TextEditingController controller, {
  TextInputType keyboardType = TextInputType.text,
  int? maxLength,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: 16.h),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: GoogleFonts.poppins(fontSize: 14.sp),
      decoration: InputDecoration(
        counterText: "",
        labelText: label,
        prefixIcon: Icon(icon, size: 20.w, color: Colors.teal.shade600),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: const Color.fromARGB(255, 224, 222, 222), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
        ),
      ),
    ),
  );
}


  Widget _buildCompactDropdown(String label, IconData icon, List<String> items, String? selectedItem, ValueChanged<String?> onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: DropdownButtonFormField<String>(
        value: selectedItem,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20.w, color: Colors.teal.shade600),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
         enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: const Color.fromARGB(255, 224, 222, 222), width: 1.5),
        ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.teal.shade600, width: 1.5),
          ),
        ),
        style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87),
        hint: Text("Select $label", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey.shade500)),
        isExpanded: true,
        onChanged: onChanged,
        items: items.map((e) => DropdownMenuItem(
          value: e,
          child: Text(e, style: GoogleFonts.poppins(fontSize: 14.sp)),
        )).toList(),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _saveCompanyDetails,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
          shadowColor: Colors.teal.shade200,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_rounded, size: 20.w, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
              "Save Details",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCompanyDetails() {
    // Save logic, validation, API call etc.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Company details saved successfully!", style: GoogleFonts.poppins()),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }
}