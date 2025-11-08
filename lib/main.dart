import 'package:caravelle/model/cart.dart';
import 'package:caravelle/model/whishlist.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:caravelle/screens/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Cart().loadFromPrefs(); // ✅ Load cart data at startup
  await Wishlist().loadWishlist(); // ✅ Load wishlist data at startup
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // 👈 base design size (don’t change often)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Caravelle Jewellers',
          theme: ThemeData(
            primarySwatch: Colors.teal,
            fontFamily: 'Roboto',
            useMaterial3: false, // 👈 Optional, avoid text scale issues
          ),
          home: child,
        );
      },
      child:  SplashScreen2(), // ✅ child separate gaa isthe performance better
    );
  }
}
