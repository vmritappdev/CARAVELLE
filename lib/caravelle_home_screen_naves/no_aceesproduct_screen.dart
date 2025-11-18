import 'package:caravelle/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header - Only back button and title
            _buildHeader(),
            
            // Product Image and Details
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildProductImage(),
                    _buildProductDetails(),
                  ],
                ),
              ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                size: 18.w,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            "Product Details",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          // Removed wishlist button
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 400.h,
      width: double.infinity,
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Image.asset(
          widget.product.image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags Row - Gross, Net, Stones, Purity, Code
          _buildProductTags(),
          
          SizedBox(height: 20.h),
          
          // Product Name
          Text(
            widget.product.name,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          
          SizedBox(height: 8.h),
          
          // Product Category
          Text(
            widget.product.category,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // Product Specifications
          _buildProductSpecifications(),
          
          SizedBox(height: 20.h),
          
          // Description
          _buildDescriptionSection(),
          
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildProductTags() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        // NEW Tag
        if (widget.product.isNew)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              "NEW",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        
        // Gross Weight
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.purple.shade100),
          ),
          child: Text(
            "GROSS: ${widget.product.grossWeight}g",
            style: TextStyle(
              color: Colors.purple.shade800,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Net Weight
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Text(
            "NET: ${widget.product.netWeight}g",
            style: TextStyle(
              color: Colors.blue.shade800,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Stone Count
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.orange.shade100),
          ),
          child: Text(
            "STONES: ${widget.product.stoneCount}",
            style: TextStyle(
              color: Colors.orange.shade800,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Purity
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Text(
            "PURITY: ${widget.product.tagno}",
            style: TextStyle(
              color: Colors.green.shade800,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Product Code
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.teal.shade100),
          ),
          child: Text(
            "CODE: ${widget.product.productCode}",
            style: TextStyle(
              color: Colors.teal.shade800,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductSpecifications() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Product Specifications",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Specifications in a clean layout
          _buildSpecificationRow("Product Name", widget.product.name),
          _buildSpecificationRow("Category", widget.product.category),
          _buildSpecificationRow("Product Code", widget.product.productCode),
          _buildSpecificationRow("Gold Purity", widget.product.tagno),
          _buildSpecificationRow("Gross Weight", "${widget.product.grossWeight} grams"),
          _buildSpecificationRow("Net Weight", "${widget.product.netWeight} grams"),
          _buildSpecificationRow("Stone Count", "${widget.product.stoneCount} stones"),
        ],
      ),
    );
  }

  Widget _buildSpecificationRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Product Description",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        
        SizedBox(height: 12.h),
        
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            widget.product.description,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade800,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}