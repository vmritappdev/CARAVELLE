import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ZoomOrderScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  ZoomOrderScreen({required this.order});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Order Details',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
            ),
          ),
          leading: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, 
                color: Colors.black, 
                size: 20.w
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 16.w),
              decoration: BoxDecoration(
            //    color: Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextButton(
                onPressed: () {},
                child: Text(
                  "Help",
                  style: TextStyle(
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Card
              _buildProductCard(),
              
              SizedBox(height: 16.h),

              // Flipkart Style Delivery Status
              _buildFlipkartDeliveryStatus(),

              SizedBox(height: 16.h),

              // See All Updates Button
              _buildSeeAllUpdates(),

              SizedBox(height: 16.h),

              // Rate Your Experience
              _buildRateExperience(),

              SizedBox(height: 16.h),

              // Offer Card
           //   _buildOfferCard(),

              SizedBox(height: 24.h),

              // Delivery Address Section
              _buildSectionHeader("Delivery Address", Icons.location_on_outlined),
              SizedBox(height: 12.h),
              _buildAddressCard(),

              SizedBox(height: 24.h),

              // Price Details Section
              _buildSectionHeader("Price Breakdown", Icons.receipt_long_outlined),
              SizedBox(height: 12.h),
              _buildPriceDetails(),

              SizedBox(height: 24.h),

              // Payment & Invoice Section
            //  _buildSectionHeader("Payment & Method", Icons.payment_outlined),
             // SizedBox(height: 12.h),
             // _buildPaymentSection(),

              SizedBox(height: 24.h),

              // Order Information
              _buildOrderInfo(),

              SizedBox(height: 32.h),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Color(0xFF1976D2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 18.w, color: Color(0xFF1976D2)),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              image: DecorationImage(
                image: AssetImage(order['image'] ?? 'assets/images/default.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['productName'] ?? 'Mangalsutra ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '60 grms',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlipkartDeliveryStatus() {
    return Container(
      width: double.infinity,
    //  padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pay Online Message
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16.w, color: Color(0xFF1976D2)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    "Pay online for a smooth doorstep experience",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Color(0xFF1976D2),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    "Pay ₹879",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Order Confirmed Section
          Align(
            alignment: Alignment.center,
            child: Text(
              "Order Confirmed",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Align(
             alignment: Alignment.center,
            child: Text(
              "Your Order has been placed.",
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[600],
              ),
            ),
          ),

          SizedBox(height: 16.h),
_buildOrderTracker(),
          // Progress Dots
         
         // SizedBox(height: 8.h),

          // Status Labels
       
        ],
      ),
    );
  }

 

 

  Widget _buildSeeAllUpdates() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "See all updates",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 16.w, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Widget _buildRateExperience() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rate your experience",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "Did you find this page helpful?",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildEmojiButton("😊"),
              SizedBox(width: 12.w),
              _buildEmojiButton("😐"),
              SizedBox(width: 12.w),
              _buildEmojiButton("😞"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiButton(String emoji) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        emoji,
        style: TextStyle(fontSize: 18.sp),
      ),
    );
  }

 
  Widget _buildAddressCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.person_outline, size: 20.w, color: Colors.grey[600]),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['customer'] ?? 'Customer Name',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      order['phone'] ?? '+91 XXXXXXXXXX',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.home_outlined, size: 20.w, color: Colors.grey[600]),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  order['address'] ?? 'Delivery address not available',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetails() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _buildPriceRow("Listing Price", order['listingPrice'] ?? "₹0", Colors.grey[700]!),
          _buildPriceRow("Selling Price", order['sellingPrice'] ?? "₹0", Colors.grey[700]!),
          _buildPriceRow("Extra Discount", order['discount'] ?? "-₹0", Color(0xFF4CAF50)),
          _buildPriceRow("Special Price", order['specialPrice'] ?? "₹0", Colors.grey[700]!),
          _buildPriceRow("Total Fees", order['fees'] ?? "₹0", Colors.grey[700]!),
          SizedBox(height: 8.h),
          Divider(height: 1, color: Colors.grey[200]),
          SizedBox(height: 12.h),
          _buildPriceRow("Total Amount", order['total'] ?? "₹0", Colors.black87, isBold: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String title, String value, Color color, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16.sp : 14.sp,
              color: color,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildOrderTracker() {
    final stages = [
      _TrackerStage('Order Placed', 'Oct 22', true, true),
      _TrackerStage('Order Accepted', 'Oct 24', true, false),
      _TrackerStage('Send To Factory', 'Oct 26', false, false),
      _TrackerStage('Order Completed', 'Oct 28', false, false),
      _TrackerStage('Delivered', 'Oct 28', false, false),
    ];

    return Column(
      children: [
        // Progress line with circles
        Container(
          height: 30,
          padding: EdgeInsets.symmetric(horizontal: 8), // Added padding to prevent overflow
          child: Stack(
            children: [
              // Background line
              Positioned(
                left: 15,
                right: 15,
                top: 14,
                child: Container(
                  height: 2,
                  color: Color(0xFFE0E0E0),
                ),
              ),
              // Progress line
              Positioned(
                left: 15,
                right: 15,
                top: 14,
                child: Container(
                  height: 2,
                  color: AppTheme.primaryColor,
                ),
              ),
              // Stage circles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: stages.map((stage) {
                  return _buildStageCircle(stage);
                }).toList(),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        // Stage labels - Fixed width with smaller font
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: stages.map((stage) {
              return _buildStageLabel(stage);
            }).toList(),
          ),
        ),
        SizedBox(height: 10),
        // Stage dates - Fixed width with smaller font
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: stages.map((stage) {
              return _buildStageDate(stage);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStageCircle(_TrackerStage stage) {
    return Container(
      width: 24, // Reduced from 30
      height: 24, // Reduced from 30
      decoration: BoxDecoration(
        color: stage.isCompleted || stage.isActive ?AppTheme.primaryColor : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: stage.isCompleted || stage.isActive ? AppTheme.primaryColor : Color(0xFFE0E0E0),
          width: 2,
        ),
      ),
      child: stage.isCompleted
          ? Icon(
              Icons.check,
              color: Colors.white,
              size: 14, // Reduced from 16
            )
          : stage.isActive
              ? Container(
                  margin: EdgeInsets.all(4), // Reduced from 6
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
    );
  }

  Widget _buildStageLabel(_TrackerStage stage) {
    return Container(
      width: 60, // Reduced from 70
      child: Text(
        stage.label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10, // Reduced from 12
          fontWeight: FontWeight.w500,
          color: stage.isCompleted || stage.isActive ? AppTheme.primaryColor : Colors.black,
        ),
        maxLines: 2, // Allow text to wrap
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStageDate(_TrackerStage stage) {
    return Container(
      width: 60, // Reduced from 70
      child: Text(
        stage.date,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 9, // Reduced from 11
          color: Color(0xFF878787),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }


  Widget _buildOrderInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Information",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order ID",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      order['orderNumber'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.copy_rounded, size: 16.w, color: Color(0xFF1976D2)),
                    SizedBox(width: 6.w),
                    Text(
                      "Copy",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Color(0xFF1976D2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              side: BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              "Shop More from Caravelle",
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrackerStage {
  final String label;
  final String date;
  final bool isCompleted;
  final bool isActive;

  _TrackerStage(this.label, this.date, this.isCompleted, this.isActive);
}