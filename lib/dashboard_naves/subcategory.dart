import 'dart:convert';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:http/http.dart' as http;
import 'package:caravelle/dashboard_naves/goldshop_offer.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubCategoriesScreen extends StatefulWidget {
  final String mainCategory;
    final String type;

  const SubCategoriesScreen({Key? key, required this.mainCategory,required this.type}) : super(key: key);

  @override
  State<SubCategoriesScreen> createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen> {
  List<dynamic> subProducts = [];
  List<dynamic> filteredSubProducts = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';

  // 🎯 Filter Options
  bool _showFilters = false;
  String _sortBy = 'name';
  final List<String> _sortOptions = ['name', 'recent'];

  @override
  void initState() {
    super.initState();
    fetchSubProducts();
  }

  /// 🔹 Fetch Sub Products API Call
  Future<void> fetchSubProducts() async {
  try {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('${baseUrl}sub_product_display.php'),
      body: {
        'token': token,
        'product': widget.mainCategory,
        'type': widget.type,
      },
    );

    print('🔹 API URL: ${baseUrl}sub_product_display.php');
    print('🔹 Sent Product: ${widget.mainCategory}');
    print('🔹 Sent Type: ${widget.type}');
    print('🔹 Status Code: ${response.statusCode}');
    print('🔹 Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['response'] == 'success' && data['data'] != null && data['data'].isNotEmpty) {
        final List<dynamic> subList = data['data'][0]['sub_products'] ?? [];

        // ✅ Convert to List<Map<String, dynamic>> (for image_url access)
        setState(() {
          subProducts = List<Map<String, dynamic>>.from(subList);
          filteredSubProducts = subProducts;
          isLoading = false;
        });

        print('✅ Total Sub Products: ${subProducts.length}');
        for (var item in subProducts) {
          print('📦 Name: ${item['name']} | 🖼️ Image: ${item['image_url']}');
        }

      } else {
        setState(() {
          subProducts = [];
          filteredSubProducts = [];
          isLoading = false;
        });
        print('⚠️ No Sub Products Found');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print('❌ Server Error: ${response.statusCode}');
    }
  } catch (e) {
    print('⚠️ Exception: $e');
    setState(() {
      isLoading = false;
    });
  }
}


  /// 🔹 Search Filter Function
  void _filterSubProducts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        filteredSubProducts = List.from(subProducts);
      } else {
        filteredSubProducts = subProducts.where((item) {
          final name = item.toString().toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      }
      _applySorting();
    });
  }

  /// 🔹 Apply Sorting
  void _applySorting() {
    setState(() {
      if (_sortBy == 'name') {
        filteredSubProducts.sort((a, b) => a.toString().compareTo(b.toString()));
      } else if (_sortBy == 'recent') {
        // For recent, we'll keep original order (assuming API returns recent first)
        filteredSubProducts = List.from(filteredSubProducts);
      }
    });
  }

  /// 🔹 Toggle Filter Panel
 

  /// 🔹 Get Category Icon based on Main Category
  IconData _getCategoryIcon() {
    final category = widget.mainCategory.toLowerCase();
    if (category.contains('gold') || category.contains('jewell')) {
      return Icons.diamond;
    } else if (category.contains('silver')) {
      return Icons.workspace_premium;
    } else if (category.contains('diamond')) {
      return Icons.emoji_events;
    } else if (category.contains('watch')) {
      return Icons.watch;
    } else if (category.contains('electronic')) {
      return Icons.electrical_services;
    } else if (category.contains('fashion') || category.contains('cloth')) {
      return Icons.checkroom;
    } else {
      return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            widget.mainCategory,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
              letterSpacing: 0.3,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppTheme.primaryColor,
          elevation: 2,
          actions: [
            // 🔄 Refresh Button
            IconButton(
              icon: Icon(Icons.refresh, size: 22.w),
              onPressed: fetchSubProducts,
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              /// 🔍 Modern Search Bar with Filter Button
              Container(
                height: 52.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(width: 16.w),
                    Icon(Icons.search_rounded, size: 24.w, color: AppTheme.primaryColor),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: _filterSubProducts,
                        decoration: InputDecoration(
                          hintText: 'Search in ${widget.mainCategory}...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14.sp,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                    // Filter Toggle Button
                    Container(
                      height: 32.h,
                      width: 1.w,
                      color: Colors.grey.shade300,
                    ),
                   
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              /// 🎯 Filter Panel (Expandable)
              if (_showFilters) ...[
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.sort_rounded, size: 18.w, color: AppTheme.primaryColor),
                          SizedBox(width: 8.w),
                          Text(
                            'Sort By:',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          // Sort Options
                          ..._sortOptions.map((option) {
                            return Padding(
                              padding: EdgeInsets.only(right: 12.w),
                              child: ChoiceChip(
                                label: Text(
                                  option == 'name' ? 'A-Z' : 'Recent',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: _sortBy == option ? Colors.white : AppTheme.primaryColor,
                                  ),
                                ),
                                selected: _sortBy == option,
                                selectedColor: AppTheme.primaryColor,
                                backgroundColor: Colors.grey.shade100,
                                onSelected: (selected) {
                                  setState(() {
                                    _sortBy = option;
                                    _applySorting();
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      // Clear Filters
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: Icon(Icons.clear_all, size: 16.w),
                              label: Text('Clear All'),
                              onPressed: () {
                                setState(() {
                                  searchController.clear();
                                  _searchQuery = '';
                                  _sortBy = 'name';
                                  filteredSubProducts = List.from(subProducts);
                                  _applySorting();
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade600,
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              /// 📊 Header with Stats
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(),
                      color: AppTheme.primaryColor,
                      size: 24.w,
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sub Products',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          '${widget.mainCategory} Category',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '${filteredSubProducts.length} items',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              /// 🔹 Data Display with Enhanced Cards
              Expanded(
                child: isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppTheme.primaryColor,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Loading Sub Products...',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      )
                    : filteredSubProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64.w,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  _searchQuery.isEmpty
                                      ? "No sub products found"
                                      : "No results for '$_searchQuery'",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Try different keywords or filters',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.refresh, size: 18.w),
                                  label: Text('Refresh'),
                                  onPressed: fetchSubProducts,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: AppTheme.primaryColor,
                            backgroundColor: Colors.white,
                            onRefresh: fetchSubProducts,
                            child: ListView.builder(
                              padding: EdgeInsets.only(bottom: 16.h),
                              itemCount: filteredSubProducts.length,
                              itemBuilder: (context, index) {
                              final subProduct = filteredSubProducts[index];
               return _buildEnhancedSubProductCard(subProduct, index);

                              },
                            ),
                          ),
              ),
            ],
          ),
        ),

        /// 🚀 Floating Action Button for Quick Actions
       
      ),
    );
  }

  /// 🔹 Enhanced Sub Product Card with Better Design
 Widget _buildEnhancedSubProductCard(Map<String, dynamic> subProduct, int index) {
  final name = subProduct['name'] ?? '';
  final imageUrl = subProduct['image_url'] ?? '';

  IconData getSubCategoryIcon() {
    final subName = name.toLowerCase();
    if (subName.contains('ring') || subName.contains('bangle')) {
      return Icons.workspace_premium;
    } else if (subName.contains('chain') || subName.contains('necklace')) {
      return Icons.favorite;
    } else if (subName.contains('ear') || subName.contains('jhumka')) {
      return Icons.hearing;
    } else if (subName.contains('bracelet')) {
      return Icons.watch;
    } else if (subName.contains('coin') || subName.contains('bar')) {
      return Icons.monetization_on;
    } else {
      return Icons.shopping_bag_rounded;
    }
  }

  return Container(
  margin: EdgeInsets.only(bottom: 12.h),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoldShopOffersScreen(
              mainCategory: widget.mainCategory,
              subCategory: name,
              subProducts: name,
                 product: widget.mainCategory, // ✅ pass product
                  type: widget.type,  
                  fetchApiType: '',          // ✅ pass type
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50, // same subtle background tone
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06), // 👈 same as old shadow
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 🖼️ Image (no inner shadow)
            Container(
              width: 60.w,
              height: 60.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.broken_image,
                                color: Colors.grey, size: 28.w),
                      )
                    : Container(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        child: Icon(
                          getSubCategoryIcon(),
                          color: AppTheme.primaryColor,
                          size: 28.w,
                        ),
                      ),
              ),
            ),

            SizedBox(width: 16.w),

            // 📝 Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${widget.mainCategory} • Sub Category',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // ➡️ Arrow Icon
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.w,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);

}

}