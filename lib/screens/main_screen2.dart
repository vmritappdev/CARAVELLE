import 'package:caravelle/dashboard_naves/accountscreen.dart';
import 'package:caravelle/dashboard_naves/cart_screen.dart';
import 'package:caravelle/dashboard_naves/whislist_screen.dart' hide CartScreen;
import 'package:caravelle/screens/caravelle_home2.dart';
import 'package:caravelle/screens/categories_screen.dart';

import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ==================== MAIN SCREEN ====================
class MainScreen2 extends StatefulWidget {
  const MainScreen2({super.key});
  @override
  State<MainScreen2> createState() => _MainScreen2State();
}

class _MainScreen2State extends State<MainScreen2> {
  int _currentIndex = 0;

  // Screens
  final List<Widget> _screens = [
    const CaravelleHomeScreen2(),
    const AccountScreen(),
    const CategoriesScreen(),
    CartScreen(),
    WishlistScreen(),
  ];

  // Bottom nav item builder
  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.amber.shade200 : const Color.fromARGB(255, 246, 245, 245),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.amber.shade200 : const Color.fromARGB(255, 249, 246, 246),
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            // Selected underline
            if (isSelected)
              Container(
                height: 2.h, // thickness of underline
                width: 20.w, // width of underline
                decoration: BoxDecoration(
                  color: Colors.amber.shade200,
                  borderRadius: BorderRadius.circular(1.r),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
     onWillPop: () async {
      if (_currentIndex != 0) {
        // If not home screen, navigate to home
        setState(() => _currentIndex = 0);
        return false; // prevent app exit
      } else {
        // If home screen, show exit confirmation
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exit App"),
            content: const Text("Are you sure you want to exit the app?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // do not exit
                child: const Text("No"),
              ),
              TextButton(
              onPressed: () => Navigator.of(context).pop(true), // exit
                child: const Text("Yes"),
              ),
            ],
          ),
        );
        return shouldExit ?? false; // return true if user pressed yes
      }
    },
      child: SafeArea(
        child: Scaffold(
          body: IndexedStack(index: _currentIndex, children: _screens),
          bottomNavigationBar: Container(
            height: 70.h,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -3))],
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(Icons.home, "Home", 0),
                  _buildNavItem(Icons.favorite, "Wishlist", 4),
                  _buildNavItem(Icons.category, "Categories", 2),
                  _buildNavItem(Icons.shopping_cart, "Cart", 3),
                  _buildNavItem(Icons.person, "Account", 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
