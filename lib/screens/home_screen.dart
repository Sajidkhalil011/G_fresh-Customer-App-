import 'package:flutter/material.dart';
import 'package:g_fresh/widgets/near_by_store.dart';
import 'package:g_fresh/widgets/top_pick_store.dart';
import 'package:g_fresh/widgets/image_slider.dart';
import 'package:g_fresh/widgets/my_appbar.dart';
class HomeScreen extends StatefulWidget {
  static const String id ='home-screen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
          return[
            MyAppBar(),
          ];
        },
        body: ListView(
          padding: EdgeInsets.only(top: 0.0),
            children: [
              ImageSlider(),
              Container(
                color: Colors.white,
                  child:   TopPickStore()
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: NearByStores(),
              ),
            ],
          ),
      ),
      );
  }
}
