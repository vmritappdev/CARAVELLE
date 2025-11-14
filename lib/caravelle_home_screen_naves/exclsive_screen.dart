import 'dart:convert';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:http/http.dart' as http;
import 'package:caravelle/dashboard_naves/goldshop_offer.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExclusiveDesignsSection extends StatefulWidget {
  const ExclusiveDesignsSection({Key? key}) : super(key: key);

  @override
  State<ExclusiveDesignsSection> createState() => _ExclusiveDesignsSectionState();
}

class _ExclusiveDesignsSectionState extends State<ExclusiveDesignsSection> {
  List<dynamic> bestSellers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBestSellerData();
  }

  Future<void> fetchBestSellerData() async {
    final url = Uri.parse("https://caravelle.in/barcode/app/best_seller.php");

    try {
      final response = await http.post(url, body: {"token": token});

      print("🔹 API URL: $url");
      print("🔹 Sent Token: $token");
      print("🔹 Status Code: ${response.statusCode}");
      print("✅ Full Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["response"] == "success" && data["total_data"] != null) {
          setState(() {
            bestSellers = data["total_data"].take(4).toList(); // ✅ Only 4 items
            isLoading = false;
          });
        } else {
          print("⚠️ No Data Found");
          setState(() => isLoading = false);
        }
      } else {
        print("❌ Server Error: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("⚠️ Exception: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🟢 Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15.0.r),
                child: Text(
                  "✨Best Seller",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 18.0.r),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GoldShopOffersScreen(
                          mainCategory: "Exclusive Designs",
                          subCategory: "All Designs",
                          subProducts: '',
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.primaryColor],
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // 🟡 Grid Section
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : bestSellers.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          "No best sellers found.",
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 7,
                          mainAxisSpacing: 5,
                          childAspectRatio: 1.3,
                        ),
                        itemCount: bestSellers.length,
                        itemBuilder: (context, index) {
                          final item = bestSellers[index];
                          final imageUrl = item["image_url"] ?? "";
                          final subProduct = item["sub_product"];
                          final product = item["product"];
                          final design = item["design"];

                          final titleText =
                              (subProduct != null && subProduct.toString().isNotEmpty)
                                  ? subProduct
                                  : (product ?? "Unknown Product");

                          final designText = (design != null && design.toString().isNotEmpty)
                              ? " ($design)"
                              : "";

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 5,
                                  offset: const Offset(2, 3),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                // 🔹 Background Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(Icons.image_not_supported),
                                        )
                                      : Image.asset(
                                          "assets/images/cara4.png",
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                ),

                                // 🔹 Text Overlay (bottom of image)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.45),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10.r),
                                      bottomRight: Radius.circular(10.r),
                                    ),
                                  ),
                                  child: Text(
                                    "$titleText$designText",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
