

import 'package:caravelle/screens/business2.dart';

import 'package:caravelle/screens/custmer2.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectionScreen extends StatelessWidget {
  final Color primaryGold = const Color(0xFFD4AF37);
  final Color darkBlue = const Color(0xFF0A2463);
  final Color mediumGray = const Color(0xFF6C757D);
  final Color darkGray = const Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 20.0.r, vertical: 16.0.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               SizedBox(height: 20.h),

              /// LOGO + BRAND NAME
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

               SizedBox(height: 30.h),

              /// SUBTITLE LINE
             

               SizedBox(height: 24.h),

              /// INSTRUCTION
              Container(
                width: double.infinity,
                child: Text(
                  'Select your role to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppTheme.subHeaderSize,
                    color:AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              SizedBox(height: 50.h),

              /// BUSINESS OPTION
              _buildEnhancedOptionCard(
                title: 'Business',
                subtitle: 'Jewellery Store Owner / Wholesaler',
                icon: Icons.store_rounded,
                backgroundColor: darkBlue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BusinessForm()),
                ),
              ),

              SizedBox(height: 20.h),

              /// CUSTOMER OPTION
              _buildEnhancedOptionCard(
                title: 'Customer',
                subtitle: 'Buy Jewellery & Diamond Products',
                icon: Icons.person_rounded,
                backgroundColor: primaryGold,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerForm()),
                ),
              ),

              const Spacer(),

              /// FOOTER
              Center(
                child: Column(
                  children: [
                    Container(
                        height: 1.h,
                        width: 120.w,
                        color: mediumGray.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'Experience the finest jewellery',
                      style: TextStyle(
                        fontSize: AppTheme.subHeaderSize,
                        color: mediumGray,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),

               SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              Color.alphaBlend(
                Colors.black.withOpacity(0.1),
                backgroundColor,
              ),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20.r,
              top: -20.r,
              child: Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Row(
              children: [
                 SizedBox(width: 24.w),
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: backgroundColor, size: AppTheme.headerSize),
                ),
                 SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:  TextStyle(
                          fontSize: AppTheme.subHeaderSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                       SizedBox(height: 6.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: AppTheme.fontSize,
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.only(right: 24.r),
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child:  Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: AppTheme.subHeaderSize,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
