import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:caravelle/uittility/app_theme.dart';

class ContactUsScreen extends StatelessWidget {
  final String phone = "6304225677";
  final String email = "info@cscjewellers.com";
  final String address = "Caravelle Jewellers, 123, MG Road, Hyderabad, Telangana, India";

  void openWhatsApp() {
  const phone = '9493206613';
  const message = 'Hi, I want to login';
  
  final intent = AndroidIntent(
    action: 'action_view',
    data: Uri.encodeFull('https://wa.me/$phone?text=$message'),
    package: 'com.whatsapp',
    flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
  );
  intent.launch();
}

  void openEmail() async {
    final url = Uri.parse("mailto:$email");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "Contact Us",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20.sp,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Get in Touch",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "We would love to hear from you! Reach out for queries, support, or feedback.",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 30.h),
              _buildContactCard(
                icon: Icons.phone_outlined,
                title: "Call Us",
                subtitle: phone,
                onTap: () => launchUrl(Uri.parse("tel:$phone")),
              ),
              SizedBox(height: 16.h),
              _buildContactCard(
                icon: Icons.mail_outline,
                title: "Email Us",
                subtitle: email,
                onTap: openEmail,
              ),
              SizedBox(height: 16.h),
              _buildContactCard(
                icon: Icons.location_on_outlined,
                title: "Visit Us",
                subtitle: address,
                onTap: () {}, // could open map if needed
              ),
              Spacer(),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton.icon(
                    onPressed: openWhatsApp,
                    icon: Icon(Icons.chat, color: Colors.white, size: 20.w),
                    label: Text(
                      "Chat with us",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 24.w),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.w, color: Colors.grey.shade400)
          ],
        ),
      ),
    );
  }
}
