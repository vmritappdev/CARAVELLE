
import 'package:caravelle/dashboard_naves/bankdetails_screen.dart';
import 'package:caravelle/dashboard_naves/cart_screen.dart';
import 'package:caravelle/dashboard_naves/contact_us.dart';
import 'package:caravelle/dashboard_naves/faq_screen.dart';
import 'package:caravelle/dashboard_naves/order_screen.dart';
import 'package:caravelle/dashboard_naves/whislist_screen.dart' hide CartScreen;
import 'package:caravelle/edit_screns/company_edit.dart';
import 'package:caravelle/edit_screns/custmer_edit.dart';


import 'package:caravelle/screens/login_screen.dart';
import 'package:caravelle/screens/mobile_otp.dart';
import 'package:caravelle/screens/termsandconditon.dart';
import 'package:caravelle/uittility/app_theme.dart';
import 'package:caravelle/uittility/conasthan_api.dart' as Utility;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}





class _AccountScreenState extends State<AccountScreen> {

  bool? isValid; // null = still loading

  @override
  void initState() {
    super.initState();
    checkValidityOnce();
  }

  Future<void> checkValidityOnce() async {
    final result = await Utility.fetchValidityStatus();
    if (!mounted) return;
    setState(() {
      isValid = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30.h),
              // Header Section
              _buildHeaderSection(),

                SizedBox(height: 20,),
              

          
              // Menu Items Section
  _buildMenuSection(context, isValid ?? false),


              SizedBox(height: 20,),
              
            
            // 👇 Conditionally show this only when validity is expired
              if (isValid == true) _buildRecentlyViewedStores(),
              
              // Account Settings Section
              _buildAccountSettingsSection(context),



             SizedBox(height: 10.h),

// 🔐 Change Password Button
Padding(
  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 8.h),
  child: SizedBox(
    width: double.infinity,
    height: 50.h,
    child: ElevatedButton.icon(
      onPressed: () {
      Navigator.push(context, 
      MaterialPageRoute(builder: (context) => MobileNumberScreen())
      );
      },
      icon: Icon(
        Icons.lock_outline,
        color: Colors.white,
        size: 20.sp,
      ),
      label: Text(
        "Change Password",
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor, // ✅ teal background for difference
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        elevation: 0,
      ),
    ),
  ),
),

// 🚪 Logout Button
Padding(
  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 8.h),
  child: SizedBox(
    width: double.infinity,
    height: 50.h,
    child: ElevatedButton.icon(
      onPressed: () => logout(context),
      icon: Icon(
        Icons.logout,
        color: Colors.white,
        size: 20.sp,
      ),
      label: Text(
        "Logout",
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red, // red background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        elevation: 0,
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

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: Colors.blue.shade100,
               // backgroundImage: AssetImage('assets/images/caravelle.png'), // Add your asset image
                child: Icon(
                  Icons.person,
                  size: 30.sp,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Baddika Surekha',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Plus Silver valid till February 20, 2026',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '147 saved with Plus membership',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
        Container(
  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
  decoration: BoxDecoration(
    color: Color(0xFFE8F5E8),
    borderRadius: BorderRadius.circular(8.r),
    border: Border.all(color: Color(0xFFC8E6C9)),
  ),
  child: Row(
    children: [
      Icon(
        Icons.card_giftcard,
        color: Color(0xFF2E7D32),
        size: 18.sp,
      ),
      SizedBox(width: 10.w),
      Expanded(
        child: Text(
          'Your Reward Points',
          style: TextStyle(
            fontSize: 14.sp,
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Text(
        '200',
        style: TextStyle(
          fontSize: 15.sp,
          color: Color(0xFF2E7D32),
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(width: 8.w),
      Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF2E7D32),
        size: 18.sp,
      ),
    ],
  ),
)
        ],
      ),
    );
  }

Widget _buildMenuSection(BuildContext context, bool isValid) {
  // ✅ Base menu items (always visible)
  final menuItems = [
    _MenuItem('Orders', Icons.shopping_bag_outlined, screen: OrdersScreen()),
    _MenuItem('Help Center', Icons.help_outline, screen: ContactUsScreen()),
  ];

  // ✅ Add Wishlist & Cart only if scheme is valid
  if (isValid) {
    menuItems.insertAll(1, [
      _MenuItem('Wishlist', Icons.favorite_border, screen: WishlistScreen()),
      _MenuItem('Cart', Icons.shopping_cart_outlined, screen: CartScreen()),
    ]);
  }

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuItems.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // two per row
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 3.9,
      ),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuBox(context, item);
      },
    ),
  );
}


Widget _buildMenuBox(BuildContext context, _MenuItem item) {
  return GestureDetector(
    onTap: () {
      if (item.screen != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => item.screen!),
        );
      }
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: AppTheme.primaryColor, size: 20.sp),
          SizedBox(width: 6.w),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}

 Widget _buildMenuItem(BuildContext context, _MenuItem item) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {
        if (item.screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => item.screen!),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(item.icon, size: 22.sp, color: Colors.grey.shade700),
            SizedBox(width: 16.w),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16.sp, color: Colors.grey.shade500),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildRecentlyViewedStores() {
    // Sample store data with asset images
    final List<StoreItem> stores = [
      StoreItem('Nike Store', 'assets/images/cara3.png', 'Sports & Shoes'),
      StoreItem('Apple Store', 'assets/images/cara4.png', 'Electronics'),
      StoreItem('Zara Fashion', 'assets/images/cara2.png', 'Clothing'),
      StoreItem('Adidas', 'assets/images/cara3.png', 'Sports Wear'),
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8.w, bottom: 12.h),
            child: Text(
              'Recently Viewed Stores',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: 140.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: stores.length,
              itemBuilder: (context, index) {
                return _buildStoreCard(stores[index]);
              },
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildStoreCard(StoreItem store) {
    return Container(
      width: 140.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Store Image
          Container(
            height: 140.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
              image: DecorationImage(
                image: AssetImage(store.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Store Info
          Expanded(
        
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    store.category,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildAccountSettingsSection(BuildContext context) {
  final accountItems = [
    _MenuItem('Bank Details', Icons.food_bank, screen: BankDetailsScreen()),
    _MenuItem('Edit Profile', Icons.edit_outlined, screen: EditCompanyScreen()),
     _MenuItem('Edit Profile', Icons.edit_outlined, screen: EditCustomerScreen()),
    _MenuItem('Terms & Policies', Icons.description_outlined, screen: TermsAndConditionsScreen()),
    _MenuItem('FAQ', Icons.help_outline, screen: FAQScreen()),
    _MenuItem('Contact Us', Icons.phone_outlined, screen: ContactUsScreen()),
  ];

  return Container(
    margin: EdgeInsets.all(16.w),
    padding: EdgeInsets.symmetric(vertical: 8.h),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(
                Icons.account_circle_outlined,
                size: 20.sp,
                color: Colors.grey.shade700,
              ),
              SizedBox(width: 12.w),
              Text(
                'Account',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey.shade300),
        // ✅ Pass context here
        ...accountItems.map((item) => _buildMenuItem(context, item)).toList(),



         
      ],
    ),
  );
}

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  // Clear all user data
  await prefs.clear();

  // Make sure Terms screen won't show again
 await prefs.setBool('accepted_terms', true);


  // Navigate to LoginPage directly
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        useInheritedMediaQuery: true,
        builder: (context, child) => const LoginPage(),
      ),
    ),
    (route) => false,
  );
}

}

class _MenuItem {
  final String title;
  final IconData icon;
  final Widget? screen; // optional screen to navigate

  _MenuItem(this.title, this.icon, {this.screen});
}





class StoreItem {
  final String name;
  final String imagePath;
  final String category;

  StoreItem(this.name, this.imagePath, this.category);
}