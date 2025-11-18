import 'dart:io';
import 'package:caravelle/screens/login_screen.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:shared_preferences/shared_preferences.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  bool _isAccepted = false;
  bool _isLoading = false;

  Future<void> _handleAccept() async {
    if (!_isAccepted) return;
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('accepted_terms', true); // ✅ Save flag

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

 final List<String> _termsList = [
  "This page contains the terms & conditions. Please read these terms & conditions carefully before ordering any products from us. You should understand that by ordering any of our products, you agree to be bound by these terms & conditions.",
  "By ordering any of our products, you agree to be bound by these terms & conditions.",
  "All personal information you provide us with or that we obtain will be handled by Caravelle as responsible for the personal information.",
  "Events outside Caravelle's control shall be considered force majeure.",
  "The price applicable is that set at the date on which you place your order.",
  "Caravelle reserves the right to amend any information without prior notice.",
  "Personal Information: All personal information you provide us with or that we obtain will be handled by Caravelle as responsible for the personal information. The personal information you provide will be used to ensure deliveries to you, the credit assessment, to provide offers and information on our catalog to you. The information you provide is only available to Caravelle and will not be shared with other third parties. You have the right to inspect the information held about you. You always have the right to request Caravelle to delete or correct the information held about you. By accepting the Caravelle Conditions, you agree to the above.",
  "Force Majeure: Events outside Caravelle's control, which is not reasonably foreseeable, shall be considered force majeure, meaning that Caravelle is released from its obligations to fulfill contractual agreements. Examples of such events are government action or omission, new or amended legislation, conflict, embargo, fire or flood, sabotage, accident, war, natural disasters, strikes or lack of delivery from suppliers. The force majeure also includes government decisions that affect the market negatively and products, for example, restrictions, warnings, ban, etc.",
  "Cookies: Caravelle uses cookies according to the new Electronic Communications Act, which came into force on 25 July 2003. A cookie is a small text file stored on your computer that contains information that helps the website identify and track the visitor. Cookies do no harm to your computer, consist only of text, cannot contain viruses and occupy virtually no space on your hard drive. There are two types of cookies: 'Session Cookies' and cookies that are saved permanently on your computer.",
  "The first type, 'Session Cookies', is assigned a unique identifier during your visit to distinguish you from other visitors. These are deleted when you close your browser.",
  "The second type of cookie saves a file permanently on your computer. This is used to track visitor behavior and improve user experience. On Caravelle we use this type to keep track of your shopping cart and visitor statistics. The stored information is only a unique number, without any personal data.",
  "Additional Information: Caravelle reserves the right to amend any information, including but not limited to technical specifications, terms of purchase and product offerings without prior notice. If a product is sold out, Caravelle has the right to cancel the order and will notify the customer of equivalent replacement products if available.",
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildCompactHeader(),
            Expanded(child: _buildCompactContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description_outlined, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Terms & Conditions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Review before proceeding",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: AppTheme.primaryColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Explore our wide range of jewellery products by accepting the Terms & Conditions.",
                    style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _termsList.length,
                itemBuilder: (context, index) {
                  return _buildCompactTermItem(index + 1, _termsList[index]);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildCompactAcceptanceSection(),
        ],
      ),
    );
  }

  Widget _buildCompactTermItem(int number, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "$number",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 11, color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactAcceptanceSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Checkbox(
                value: _isAccepted,
                onChanged: _isLoading
                    ? null
                    : (val) => setState(() => _isAccepted = val ?? false),
                activeColor: AppTheme.primaryColor,
                side: BorderSide(color: AppTheme.primaryColor, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Text(
                  "I agree to the Terms & Conditions",
                  style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 140.w,
              height: 50.h,
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                        content: Text(
                          "You must accept Terms & Conditions to enter the app.",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("No", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
                          ),
                          TextButton(
                            onPressed: () => exit(0),
                            child: Text("Yes", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0,
                ),
                child: Text("Decline", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
              ),
            ),
            SizedBox(
              width: 140.w,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _isLoading || !_isAccepted ? null : _handleAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAccepted ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  elevation: 4,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text("Continue", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp, color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
