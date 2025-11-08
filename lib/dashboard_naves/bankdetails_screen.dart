import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

class BankDetailsScreen extends StatelessWidget {
  const BankDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            'Bank Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primaryColor, AppTheme.primaryColor],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance,
                        size: 40.w,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Caravelle Jewelers',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Official Bank Account Details',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
      
              // Bank Information
              Text(
                'Bank Information',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 16.h),
      
              _buildInfoCard(
                context: context,
                icon: Icons.account_balance,
                title: 'Bank Name',
                value: 'State Bank of India',
                showCopy: true
              ),
              _buildInfoCard(
                context: context,
                icon: Icons.credit_card,
                title: 'Account Number',
                value: '32456789012345',
                showCopy: true,
              ),
              _buildInfoCard(
                context: context,
                icon: Icons.code,
                title: 'IFSC Code',
                value: 'SBIN0003245',
                showCopy: true,
              ),
              _buildInfoCard(
                context: context,
                icon: Icons.business,
                title: 'Branch',
                value: 'Jewellery Street, Hyderabad',
              ),
              _buildInfoCard(
                context: context,
                icon: Icons.person,
                title: 'Account Name',
                value: 'Caravelle Jewelers Pvt. Ltd.',
              ),
              _buildInfoCard(
                context: context,
                icon: Icons.account_balance_wallet,
                title: 'Account Type',
                value: 'Current Account',
              ),
      
              SizedBox(height: 24.h),
      
              // UPI Information
              Text(
                'UPI Payment',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 16.h),
      
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.qr_code,
                          size: 24.w,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'UPI ID',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'caravelle.jewelers@oksbi',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _copyToClipboard('caravelle.jewelers@oksbi');
                                    _showSnackBar(context, 'UPI ID copied to clipboard');
                                  },
                                  icon: Icon(
                                    Icons.copy,
                                    size: 18.w,
                                    color: AppTheme.primaryColor,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(
                                    minWidth: 36.w,
                                    minHeight: 36.w,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      
              SizedBox(height: 24.h),
      
              // Important Instructions
              Text(
                'Important Instructions',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
              SizedBox(height: 12.h),
      
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                color: Colors.orange.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInstruction(
                        '✓ Always include your Order ID in payment remarks',
                      ),
                      SizedBox(height: 8.h),
                      _buildInstruction(
                        '✓ Payments will be verified within 2-4 hours',
                      ),
                      SizedBox(height: 8.h),
                      _buildInstruction(
                        '✓ Keep transaction details for future reference',
                      ),
                      SizedBox(height: 8.h),
                      _buildInstruction(
                        '✓ Contact support for any payment issues',
                      ),
                      SizedBox(height: 8.h),
                      _buildInstruction(
                        '✓ Do not share OTP or password with anyone',
                      ),
                    ],
                  ),
                ),
              ),
      
              SizedBox(height: 24.h),
      
              // Contact Information
              Text(
                'Contact Support',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 16.h),
      
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 20.w,
                            color: Colors.green.shade700,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Phone Number',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  '+91 98765 43210',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Implement call functionality
                            },
                            icon: Icon(
                              Icons.phone_outlined,
                              size: 20.w,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 24.h),
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            size: 20.w,
                            color: AppTheme.primaryColor,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  'accounts@caravellejewelers.com',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Implement email functionality
                            },
                            icon: Icon(
                              Icons.email_outlined,
                              size: 20.w,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      
             
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildInfoCard({
  required BuildContext context, // ⬅️ ఇది add చెయ్
  required IconData icon,
  required String title,
  required String value,
  bool showCopy = false,
}) {
  return Card(
    elevation: 2,
    margin: EdgeInsets.only(bottom: 12.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              size: 20.w,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          if (showCopy)
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: Icon(
                Icons.copy,
                size: 18.w,
                color: AppTheme.primaryColor,
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: 36.w,
                minHeight: 36.w,
              ),
            ),
        ],
      ),
    ),
  );
}
  Widget _buildInstruction(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.circle,
          size: 6.w,
          color: Colors.orange.shade700,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(String text) {
    // Implement clipboard functionality
    // You can use packages like clipboard or services
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  void _shareBankDetails(BuildContext context) {
    // Implement share functionality
    _showSnackBar(context, 'Bank details shared successfully');
  }

  void _downloadDetails(BuildContext context) {
    // Implement download functionality
    _showSnackBar(context, 'Bank details saved successfully');
  }
}