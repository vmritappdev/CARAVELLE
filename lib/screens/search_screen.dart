import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: TextField(
          decoration: InputDecoration(
            hintText: "Search diamonds, gold, rings, necklaces...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          autofocus: true,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent Searches Section
            _buildSectionTitle('Recent Searches'),
            SizedBox(height: 12.h),
            _buildRecentSearches(),
            SizedBox(height: 24.h),
            
            // Popular Categories Section
            _buildSectionTitle('Popular Categories'),
            SizedBox(height: 12.h),
            _buildPopularCategories(),
            SizedBox(height: 24.h),
            
            // Featured Collections Section
            _buildSectionTitle('Featured Collections'),
            SizedBox(height: 12.h),
            _buildFeaturedCollections(),
            SizedBox(height: 24.h),
            
            // Trending Products Section
            _buildSectionTitle('Trending Now'),
            SizedBox(height: 12.h),
            _buildTrendingProducts(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildRecentSearches() {
    final List<String> recentSearches = [
      'Lab Grown Diamond Rings',
      '24K Gold Necklaces',
      'Wedding Bands for Men',
      'CZ Stud Earrings',
      'Rose Gold Bracelets',
    ];

    return Column(
      children: recentSearches.map((search) => _buildSearchItem(search)).toList(),
    );
  }

  Widget _buildSearchItem(String searchText) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 20.w, color: Colors.grey.shade600),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              searchText,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16.w, color: Colors.grey.shade500),
        ],
      ),
    );
  }

  Widget _buildPopularCategories() {
    final List<Map<String, dynamic>> categories = [
      {'name': 'Diamond Rings', 'icon': Icons.diamond_outlined},
      {'name': 'Gold Jewelry', 'icon': Icons.workspace_premium},
      {'name': 'CZ Collection', 'icon': Icons.auto_awesome},
      {'name': 'Bridal Sets', 'icon': Icons.favorite_border},
      {'name': 'Men\'s Jewelry', 'icon': Icons.watch},
      {'name': 'Necklaces', 'icon': Icons.currency_lira},
      {'name': 'Earrings', 'icon': Icons.hearing},
      {'name': 'Bracelets', 'icon': Icons.link},
    ];

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: categories.map((category) => _buildCategoryChip(category)).toList(),
    );
  }

  Widget _buildCategoryChip(Map<String, dynamic> category) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            category['icon'],
            size: 16.w,
            color: AppTheme.primaryColor,
          ),
          SizedBox(width: 6.w),
          Text(
            category['name'],
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCollections() {
    final List<Map<String, String>> collections = [
      {'name': 'Premium Diamond Collection', 'items': '50+ items'},
      {'name': '24K Pure Gold Jewelry', 'items': '35+ items'},
      {'name': 'Lab Grown Diamond Rings', 'items': '28+ items'},
      {'name': 'Wedding & Engagement', 'items': '42+ items'},
      {'name': 'CZ Luxury Collection', 'items': '65+ items'},
    ];

    return Column(
      children: collections.map((collection) => _buildCollectionItem(collection)).toList(),
    );
  }

  Widget _buildCollectionItem(Map<String, String> collection) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryColor, Color(0xFFD4AF37)],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  collection['name']!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  collection['items']!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16.w, color: Colors.grey.shade500),
        ],
      ),
    );
  }

  Widget _buildTrendingProducts() {
    final List<Map<String, String>> products = [
      {'name': '1 Carat Lab Diamond Ring', 'price': '₹45,999'},
      {'name': '24K Gold Mangalsutra', 'price': '₹32,499'},
      {'name': 'CZ Princess Cut Earrings', 'price': '₹8,999'},
      {'name': 'Men\'s Gold Wedding Band', 'price': '₹18,750'},
      {'name': 'Diamond Tennis Bracelet', 'price': '₹67,800'},
      {'name': 'Rose Gold Pendant Set', 'price': '₹23,450'},
      {'name': 'Platinum Diamond Ring', 'price': '₹89,999'},
    ];

    return Column(
      children: products.map((product) => _buildProductItem(product)).toList(),
    );
  }

  Widget _buildProductItem(Map<String, String> product) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Icon(
                Icons.diamond_outlined,
                color: AppTheme.primaryColor,
                size: 22.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name']!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  product['price']!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16.w, color: Colors.grey.shade500),
        ],
      ),
    );
  }
}