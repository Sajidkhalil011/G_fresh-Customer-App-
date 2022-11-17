import 'package:flutter/material.dart';
import 'package:g_fresh/widgets/categories_widget.dart';
import 'package:g_fresh/widgets/products/best_selling_products.dart';
import 'package:g_fresh/widgets/products/featured_products.dart';
import 'package:g_fresh/widgets/products/recently_added_products.dart';
import 'package:g_fresh/widgets/vendor_appbar.dart';
import 'package:g_fresh/widgets/vendor_banner.dart';

class VendorHomeScreen extends StatelessWidget {
  static const String id = 'vendor-screen';
  const VendorHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
             VendorAppBar(),
          ];
        },
        body: ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children:  [
            VendorBanner(),
           VendorCategories(),
            //Recently Added Products
            //Best Selling Products
            //Featured Products
            RecentlyAddedProducts(),
            FeaturedProducts(),
            BestSellingProducts(),
          ],
        ),
      ),
    );
  }
}
