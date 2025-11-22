import 'dart:async';
import 'dart:convert';

import 'package:caravelle/caravelle_home_screen_naves/catalog.dart';
import 'package:caravelle/caravelle_home_screen_naves/newarravel_section.dart';
import 'package:caravelle/dashboard_naves/accountscreen.dart';
import 'package:caravelle/dashboard_naves/18k_14k_categires.dart';
import 'package:caravelle/caravelle_home_screen_naves/customexclsivedesgin.dart';

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
  fetchNewArrivals();
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



Future<void> fetchProducts(String type) async {
  final url = Uri.parse('${baseUrl}product_display.php');

  try {
    // 👇 Prepare the body data
    final body = {
      'type': type,
      'token': token,
    };

    print("🌐 API URL: $url");
    print("📦 Request Body: $body");

    final response = await http.post(url, body: body);

    if (response.statusCode == 200) {
      print("✅ API Success for type: $type");
      print("🔗 Full Request URL: ${url.toString()}");
      print("🧾 Response: ${response.body}");
    } else {
      print("❌ API Error: ${response.statusCode}");
      print("❌ URL: ${url.toString()}");
    }
  } catch (e) {
    print("⚠️ Exception: $e");
    print("❗ Error calling: ${url.toString()}");
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


Future<List<dynamic>> fetchNewArrivals() async {
  final url = Uri.parse("${baseUrl}new_arrival.php");

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'token': token}, // ✅ token body lo pass chestunnam
    );

    if (response.statusCode == 200) {
      print("✅ API Response: ${response.body}");

      final data = json.decode(response.body);

      if (data is List) {
        print("✅ Total items fetched: ${data.length}");
        for (var item in data) {
          print("🖼️ Image URL: ${item['image_url']}");
        }
        return data;
      } else {
        print("⚠️ Unexpected response format: ${data.runtimeType}");
        return [];
      }
    } else {
      print("❌ API Error: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    print("❌ Exception: $e");
    return [];
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
                                Icon(Icons.star, color: Colors.amber, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Ready To Stock',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                   // letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.star, color: Colors.amber, size: 20),
                              ],
                            ),
                          ),
            
                          SizedBox(height: 10.h),

                          
         Container(
  margin: EdgeInsets.symmetric(horizontal: 19.w, vertical: 14.h),
  padding: EdgeInsets.all(12.w), // 🔹 Slightly reduced padding
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [
        AppTheme.primaryColor,
        Color(0xFF00B3B3),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.circular(18.r),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF008080).withOpacity(0.15),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Row(
        children: [
          Expanded(child: _goldBox("CZ Jewellery", "cz")),
          SizedBox(width: 8.w),
          Expanded(child: _goldBox("Lab Diamonds", "diamond")),
        ],
      ),
      SizedBox(height: 8.h),

      
      Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 140.w, // 🔹 Reduced width for center box
          child: _goldBox("Plain Jewellery", "plain"),
        ),
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
                                  "✨Custom Orders",
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
                                  
                                  ],
                                ),
                                SizedBox(height: 12.h),
                             NewArrivalSection(),
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
  style: TextStyle(
    color: Colors.white,
    fontSize: 20.sp, // Slightly bigger for logo feel
    fontWeight: FontWeight.w800, // Extra bold
    letterSpacing: 2.5, // Spaced for luxury branding
   // fontStyle: FontStyle.italic, // Stylish slant
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

Widget _goldBox(String title, String type) {
  return GestureDetector(
   onTap: () async {
      await fetchProducts(type);

      // ✅ Navigate to next screen after API call success
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductCategoriesScreen(type: type,),
        ),
      );
    },
    child: Container(
      height: 40.h, // 🔹 Reduced height (was 90.h)
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19.r), // 🔹 Slightly smaller corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 14.sp, 
             fontFamily: "Inter",   // 🔹 Reduced font size
          fontWeight: FontWeight.bold,
        ),
      ),
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
