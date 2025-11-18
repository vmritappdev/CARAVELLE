import 'package:caravelle/dashboard_naves/accountscreen.dart';
import 'package:caravelle/dashboard_naves/cart_screen.dart';
import 'package:caravelle/dashboard_naves/whislist_screen.dart' hide CartScreen;
import 'package:caravelle/screens/categories_screen.dart';
import 'package:caravelle/screens/caravelle_homescreen.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // FIXED ORDER OF SCREENS — EXACTLY MATCHING THE BOTTOM NAVIGATION
  final List<Widget> _screens = [
    const CaravelleHomeScreen(), // 0
    WishlistScreen(),            // 1
    const CategoriesScreen(),    // 2
    CartScreen(),                // 3
    const AccountScreen(),       // 4
  ];

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
              color: isSelected ? Colors.amber.shade200 : Colors.white,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.amber.shade200 : Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            if (isSelected)
              Container(
                height: 2.h,
                width: 20.w,
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
    return SafeArea(
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),

        bottomNavigationBar: Container(
          height: 70.h,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -3))
            ],
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(Icons.home, "Home", 0),
                _buildNavItem(Icons.favorite, "Wishlist", 1),
                _buildNavItem(Icons.category, "Categories", 2),
                _buildNavItem(Icons.shopping_cart, "Cart", 3),
                _buildNavItem(Icons.person, "Account", 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
