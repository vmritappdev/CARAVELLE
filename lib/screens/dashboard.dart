
import 'package:caravelle/screens/categories_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  
  int _days = 5;
  int _hours = 12;
  int _minutes = 45;
  int _seconds = 30;

  int activeIndex = 0;

  final List<String> _carouselImages = [
    'assets/images/cara8.png',
    'assets/images/cara9.png',
    'assets/images/cara10.png',
    'assets/images/cara11.png',
  ];

 
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_seconds > 0) {
            _seconds--;
          } else {
            _seconds = 59;
            if (_minutes > 0) {
              _minutes--;
            } else {
              _minutes = 59;
              if (_hours > 0) {
                _hours--;
              } else {
                _hours = 23;
                if (_days > 0) {
                  _days--;
                }
              }
            }
          }
        });
        _startTimer();
      }
    });
  }


  

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;




    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppTheme.primaryColor, // Status bar color
      statusBarIconBrightness: Brightness.light, // Icons white
    ));

    return SafeArea(
      child: Scaffold(
        
        backgroundColor: Colors.white,
       appBar: AppBar(
  automaticallyImplyLeading: false,
  backgroundColor: AppTheme.primaryColor,
  elevation: 0,
  toolbarHeight: 60.h,
  title: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Logo + Name
      Row(
        children: [
          Image.asset(
            'assets/images/caravelle.png',
            height: 60.h,
            width: 60.w,
            fit: BoxFit.contain,
            color: Colors.white,
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Caravelle',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.logoSize,
                  ),
                ),
              ),
              Text(
                'Jewellery & Diamonds',
                style: TextStyle(
                  color: Colors.amber.shade200,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),

      // Gold Rate (small, neat)
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Gold Rate",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.sp,
            ),
          ),
          Text(
            '₹11,200 / g', // API dynamic use cheyachu
            style: TextStyle(
              color: Colors.amber.shade200,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    ],
  ),
),


        body: SingleChildScrollView(
          
        //  padding: EdgeInsets.all(16.r),
          child: Column(
            
            children: [

 SizedBox(height: 30,),

               Padding(
                 padding:  EdgeInsets.only(left:  10.r,right: 10.r),
                 child: Container(
                  
                  height: 45.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 16.w),
                      Icon(
                        Icons.search_rounded,
                        color: AppTheme.primaryColor,
                        size: 22.h,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search jewelry, diamonds, ...",
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey[500],
                              fontSize: AppTheme.subHeaderSize,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 8.w),
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.filter_list_rounded,
                          color: AppTheme.primaryColor,
                          size: 18.h,
                        ),
                      ),
                    ],
                  ),
                               ),
               ),




              SizedBox(height: 12.h),
              // Expiring Soon Section - Reduced Height
Padding(
  padding: EdgeInsets.symmetric(horizontal: 10.r),
  child: Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.r),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18.r),
      gradient: LinearGradient(
        colors: [
          Color(0xFFFFF8E1), // light gold
          Color(0xFFFFECB3), // deeper gold
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.amber.withOpacity(0.3),
          blurRadius: 10,
          offset: Offset(0, 6),
        ),
      ],
      border: Border.all(
        color: Color(0xFFD4AF37).withOpacity(0.5), // elegant gold border
        width: 1.2,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "⏳ Expiring In",
          style: GoogleFonts.poppins(
            fontSize: AppTheme.subHeaderSize,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildVerticalTimeItem("Days", _days),
            _buildVerticalTimeItem("Hours", _hours),
            _buildVerticalTimeItem("Min", _minutes),
            _buildVerticalTimeItem("Sec", _seconds),
          ],
        ),
      ],
    ),
  ),
),


              SizedBox(height: 20.h),

              // Carousel Slider with neat design
             Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.01),
              child: SizedBox(
              
                width: double.infinity,
                
                child: CarouselSlider.builder(
                  itemCount: _carouselImages.length,
                  options: CarouselOptions(
                    height: screenHeight * 0.25,
                    viewportFraction: 1.0,
                    autoPlay: true,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: false,
                    autoPlayAnimationDuration: const Duration(milliseconds: 700),
                    onPageChanged: (index, reason) {
                      setState(() => activeIndex = index);
                    },
                    autoPlayInterval: const Duration(seconds: 3),
                  ),
                  itemBuilder: (context, index, realIndex) {
                    final image = _carouselImages[index];
                    return Container(
                      
                      width: double.infinity,
                      decoration: const BoxDecoration(
                     
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                           // borderRadius: BorderRadius.circular(5),
                            child: Image.asset(
                              image, 
                              fit: BoxFit.cover,
                         width: double.infinity,
                         height: screenHeight * 0.6, 
                            ),
                          ),
                         
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            //  SizedBox(height: 12.h),

              // Carousel Indicators
              buildIndicator(),

              SizedBox(height: 24.h),

              // Ready Stock Section
              _buildSectionHeader("Ready Stock",showViewAll: false),
              SizedBox(height: 16.h),


              


         Padding(
  padding: EdgeInsets.symmetric(horizontal: 10.r),
  child: Row(
    children: [
      // Left Image with 18K Button
      Expanded(
        child: Stack(
          children: [
            Container(
              height: 180.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                image: DecorationImage(
                  image: AssetImage("assets/images/cara3.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoriesScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        side: BorderSide(color: Color(0xFFD4AF37)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    ),
                    child: Text(
                      "18K Gold",
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      SizedBox(width: 10.w),

      // Right Image with 14K Button
      Expanded(
        child: Stack(
          children: [
            Container(
              height: 180.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                image: DecorationImage(
                  image: AssetImage("assets/images/cara4.png"), // Replace with second image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoriesScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        side: BorderSide(color: Color(0xFFD4AF37)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    ),
                    child: Text(
                      "14K Gold",
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),


              SizedBox(height: 24.h),

                _buildSectionHeader("Custom Orders",showViewAll: false),
                 SizedBox(height: 16.h),
                 Padding(
                   padding:  EdgeInsets.only(left: 10.r,right: 10.r),
                   child: Container(
                                   width: double.infinity,
                                   height: 100.h,
                                   padding: EdgeInsets.all(16.r),
                                   decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFD700).withOpacity(0.1),
                        const Color(0xFFD4AF37).withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                                   ),
                                   child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Latest Designs",
                              style: GoogleFonts.poppins(
                                color: Colors.grey[800],
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "Discover our newest collection of exquisite jewelry pieces",
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppTheme.primaryColor.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.diamond_outlined,
                          size: 32,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                                   ),
                                 ),
                 ),

              SizedBox(height: 24.h),

              // New Arrival Section
              _buildSectionHeader("New Arrival"),
              SizedBox(height: 16.h),
              Padding(
                padding:  EdgeInsets.only(left: 10.r,right: 10.r),
                child: Container(
                  width: double.infinity,
                  height: 100.h,
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFD700).withOpacity(0.1),
                        const Color(0xFFD4AF37).withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Latest Designs",
                              style: GoogleFonts.poppins(
                                color: Colors.grey[800],
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "Discover our newest collection of exquisite jewelry pieces",
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppTheme.primaryColor.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.diamond_outlined,
                          size: 32,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Exclusive Designs Section
              _buildSectionHeader("Exclusive Designs"),
              SizedBox(height: 16.h),
              Padding(
               padding:  EdgeInsets.only(left: 10.r,right: 10.r),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 36,
                        color: const Color(0xFFD4AF37),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "Limited Edition Pieces",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[800],
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "Handcrafted designs available only at Caravelle",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 60.h),
            ],
          ),
        ),

        // Bottom Navigation Bar


      ),
    );
  }

 Widget _buildVerticalTimeItem(String label, int time) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Time Box with Gold Border and Soft Shadow
      Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFD4AF37), // Soft gold border
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            time.toString().padLeft(2, '0'),
            style: GoogleFonts.poppins(
              color: const Color(0xFFD4AF37),
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      SizedBox(height: 6.h),
      // Label below the time box
      Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.black87,
          fontSize: AppTheme.fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

 Widget _buildSectionHeader(String title, {bool showViewAll = true}) {
  return Padding(
    padding:  EdgeInsets.only(left: 10.r,right: 10.r),
    child: Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.grey[800],
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (showViewAll) ...[
          Text(
            "View All",
            style: GoogleFonts.poppins(
              color: AppTheme.primaryColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 12,
            color: AppTheme.primaryColor,
          ),
        ],
      ],
    ),
  );
}







  Widget buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: _carouselImages.length,
        effect: const SlideEffect(
          dotWidth: 8,
          dotHeight: 8,
          activeDotColor: AppTheme.primaryColor,
          dotColor: Colors.grey,
        ),
      );
}