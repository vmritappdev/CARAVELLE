import 'dart:async';
import 'dart:convert';
import 'package:caravelle/caravelle_home_screen_naves/follow_us_screen.dart';
import 'package:caravelle/dashboard_naves/accountscreen.dart';

import 'package:caravelle/caravelle_home_screen_naves/noacess_view_all.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CaravelleHomeScreen2 extends StatefulWidget {
  const CaravelleHomeScreen2({super.key});

  @override
  State<CaravelleHomeScreen2> createState() => _CaravelleHomeScreen2State();
}

class _CaravelleHomeScreen2State extends State<CaravelleHomeScreen2> {
  int activeIndex = 0;
  List<String> images = [];
  bool isLoading = true;
  String? goldRate;
String? _apiMessage; 
 
  Future<void> fetchGoldRate() async {
    final url = '${baseUrl}gold_rate_display.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'token': token},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response'] == 'success' &&
            data['data'] != null &&
            data['data'].isNotEmpty) {
          final rate = data['data'][0]['gold_rate']?.toString() ?? "0.00";
          setState(() {
            goldRate = rate;
          });
        }
      }
    } catch (e) {
      print('⚠️ Gold Rate Exception: $e');
    }
  }

  Future<void> fetchImages() async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}scrolling_images.php'),
        body: {"token": token},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;

        setState(() {
          images = data['data'] != null
              ? List<String>.from(
                  data['data'].map((item) => '${item['image_url']}'),
                )
              : [];
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      print('❌ Error in fetchImages: $e');
    }
  }


  Future<void> fetchExtendRequest() async {
  final url = Uri.parse('${baseUrl}extend_request.php');

  try {
    print("🔹 API CALL STARTED: Extend Request");
    print("🌐 URL: $url");

    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('mobile_number') ?? '';

    if (phone.isEmpty) {
      print("⚠️ No phone number found in SharedPreferences!");
      return;
    }

    print("📦 BODY: { token: $token, phone: $phone }");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'token': token,
        'phone': phone,
      },
    );

    print("📩 STATUS CODE: ${response.statusCode}");
    print("📜 RAW RESPONSE: ${response.body}");

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("✅ DECODED DATA: $data");

      if (data is Map<String, dynamic>) {
        setState(() {
          _apiMessage = data['message']?.toString(); // 🟢 Save message
        });

        print("🟢 STATUS: ${data['status']}");
        print("💬 MESSAGE: $_apiMessage");
      }
    } else {
      print("❌ API FAILED with Status Code: ${response.statusCode}");
    }
  } catch (e) {
    print("🔥 ERROR while calling API: $e");
  }
}

Future<void> fetchExtendRequestButton(BuildContext context) async {
  final url = Uri.parse('https://caravelle.in/barcode/app/extend_request_button.php');

  try {
    print("🔹 API CALL STARTED: Extend Request Button");
    print("🌐 URL: $url");

    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('mobile_number') ?? '';

    if (phone.isEmpty) {
      print("⚠️ No phone number found in SharedPreferences!");
      return;
    }

    print("📦 BODY: { token: $token, phone: $phone }");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'token': token,
        'phone': phone,
      },
    );

    print("📩 STATUS CODE: ${response.statusCode}");
    print("📜 RAW RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("✅ DECODED DATA: $data");

      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? '';
        final status = data['status'] ?? '';

        print("🟢 STATUS: $status");
        print("💬 MESSAGE: $message");

        if (mounted) {
          setState(() {
            _apiMessage = message; // ✅ message set చెయ్యడం వల్ల button hide అవుతుంది
          });
        }
      }
    } else {
      print("❌ API FAILED with Status Code: ${response.statusCode}");
    }
  } catch (e) {
    print("🔥 ERROR while calling API: $e");
  }
}



  @override
  void initState() {
    super.initState();
    fetchImages();
    fetchGoldRate();
    fetchExtendRequest();
  
  
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
                  padding: EdgeInsets.only(top: 50.h),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ================= Image Carousel =================
                    
                        
                           _buildCarouselSection(),
                        
                        
                        SizedBox(height: 20.h),

                        // ================= Access Message =================
                        _buildAccessMessage(),

                        SizedBox(height: 24.h),

                        // ================= New Arrival Section =================
                        _buildNewArrivalSection(context),

                        SizedBox(height: 24.h),

                        // ================= Follow Us Section =================
                        const FollowUsSection(),

                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ),

                // ================= Fixed Header =================
                _buildHeader(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile Icon
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountScreen()),
              );
            },
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF42A5F5), Colors.pinkAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          // App Title
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "CARAVELLE",
                style: GoogleFonts.italiana(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 22.sp,
                  letterSpacing: 1.8,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Gold | CZ | Lab Diamonds',
                style: GoogleFonts.roboto(
                  fontSize: 10.sp,
                  color: Colors.amber.shade200,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Gold Rate
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Gold Rate",
                  style: TextStyle(
                    color: Colors.amber.shade100,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.currency_rupee,
                      color: Colors.amber.shade300,
                      size: 12.w,
                    ),
                    Text(
                      goldRate != null ? "$goldRate / gm" : "Loading...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselSection() {
    return Stack(
      children: [
        Container(
          height: 400.h,
          child: isLoading
              ? _buildLoadingCarousel()
              : images.isEmpty
                  ? _buildEmptyCarousel()
                  : CarouselSlider.builder(
                      itemCount: images.length,
                      options: CarouselOptions(
                        height: 400.h,
                        viewportFraction: 1.0,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 4),
                        onPageChanged: (index, reason) =>
                            setState(() => activeIndex = index),
                      ),
                      itemBuilder: (context, index, realIndex) {
                        return Container(
                       //   margin: EdgeInsets.symmetric(horizontal: 4.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(0.r),
                            child: Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.error_outline,
                                    color: Colors.grey,
                                    size: 50,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
        ),
        
        // Carousel Indicator
        if (!isLoading && images.isNotEmpty)
          Positioned(
            bottom: 20.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: AnimatedSmoothIndicator(
                  activeIndex: activeIndex,
                  count: images.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 6.h,
                    dotWidth: 6.w,
                    activeDotColor: Colors.amber,
                    dotColor: Colors.white.withOpacity(0.6),
                    spacing: 4.w,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingCarousel() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyCarousel() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 50.w,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 8.h),
          Text(
            "No images available",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

Widget _buildAccessMessage() {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 16.w),
    padding: EdgeInsets.all(20.w),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue.shade50, Colors.teal.shade50],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: Colors.blue.shade100),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.schedule,
          size: 40.w,
          color: Colors.blue.shade600,
        ),
        SizedBox(height: 12.h),
        Text(
          "⏳ Access Pending",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            color: Colors.blue.shade800,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          "You don't have admin access yet. It will be granted within 24–48 hours. Once approved, you'll be able to view the full collection.",
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20.h),

       // 👇 Customer Request Button / Message Section
Center(
  child: _apiMessage != null && _apiMessage!.isNotEmpty
      ? Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.teal, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, color: Colors.teal, size: 22.sp),
              SizedBox(width: 10.w),
              Flexible(
                child: Text(
                  _apiMessage!,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal.shade800,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        )
      : ElevatedButton.icon(
          onPressed: () async {
            await fetchExtendRequestButton(context);
          },
          icon: Icon(Icons.person_add_alt_1, color: Colors.white, size: 20.sp),
          label: Text(
            "Request Access",
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 3,
          ),
        ),
)
,
        // 👇 “Thank you for your patience” text below button
        SizedBox(height: 12.h),
        Text(
          "🙏 Thank you for your patience!",
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.teal.shade700,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}


  Widget _buildNewArrivalSection(BuildContext context) {
  return FutureBuilder(
    future: _fetchProducts(),
    builder: (context, snapshot) {
      final products = snapshot.data;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "✨ Basic Design",
                  style: GoogleFonts.roboto(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
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
                            builder: (_) => const ViewAllProductsScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 10.h),
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
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14.w,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // 🔹 Horizontal Scroll
            if (products != null && products.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: products.take(5).map((product) {
                    final productName =
                        (product['product'] ?? '').toString().trim();
                    final subProduct =
                        (product['sub_product'] ?? '').toString().trim();
                    final design =
                        (product['design'] ?? '').toString().trim();
                    final imageUrl =
                        (product['image_url'] ?? '').toString().trim();

                    // 🧩 Text display logic
                    String nameText = (subProduct.isEmpty ||
                            subProduct.toLowerCase() == "null")
                        ? productName
                        : subProduct;

                    String designText =
                        (design.isNotEmpty && design.toLowerCase() != "null")
                            ? " ($design)"
                            : "";

                    return _buildProductCard(imageUrl, "$nameText$designText");
                  }).toList(),
                ),
              )
            else
              SizedBox(
                height: 140.h,
                child: const Center(
                  child: Text(
                    "Loading products...",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

Widget _buildProductCard(String imageUrl, String label) {
  return Container(
    margin: EdgeInsets.only(right: 16.w),
    child: Column(
      children: [
        Container(
          height: 120.h,
          width: 120.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  )
                : Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.roboto(
              color: Colors.black87,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

Future<List<Map<String, dynamic>>> _fetchProducts() async {
  
  final url =
      Uri.parse('${baseUrl}no_access_products.php');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'token': token},
    );

    debugPrint("📡 API Status: ${response.statusCode}");
    debugPrint("🧾 Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('total_data')) {
        return List<Map<String, dynamic>>.from(data['total_data']);
      }
    }
  } catch (e) {
    debugPrint("❌ Error fetching products: $e");
  }

  return [];
}

}