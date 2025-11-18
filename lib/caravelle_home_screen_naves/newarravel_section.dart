import 'dart:convert';
import 'package:caravelle/dashboard_naves/goldshop_offer.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;


class NewArrivalSection extends StatefulWidget {
  const NewArrivalSection({Key? key}) : super(key: key);

  @override
  State<NewArrivalSection> createState() => _NewArrivalSectionState();
}

class _NewArrivalSectionState extends State<NewArrivalSection> {
  List<dynamic> _newArrivals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNewArrivals();
  }

  Future<void> _fetchNewArrivals() async {
    final url = Uri.parse("${baseUrl}new_arrival.php");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'token': token},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ API Response: ${response.body}");

        if (data is Map && data['total_data'] is List) {
          final List<dynamic> list = data['total_data'];

          setState(() {
            _newArrivals = list;
            _isLoading = false;
          });

          print("✅ Total new arrivals: ${_newArrivals.length}");
          for (var item in _newArrivals) {
            final product = item['product'] ?? 'Unknown';
            final subProduct = item['sub_product'] ?? '';
            final design = item['design'] ?? '';
            final imageUrl = item['image_url'] ?? '';

            print("📦 ${subProduct.isNotEmpty ? subProduct : product} "
                "${design.isNotEmpty ? '($design)' : ''} | 🖼️ $imageUrl");
          }
        } else {
          print("⚠️ Unexpected data format: ${data.runtimeType}");
          setState(() => _isLoading = false);
        }
      } else {
        print("❌ API Error: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("❌ Exception: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "✨ New Arrival Design",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              /// 🔹 View All Button
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
                          builder: (context) =>
                              GoldShopOffersScreen(subProducts: '',fetchApiType: 'newArrival',),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
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

          /// 🔹 Dynamic Scrollable Image Row
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _newArrivals.take(5).map((item) {
                      final imageUrl = item['image_url'] ?? '';
                      final product = item['product'] ?? '';
                      final subProduct = item['sub_product'] ?? '';
                      final design = item['design'] ?? '';

                      return _customImageCard(
                        imageUrl,
                        product,
                        subProduct,
                        design,
                      );
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }

  /// 🔹 Custom Image Card Widget
  Widget _customImageCard(
      String imageUrl, String product, String subProduct, String design) {
    // ✅ Main title logic
    String mainTitle = subProduct.isNotEmpty ? subProduct : product;

    // ✅ Add design only if not empty
    String finalTitle = design.isNotEmpty ? "$mainTitle ($design)" : mainTitle;

    return Container(
      width: 130.w,
      margin: EdgeInsets.only(right: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 110.h,
                    width: 120.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/cara4.png',
                        height: 110.h,
                        width: 120.w,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    'assets/images/cara4.png',
                    height: 110.h,
                    width: 120.w,
                    fit: BoxFit.cover,
                  ),
          ),
          SizedBox(height: 8.h),
          Text(
  finalTitle.toUpperCase(),
  style: TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    //fontFamily: 'Roboto'
  ),
  textAlign: TextAlign.center,
),

        ],
      ),
    );
  }
}
