import 'dart:convert';
import 'package:caravelle/dashboard_naves/subcategory.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class ProductCategoriesScreen extends StatefulWidget {
  @override
  State<ProductCategoriesScreen> createState() => _ProductCategoriesScreenState();
}

class _ProductCategoriesScreenState extends State<ProductCategoriesScreen> {
  List<CategoryItem> categories = [];
  List<CategoryItem> filteredCategories = [];
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final url = '${baseUrl}product_display.php';

    try {
      print('==============================');
      print('🌐 API CALL STARTED');
      print('📬 URL: $url');
      print('🔑 Token Sent: "$token"');
      print('==============================');

      final response = await http.post(
        Uri.parse(url),
        body: {'token': token},
      );

      print('🔵 API Status Code: ${response.statusCode}');
      print('📩 Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['response'] == 'success') {
          final List<dynamic> items = data['data'] ?? [];
          setState(() {
            categories = items
                .map((item) => CategoryItem(
                      item['name'] ?? 'No Name',
                      item['image_url'] ?? '',
                    ))
                .toList();
            filteredCategories = categories;
            isLoading = false;
          });
          print('✅ Success Message: ${data['message']}');
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Something went wrong';
            isLoading = false;
          });
          print('❌ Error Message: ${data['message']}');
        }
      } else {
        setState(() {
          errorMessage = 'Server Error: ${response.statusCode}';
          isLoading = false;
        });
        print('🔴 Server Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Exception: $e';
        isLoading = false;
      });
      print('⚠️ Exception: $e');
    }
  }

  void filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCategories = categories;
      } else {
        filteredCategories = categories
            .where((cat) =>
                cat.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.primaryColor,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: AppTheme.primaryColor),
          title: Text(
            'Categories',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
         
       
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔍 Search Bar + All Button
              Container(
                height: 42.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 12.w),
                    Icon(Icons.search,
                        size: 20.w, color: AppTheme.primaryColor),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: filterSearch,
                        decoration: InputDecoration(
                          hintText: 'Search categories...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14.sp,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                    Container(
                      height: 30.h,
                      width: 2.w,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      onPressed: () {
                        searchController.clear();
                        filterSearch('');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        minimumSize: Size(0, 30.h),
                      ),
                      child: Text(
                        'All',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                  ],
                ),
              ),

              
              SizedBox(height: 20.h),

              /// 🟡 Loading / Error / Grid with Pull-to-Refresh
              Expanded(
                child: RefreshIndicator(
                  // 🌈 Stylish Refresh Indicator Colors
                  color: AppTheme.primaryColor,
                  backgroundColor: Colors.white,
                  strokeWidth: 2.5,
                  displacement: 40,
                  edgeOffset: 0,
                  // 🔄 Pull-to-Refresh Functionality
                  onRefresh: () async {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    await fetchCategories();
                  },
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 50.w,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14.sp,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16.h),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isLoading = true;
                                        errorMessage = null;
                                      });
                                      fetchCategories();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Retry',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : filteredCategories.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.category_outlined,
                                        color: Colors.grey,
                                        size: 60.w,
                                      ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        'No categories found',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'Pull down to refresh',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              
  : GridView.builder(
    itemCount: filteredCategories.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 6.h,
      crossAxisSpacing: 16.w,
      childAspectRatio: 0.9,
    ),
    itemBuilder: (context, index) {
      return CleanCategoryCard(
        category: filteredCategories[index],
      );
    },
  ),
),

                
              ),
            ],
          ),
        ),
        // 🔄 Floating Action Button for Refresh
      
      ),
    );
  }
}

/// Category Model
class CategoryItem {
  final String title;
  final String image;
  CategoryItem(this.title, this.image);
}

/// Clean Category Card with Simple Image in Middle
class CleanCategoryCard extends StatelessWidget {
  final CategoryItem category;

  const CleanCategoryCard({Key? key, required this.category}) : super(key: key);

  void _navigateToCategory(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubCategoriesScreen(mainCategory: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _navigateToCategory(context, category.title),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.08),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🟢 Image perfectly fills the box
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1.1, // square box (equal height & width)
                child: category.image.isNotEmpty
                    ? Image.network(
                        category.image,
                        fit: BoxFit.cover, // ✅ fills full box neatly
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 40.w,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40.w,
                          color: Colors.grey.shade400,
                        ),
                      ),
              ),
            ),

            SizedBox(height:14.h),

            // 🔹 Category title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Text(
                category.title,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
