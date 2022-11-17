import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:g_fresh/providers/auth_provider.dart';
import 'package:g_fresh/providers/cart_provider.dart';
import 'package:g_fresh/providers/coupon_provider.dart';
import 'package:g_fresh/providers/location_provider.dart';
import 'package:g_fresh/providers/store_provider.dart';
import 'package:g_fresh/screens/home_screen.dart';
import 'package:g_fresh/screens/landing_screen.dart';
import 'package:g_fresh/screens/login_screen.dart';
import 'package:g_fresh/screens/main_screen.dart';
import 'package:g_fresh/screens/map_screen.dart';
import 'package:g_fresh/screens/product_list_screen.dart';
import 'package:g_fresh/screens/profile_screen.dart';
import 'package:g_fresh/screens/profile_update_screen.dart';
import 'package:g_fresh/screens/vendor_home_screen.dart';
import 'package:g_fresh/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'providers/order_provider.dart';
import 'screens/splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => StoreProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CouponProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor:  Color(0xff84c225), fontFamily: 'Lato'),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => const SplashScreen(),
        HomeScreen.id: (context) => const HomeScreen(),
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        MapScreen.id: (context) => const MapScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        LandingScreen.id: (context) => const LandingScreen(),
        MainScreen.id: (context) => const MainScreen(),
        VendorHomeScreen.id: (context) => const VendorHomeScreen(),
        ProductListScreen.id:(context)=>const ProductListScreen(),
        ProfileScreen.id:(context)=>const ProfileScreen(),
        UpdateProfile.id:(context)=>const UpdateProfile(),


      },
      builder: EasyLoading.init(),
    );
  }
}
