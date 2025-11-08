import 'dart:async';
import 'dart:convert';

import 'package:caravelle/caravelle_home_screen_naves/catalog.dart';
import 'package:caravelle/dashboard_naves/accountscreen.dart';
import 'package:caravelle/dashboard_naves/18k_14k_categires.dart';
import 'package:caravelle/caravelle_home_screen_naves/customexclsivedesgin.dart';
import 'package:caravelle/dashboard_naves/goldshop_offer.dart';
import 'package:caravelle/caravelle_home_screen_naves/exclsive_screen.dart';
import 'package:caravelle/caravelle_home_screen_naves/follow_us_screen.dart';
import 'package:caravelle/screens/caravelle_home2.dart';

import 'package:caravelle/screens/custmaization_screen.dart';
import 'package:caravelle/caravelle_home_screen_naves/goldrate_validatiy.dart';

import 'package:caravelle/screens/search_screen.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:caravelle/uittility/conasthan_api.dart' as Utility;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CaravelleHomeScreen extends StatefulWidget {
  const CaravelleHomeScreen({super.key});

  @override
  State<CaravelleHomeScreen> createState() => _CaravelleHomeScreenState();
}

class _CaravelleHomeScreenState extends State<CaravelleHomeScreen> {
  int activeIndex = 0;

   List<String> images = [];
   bool isLoading = true;
  



bool _hasInitialized = false; // ✅ Runs only once

@override
void initState() {
  super.initState();
  fetchImages();
  _checkValidityOnce();
}

Future<void> _checkValidityOnce() async {
  // Prevent multiple calls
  if (_hasInitialized) return;
  _hasInitialized = true;

  // Wait a bit before checking
  await Future.delayed(const Duration(milliseconds: 100));

  // Fetch validity status
  final isValid = await Utility.fetchValidityStatus();

  // Check if widget is still active
  if (!mounted) return;

  // Navigate accordingly
  if (!isValid) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CaravelleHomeScreen2()),
    );
  }
}


// ✅ Load mobile number and then call validity API


Future<void> fetchImages() async {
  print('fetchImages called');

  try {
    final response = await http.post(
      Uri.parse('${baseUrl}scrolling_images.php'),
      body: {"token": token},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (!mounted) return; // 🔒 Prevent setState after dispose

      setState(() {
        images = data['data'] != null
            ? List<String>.from(
                data['data'].map((item) => '${item['image_url']}'),
              )
            : [];
        isLoading = false;
      });

      print('Fetched images: $images');
    } else {
      if (!mounted) return;
      setState(() => isLoading = false);
      print('Failed to load images: ${response.statusCode}');
    }
  } catch (e) {
    if (!mounted) return;
    setState(() => isLoading = false);
    print('Error in fetchImages: $e');
  }
}


  @override
  Widget build(BuildContext context) {
  

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppTheme.primaryColor,
      statusBarIconBrightness: Brightness.light,
    ));

    return ScreenUtilInit(
       useInheritedMediaQuery: true,
      designSize: const Size(390, 844),
      builder: (context, child) {
        return SafeArea(
          
            child: Scaffold(
              backgroundColor: const Color(0xFFF5F7FA),
              body: Stack(
                children: [
                  // ================= Scrollable Body =================
                  Padding(
                    padding: EdgeInsets.only(top: 50.h), // space for fixed header
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [


                         
                         GoldRateValidityWidget(),
            
            
                         
                        Stack(
  children: [
 
    isLoading
        ? Center(child: CircularProgressIndicator())
        : CarouselSlider.builder(
            itemCount: images.length,
            options: CarouselOptions(
              height: 400.h, // fixed height
              viewportFraction: 1.0,
              autoPlay: true,
              onPageChanged: (index, reason) =>
                  setState(() => activeIndex = index),
            ),
            itemBuilder: (context, index, realIndex) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Image.network(
                  images[index], // network URL
                  fit: BoxFit.cover,
                  width: double.infinity, // do not use .w with infinity
                  height: 400.h,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        'Image not available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  },
                ),
              );
            },
          ),

    // Carousel indicator
    Positioned(
      bottom: 30.h,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedSmoothIndicator(
          activeIndex: activeIndex,
          count: images.isNotEmpty ? images.length : 1,
          effect: WormEffect(
            dotHeight: 8.h,
            dotWidth: 8.w,
            activeDotColor: Colors.amber,
            dotColor: Colors.grey,
          ),
        ),
      ),
    ),

    // Overlay Text
    Positioned(
      bottom: 60.h,
      left: 20.w,
      child: Text(
        "Timeless Radiance",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // Shop Now Button
    Positioned(
      bottom: 50.h,
      right: 20.w,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        ),
        child: const Text(
          "Shop Now",
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),
  ],
)
,
                        //  SizedBox(height: 10.h),
            
                          // ---------------- Exclusive Collection ----------------
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            color: AppTheme.primaryColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star, color: AppTheme.primaryColor, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Ready To Stock',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.star, color: Colors.amber, size: 20),
                              ],
                            ),
                          ),
            
                          SizedBox(height: 10.h),

                          
            
                          // ---------------- Gold Boxes ----------------
                     Container(
  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [
       // Color(0xFF006D6D), // Dark Teal
        AppTheme.primaryColor,
        Color(0xFF00B3B3), // Light Teal
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.circular(20.r),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF008080).withOpacity(0.15),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: _goldBox("CZ Jewellery"),
      ),
      SizedBox(width: 10.w),
      Expanded(
        child: _goldBox("Lab Diamonds"),
      ),
    ],
  ),
),
            
                          // ---------------- Exclusive Designs Grid ----------------
                         ExclusiveDesignsSection(),
            
                          SizedBox(height: 20.h),
            
                          // ---------------- Custom Orders ----------------
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [


                                CustomDesignWidget(),

                                 SizedBox(height: 20.h),


                                Text(
                                  "Custom Orders",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: const DecorationImage(
                                      image: AssetImage('assets/images/d.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.black.withOpacity(0.35),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Design Your Dream Jewelry',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => CustomizationScreen(),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.primaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 10,
                                              ),
                                            ),
                                            child: const Text(
                                              'START CUSTOMIZATION',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
            
                          // ---------------- New Arrival ----------------
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "New Arrival Design",
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                     Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade600, Colors.teal.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoldShopOffersScreen(subProducts: ''),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Row(
                    children: [
                      Text(
                        "View All",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _customImageCard("assets/images/cara3.png", "Necklace"),
                                      _customImageCard("assets/images/cara4.png", "Ring"),
                                      _customImageCard("assets/images/cara9.png", "Bracelet"),
                                      _customImageCard("assets/images/cara2.png", "Earrings"),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 26.h),

                           ProductGalleryWidget(),


                               SizedBox(height: 26.h),


                                FollowUsSection(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            
                  // ================= Fixed Header =================
                  Container(
                    height: 50.h,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.primaryColor],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AccountScreen()));
                          },
                          child: Container(
                            width: 36.w,
                            height: 36.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF42A5F5), Colors.pink],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "S",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                         Text(
  "CARAVELLE",
  style: GoogleFonts.montserrat(
    color: Colors.white,
    fontSize: 26.sp, // Slightly bigger for logo feel
    fontWeight: FontWeight.w800, // Extra bold
    letterSpacing: 2.5, // Spaced for luxury branding
    fontStyle: FontStyle.italic, // Stylish slant
    shadows: [
      Shadow(
        color: Colors.black26, // soft shadow for depth
        offset: Offset(1, 1),
        blurRadius: 4,
      ),
    ],
  ),
),



                           Text(
  'Gold | CZ | Lab Diamonds',
  style: TextStyle(
    fontSize: 11.sp,
    fontStyle: FontStyle.italic,
   // fontWeight: FontWeight.bold,
    color:  Colors.amber,
  ),
),
                          ],
                        ),
            
                        GestureDetector(
                           onTap: () {
                    // Search screen ki navigate avtundi
                    Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
                    );
                  },
                          child: const 
                        Icon(Icons.search, color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
        );
      },
    );
  }

 Widget _goldBox(String title) {
  return Container(
    // Remove fixed width: 190.w
    height: 90.h,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductCategoriesScreen()));
          },
          child: Text(
            title,
            textAlign: TextAlign.center, // ← Add this
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductCategoriesScreen()));
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: const Text(
              "View All Stock",
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
        ),
      ],
    ),
  );
}

 

  Widget _customImageCard(String imagePath, String label) {
    return Container(
      margin: EdgeInsets.only(right: 12.w),
      child: Column(
        children: [
          Container(
            height: 100.h,
            width: 100.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.r),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: images.length,
        axisDirection: Axis.horizontal,
        effect: const CustomizableEffect(
          activeDotDecoration: DotDecoration(
            width: 25,
            height: 6,
            color: Colors.amber,
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          dotDecoration: DotDecoration(
            width: 25,
            height: 6,
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          spacing: 6.0,
        ),
      );
}
