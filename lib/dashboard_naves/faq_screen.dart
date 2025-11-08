import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQScreen extends StatelessWidget {



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


  final List<Map<String, String>> faqs = [
    {
      "question": "What is the Gold Saving Scheme?",
      "answer":
          "The Gold Saving Scheme allows customers to save monthly and purchase gold jewellery at the end of the scheme period with attractive benefits and discounts."
    },
    {
      "question": "How can I join the scheme?",
      "answer":
          "You can join by visiting any of our CSC Jewellers showrooms or through our official app by completing a simple registration process."
    },
    {
      "question": "Is my money safe with CSC Jewellers?",
      "answer":
          "Yes, your investment is 100% safe. CSC Jewellers is a trusted and reputed brand with transparent processes and secured payment systems."
    },
    {
      "question": "Can I pay my installment online?",
      "answer":
          "Yes, you can make your monthly installment payments easily through our mobile app using UPI, net banking, or card payments."
    },
    {
      "question": "When can I redeem my scheme?",
      "answer":
          "You can redeem your scheme at the end of the tenure and purchase gold jewellery of your choice from any CSC Jewellers showroom."
    },

    {
      "question": "Is my money safe with CSC Jewellers?",
      "answer":
          "Yes, your investment is 100% safe. CSC Jewellers is a trusted and reputed brand with transparent processes and secured payment systems."
    },
    {
      "question": "Can I pay my installment online?",
      "answer":
          "Yes, you can make your monthly installment payments easily through our mobile app using UPI, net banking, or card payments."
    },
    {
      "question": "When can I redeem my scheme?",
      "answer":
          "You can redeem your scheme at the end of the tenure and purchase gold jewellery of your choice from any CSC Jewellers showroom."
    },
  ];



  

  @override
Widget build(BuildContext context) {
  return SafeArea(
    child: Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          "FAQs",
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            fontSize: AppTheme.headerSize.sp,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // FAQs list
            Expanded(
              child: ListView.builder(
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  final item = faqs[index];
                  return _buildFAQCard(item["question"]!, item["answer"]!);
                },
              ),
            ),
            
            // Chat Button
            Container(
              width: double.infinity,
              height: 50.h,
              margin: EdgeInsets.symmetric(vertical: 8.h),
              child: ElevatedButton.icon(
                onPressed: openWhatsApp,
                icon: Icon(Icons.chat, color: Colors.white),
                label: Text(
                  "Chat with us",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    ),
  );
}

  Widget _buildFAQCard(String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          childrenPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          title: Text(
            question,
            style: GoogleFonts.lato(
              fontSize: AppTheme.subHeaderSize.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C2C2C),
            ),
          ),
          iconColor: AppTheme.primaryColor,
          collapsedIconColor: AppTheme.primaryColor,
          children: [
            Divider(color: Colors.grey.shade300, height: 1),
            SizedBox(height: 6.h),
            Text(
              answer,
              style: GoogleFonts.roboto(
                fontSize: 14.sp,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }



  
}
