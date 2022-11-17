import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/location_provider.dart';
import '../screens/map_screen.dart';

class MyAppBar extends StatefulWidget {
  const MyAppBar({Key? key}) : super(key: key);

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {

  String? _location='';
  String? _address='';

  @override
  void initState() {
    getPrefs();
    super.initState();
  }

  getPrefs()async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? location=prefs.getString('location');
    String? address=prefs.getString('address');
    setState(() {
      _location=location!;
      _address=address!;
    });
  }
  @override
  Widget build(BuildContext context) {
    final locationData=Provider.of<LocationProvider>(context);

    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Color(0xff84c225),
      elevation: 0.0,
      floating: true,
      snap:true,
      title: TextButton(
        onPressed: (){
          locationData.getCurrentPosition().then((value){
            if(value!=null){
              PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                context,
                settings: RouteSettings(name: MapScreen.id),
                screen: MapScreen(),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            }else{
              print('Permission not Allowed');
            }
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children:  [
                Flexible(
                    child: Text(_location ??= "Address not set",
                      style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,)),
                Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 15,
                ),
              ],
            ),
            Flexible(child: Text(_address ?? 'Press here to set Delivery Location',overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white,fontSize: 12),)),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Padding(
          padding:  EdgeInsets.all(10.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search,color: Colors.grey,),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: Colors.white,

            ),
          ),
        ),
      ),
    );
  }
}
