import 'package:flutter/material.dart';
import 'package:g_fresh/providers/location_provider.dart';
import 'package:g_fresh/screens/home_screen.dart';
import 'package:g_fresh/screens/map_screen.dart';
class LandingScreen extends StatefulWidget {
  static const String id='landing-screen';
  const LandingScreen({Key? key}) : super(key: key);

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  LocationProvider _locationProvider = LocationProvider();
  bool _loading=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize:MainAxisSize.min ,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Delivery Location not set',style: TextStyle(
                fontWeight: FontWeight.bold,
            ),),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Please update your Delivery location to find nearest Stores for you',textAlign:TextAlign.center,
              style: TextStyle(color: Colors.grey,),),
          ),
          CircularProgressIndicator(),
          Container(
            width: 600,
              child: Image.asset('images/city.png',fit: BoxFit.fill,color: Colors.black12,),),
          _loading ? CircularProgressIndicator(): TextButton(
            child: Text('Set Your Location',
              style: TextStyle(color: Colors.white),),
            onPressed: ()async{
              setState(() {
                _loading=true;
              });
              await _locationProvider.getCurrentPosition();
              if(_locationProvider.permissionAllowed==true){
                Navigator.pushReplacementNamed(context, MapScreen.id);
              }else{
                Future.delayed(Duration(seconds:4),(){
                  if(_locationProvider.permissionAllowed==false){
                    print('Permission not allowed');
                    setState(() {
                      _loading=false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Please allow Permission to find nearest stores for you'),
                    ));
                  }
                });
              }
              Navigator.pushReplacementNamed(context, HomeScreen.id);
            },
            style: TextButton.styleFrom(
              primary: Colors.black,
                backgroundColor: Color(0xff84c225)
            ),
          )
        ],
      ),
    );
  }
}
