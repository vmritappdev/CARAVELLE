// screens/view_all_products_screen.dart
import 'dart:convert';
import 'package:caravelle/model/product_model.dart';
import 'package:caravelle/uittility/conasthan_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:http/http.dart' as http;

class ViewAllProductsScreen extends StatefulWidget {
  const ViewAllProductsScreen({Key? key}) : super(key: key);

  @override
  State<ViewAllProductsScreen> createState() => _ViewAllProductsScreenState();
}

class _ViewAllProductsScreenState extends State<ViewAllProductsScreen> {
  List<Product> products = [];
  bool isGridView = true;
  bool isLoading = true;

  Future<void> _fetchProducts() async {
    const apiUrl = "https://caravelle.in/barcode/app/no_access_products.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'token': token},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map && data.containsKey('total_data')) {
          final List<dynamic> list = data['total_data'] ?? [];

          setState(() {
            products = list.map<Product>((item) {
              return Product(
                id: item['id']?.toString() ?? '',
                name: item['product']?.toString() ?? '',
                subProduct: item['sub_product']?.toString() ?? '',
                design: item['design']?.toString() ?? '',
                image: item['image_url']?.toString() ?? '',
                grossWeight: double.tryParse(item['gross']?.toString() ?? '0') ?? 0,
                netWeight: double.tryParse(item['net']?.toString() ?? '0') ?? 0,
                stoneCount: double.tryParse(item['stone']?.toString() ?? '0')?.round() ?? 0,
                wight: double.tryParse(item['other_wt']?.toString() ?? '0')?.round() ?? 0,
                tagno: item['barcode']?.toString() ?? '',
                amount: double.tryParse(item['amount']?.toString() ?? '0') ?? 0,
                status: item['status']?.toString() ?? '',
              );
            }).toList();
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("🔥 Error fetching products: $e");
      setState(() => isLoading = false);
    }
  }

  // ✅ Image Click Function - Big Image with Details
  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Big Image
                Container(
                  height: 250.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.grey.shade100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      product.image.isNotEmpty ? product.image : 'https://caravelle.in/barcode/images/no_image.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.photo, size: 60.w, color: Colors.grey.shade400),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Product Name
                Text(
                  _getFullName(product),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),

                // Status
                _buildStatusBadge(product.status),
                SizedBox(height: 20.h),

                // Product Details
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                  //    _buildDetailRow("Product ID", product.id),
                      SizedBox(height: 8.h),
                      _buildDetailRow("Gross Weight", "${product.grossWeight} g"),
                      SizedBox(height: 8.h),
                      _buildDetailRow("Net Weight", "${product.netWeight} g"),
                      SizedBox(height: 8.h),
                      _buildDetailRow("Stone Count", "${product.stoneCount}"),
                      SizedBox(height: 8.h),
                   //   _buildDetailRow("Stone Weight", "${product.wight.toStringAsFixed(2)} g"),
                      SizedBox(height: 8.h),
                      _buildDetailRow("Tag No", product.tagno),
                      SizedBox(height: 8.h),
                    //  _buildDetailRow("Amount", "₹${product.amount.toStringAsFixed(2)}"),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      "Close",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Detail Row for Modal
  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildViewToggle(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (isGridView ? _buildGridView() : _buildListView()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, size: 22.w, color: Colors.black),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: 12.w),
          Text(
            "All Products",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Text(
            "${products.length} items",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.grid_view, color: isGridView ? Colors.blue : Colors.grey),
            onPressed: () => setState(() => isGridView = true),
          ),
          IconButton(
            icon: Icon(Icons.list, color: !isGridView ? Colors.blue : Colors.grey),
            onPressed: () => setState(() => isGridView = false),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(products[index]),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductListItem(products[index]),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => _showProductDetails(product), // ✅ Image click functionality
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Status Badge
            Stack(
              children: [
                Container(
                  height: 120.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
                    color: Colors.grey.shade100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
                    child: Image.network(
                      product.image.isNotEmpty ? product.image : 'https://caravelle.in/barcode/images/no_image.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.photo, size: 40.w, color: Colors.grey.shade400),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: _buildStatusBadge(product.status),
                ),
              ],
            ),

            // Details
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getShortName(product),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  _buildSimpleRow("Gross", "${product.grossWeight}g"),
                  _buildSimpleRow(
                    "Stone",
                    "${product.stoneCount} (${product.wight.toStringAsFixed(2)} g)",
                  ),
                  _buildSimpleRow("Net", "${product.netWeight}g"),
                  _buildSimpleRow("Tag No", product.tagno),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductListItem(Product product) {
    return GestureDetector(
      onTap: () => _showProductDetails(product), // ✅ Image click functionality
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            // Image with Status Badge
            Stack(
              children: [
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(8.r)),
                    color: Colors.grey.shade100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(8.r)),
                    child: Image.network(
                      product.image.isNotEmpty ? product.image : 'https://caravelle.in/barcode/images/no_image.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.photo, size: 24.w, color: Colors.grey.shade400),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 4.h,
                  left: 4.w,
                  child: _buildStatusBadge(product.status),
                ),
              ],
            ),

            // Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getShortName(product),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 8.w,
                      children: [
                        _buildSimpleChip("Gross: ${product.grossWeight}g"),
                        _buildSimpleChip("Stone: ${product.stoneCount}"),
                        _buildSimpleChip("Net: ${product.netWeight}g"),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Tag: ${product.tagno}",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Status Badge Widget
  Widget _buildStatusBadge(String status) {
    final isInStock = status.toUpperCase() == "ACTIVE";
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isInStock ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(4.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        isInStock ? "In Stock" : "Out of Stock",
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSimpleRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  String _getShortName(Product p) {
    String name = p.name;
    if (p.subProduct.isNotEmpty && p.subProduct != "null") {
      name += " (${p.subProduct})";
    }
    return name;
  }

  String _getFullName(Product p) {
    String name = p.name;
    if (p.subProduct.isNotEmpty && p.subProduct != "null") {
      name += " (${p.subProduct})";
    }
    if (p.design.isNotEmpty && p.design != "null") {
      name += " - ${p.design}";
    }
    return name;
  }
}