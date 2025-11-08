import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class FollowUsSection extends StatelessWidget {
  const FollowUsSection({Key? key}) : super(key: key);

  // 🔗 Helper function to open links
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 25.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15.r,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 📱 Follow Us Text
          Text(
            "Follow Us:",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: 0.8,
            ),
          ),
          
          SizedBox(width: 16.w),
          
          // 🌟 Social Media Icons
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 🌸 Instagram
                _buildSocialIcon(
                  assetPath: 'assets/images/insta.png',
                  onTap: () => _launchUrl('https://www.instagram.com/yourpage'),
                  backgroundColor: Colors.pink.shade50,
                ),
                
                // 📘 Facebook
                _buildSocialIcon(
                  assetPath: 'assets/images/fac.png',
                  onTap: () => _launchUrl('https://www.facebook.com/yourpage'),
                  backgroundColor: Colors.blue.shade50,
                ),
                
                // 💬 WhatsApp
                _buildSocialIcon(
                  assetPath: 'assets/images/what.png',
                  onTap: () => _launchUrl('https://wa.me/91XXXXXXXXXX'),
                  backgroundColor: Colors.green.shade50,
                ),
                
                // 📞 Call
                _buildSocialIcon(
                  assetPath: 'assets/images/ca.png',
                  onTap: () => _launchUrl('tel:+919876543210'),
                  backgroundColor: Colors.red.shade50,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🌟 Enhanced reusable social icon widget with original images
  Widget _buildSocialIcon({
    required String assetPath,
    required VoidCallback onTap,
    Color? backgroundColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50.r),
      splashColor: Colors.black.withOpacity(0.1),
      highlightColor: Colors.transparent,
      child: Container(
        width: 50.w,
        height: 50.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? Colors.grey.shade100,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.r,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 8.r,
              offset: const Offset(0, -2),
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 2.w,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            // Original image colors preserved
          ),
        ),
      ),
    );
  }
}