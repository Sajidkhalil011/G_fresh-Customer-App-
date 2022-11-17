import 'package:flutter/material.dart';
import 'package:g_fresh/providers/store_provider.dart';
import 'package:g_fresh/widgets/products/products_filter_widget.dart';
import 'package:provider/provider.dart';
import '../widgets/products/product_list.dart';


class ProductListScreen extends StatelessWidget {
  static const String id='product-list-screen';
  const ProductListScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var _storeProvider=Provider.of<StoreProvider>(context);
    return Scaffold(
        body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
      return [
        SliverAppBar(
          backgroundColor: Color(0xff84c225),
          floating: true,
          snap: true,
          title: Text(_storeProvider.selectedProductCategory ?? "",style: TextStyle(color: Colors.white), ),
          iconTheme: IconThemeData(
            color: Colors.white
          ),
          expandedHeight: 110,
          flexibleSpace: Padding(
            padding: EdgeInsets.only(top: 88),
            child: Container(
              height: 56,
              color: Colors.grey,
              child: ProductFilterWidget(),
            ),
          ),
        ),
      ];
    },
          body: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              ProductListWidget(),
            ],
          ),
    ),
    );
  }
}
