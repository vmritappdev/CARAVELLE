import 'package:caravelle/dashboard_naves/goldshop_offer.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum ImageSide { left, right }

class CustomDesignWidget extends StatefulWidget {
  const CustomDesignWidget({super.key});

  @override
  State<CustomDesignWidget> createState() => _CustomDesignWidgetState();
}

class _CustomDesignWidgetState extends State<CustomDesignWidget> {
  List<DesignItem> _designItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchExclusiveCollection();
  }

  Future<void> _fetchExclusiveCollection() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await http.post(
        Uri.parse('${baseUrl}exclusive_collection.php'),
        body: {
          'token': token,
        },
      );

      print('🔹 API URL: https://caravelle.in/barcode/app/exclusive_collection.php');
      print('🔹 Status Code: ${response.statusCode}');
      print('🔹 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Full Response: $data');

        if (data['response'] == 'success' && data['total_count'] > 0) {
          final List<dynamic> collectionData = data['total_data'];
          final List<DesignItem> items = [];
          
          for (int i = 0; i < collectionData.length && i < 3; i++) {
            final item = collectionData[i];
            final imageUrl = item['image_url']?.toString();
            final collection = item['collection']?.toString();
            
          
         

String title;
if (collection != null && collection.isNotEmpty && collection != 'null') {
  title = '$collection COLLECTIONS'; 
} else {
  title = 'Stock Collections'; // fallback case
}

            
            items.add(DesignItem(
              imageUrl: imageUrl ?? _getDefaultImage(i),
              title: title,
              subtitle: _getDefaultSubtitle(i),
              accentColor: _getAccentColor(i),
            ));
          }
          
          setState(() {
            _designItems = items;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'No collections found';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network Error: $e';
        _isLoading = false;
      });
      print('⚠️ Exception: $e');
    }
  }

  // Helper methods for fallback data
  String _getDefaultTitle(int index) {
    switch (index) {
      case 0: return 'Modern Gold Necklace';
      case 1: return 'Classic Bangles Set';
      case 2: return 'Royal Bridal Collection';
      default: return 'Exclusive Design';
    }
  }

  String _getDefaultSubtitle(int index) {
    switch (index) {
      case 0: return 'Elegant & timeless craftsmanship';
      case 1: return 'Perfect blend of tradition & style';
      case 2: return 'Designed for special moments';
      default: return 'Premium jewelry collection';
    }
  }

  String _getDefaultImage(int index) {
    switch (index) {
      case 0: return 'assets/images/cara4.png';
      case 1: return 'assets/images/cara8.png';
      case 2: return 'assets/images/cara9.png';
      default: return 'assets/images/default_jewelry.png';
    }
  }

  Color _getAccentColor(int index) {
    final accentColors = [
      Colors.amber.shade600,
      Colors.orange.shade600,
      Colors.red.shade400,
    ];
    return accentColors[index % accentColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Header
            _buildHeader(context),
            SizedBox(height: 24.h),
            
            // Premium Card Container
            _buildDesignsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "✨Exclusive Collections",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1a1a1a),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "Curated collection for the modern you",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          
          // Enhanced View All Button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryColor],
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
                      builder: (context) => GoldShopOffersScreen(
                        mainCategory: "Exclusive Designs",
                        subCategory: "All Designs",
                          subProducts: ''
                      ),
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
    );
  }

  Widget _buildDesignsCard() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    // Use fallback data if API didn't return enough items
    final List<DesignItem> displayItems = _designItems.isNotEmpty 
        ? _designItems 
        : [
            DesignItem(
              imageUrl: _getDefaultImage(0),
              title: _getDefaultTitle(0),
              subtitle: _getDefaultSubtitle(0),
              accentColor: _getAccentColor(0),
            ),
            DesignItem(
              imageUrl: _getDefaultImage(1),
              title: _getDefaultTitle(1),
              subtitle: _getDefaultSubtitle(1),
              accentColor: _getAccentColor(1),
            ),
            DesignItem(
              imageUrl: _getDefaultImage(2),
              title: _getDefaultTitle(2),
              subtitle: _getDefaultSubtitle(2),
              accentColor: _getAccentColor(2),
            ),
          ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.teal.shade50.withOpacity(0.7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            _buildDesignItem(
              designItem: displayItems[0],
              imageSide: ImageSide.left,
            ),
            SizedBox(height: 24.h),
            _buildDivider(),
            SizedBox(height: 24.h),
            _buildDesignItem(
              designItem: displayItems[1],
              imageSide: ImageSide.right,
            ),
            SizedBox(height: 24.h),
            _buildDivider(),
            SizedBox(height: 24.h),
            _buildDesignItem(
              designItem: displayItems[2],
              imageSide: ImageSide.left,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesignItem({
    required DesignItem designItem,
    required ImageSide imageSide,
  }) {
    final textContent = Expanded(
      child: Column(
        crossAxisAlignment: imageSide == ImageSide.left
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: designItem.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              designItem.title, // Now shows API collection name
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            designItem.subtitle,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            textAlign:
                imageSide == ImageSide.left ? TextAlign.left : TextAlign.right,
          ),
        ],
      ),
    );

    final imageContainer = Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: designItem.accentColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          children: [
            // Use NetworkImage for API URLs, AssetImage for local assets
            designItem.imageUrl.startsWith('http')
                ? Image.network(
                    designItem.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            color: AppTheme.primaryColor,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => _buildDefaultImage(designItem.accentColor),
                  )
                : Image.asset(
                    designItem.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) => _buildDefaultImage(designItem.accentColor),
                  ),
            // Gradient overlay for better text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: imageSide == ImageSide.left
          ? [imageContainer, SizedBox(width: 20.w), textContent]
          : [textContent, SizedBox(width: 20.w), imageContainer],
    );
  }

  Widget _buildDefaultImage(Color accentColor) {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image_not_supported_rounded, 
        color: Colors.grey.shade400, 
        size: 30,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.grey.shade300,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < 3; i++) ...[
            if (i > 0) SizedBox(height: 24.h),
            if (i > 0) _buildDivider(),
            if (i > 0) SizedBox(height: 24.h),
            _buildShimmerItem(index: i),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmerItem({required int index}) {
    final imageSide = index % 2 == 0 ? ImageSide.left : ImageSide.right;

    final shimmerContent = Expanded(
      child: Column(
        crossAxisAlignment: imageSide == ImageSide.left
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: 80.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );

    final shimmerImage = Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: imageSide == ImageSide.left
          ? [shimmerImage, SizedBox(width: 20.w), shimmerContent]
          : [shimmerContent, SizedBox(width: 20.w), shimmerImage],
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.orange,
            size: 40.w,
          ),
          SizedBox(height: 12.h),
          Text(
            'Failed to load collections',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _errorMessage ?? 'Please try again',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _fetchExclusiveCollection,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Retry',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class to store design item data
class DesignItem {
  final String imageUrl;
  final String title;
  final String subtitle;
  final Color accentColor;

  DesignItem({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });
}