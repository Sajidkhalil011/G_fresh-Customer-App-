import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:g_fresh/providers/auth_provider.dart';
import 'package:g_fresh/providers/location_provider.dart';
import 'package:g_fresh/screens/login_screen.dart';
import 'package:g_fresh/screens/main_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MapScreen extends StatefulWidget {
 static const String id='map-screen';
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
    LatLng? currentLocation;
    GoogleMapController? mapController;
   bool _locating = false;
   bool _loggedIn=false;
    User? user;
   @override
   initState() {
     getCurrentUser();
    super.initState();
  }

  Future<void> getCurrentUser()async {
     setState(() {
       user=FirebaseAuth.instance.currentUser;
     });
     if(user!=null){
       setState(() {
         _loggedIn=true;
       });
     }
  }

  @override
  Widget build(BuildContext context) {
    final locationData = Provider.of<LocationProvider>(context);
    final _auth = Provider.of<AuthProvider>(context);

    setState(() {
      currentLocation=LatLng(locationData.latitude!,locationData.longitude!);
    });
    void _onMapCreated(GoogleMapController controller){
      setState(() {
        mapController=controller;
      });
    }
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: currentLocation!,zoom: 14.4746,),
              zoomControlsEnabled: false,
              zoomGesturesEnabled: true,
              compassEnabled: true,
              minMaxZoomPreference:  MinMaxZoomPreference.unbounded,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              mapToolbarEnabled: true,
              onCameraMove: (CameraPosition position){
                setState(() {
                  _locating=true;
                });
                locationData.onCameraMove(position);
              },
              onMapCreated:_onMapCreated,
              onCameraIdle: (){
                setState(() {
                  _locating=false;
                });
                locationData.getMoveCamera();
              },
            ),
            Center(child: Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 40),
                child: Image.asset('images/marker.png',),
            ),
            ),
            const Center(
              child:SpinKitPulse(
                color: Colors.black54,
                size: 100.0,
              ),
            ),
            Positioned(
              bottom: 0.0,
              child: Container(
                  height:230,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:  [
                    SizedBox(height: 20,),
                    _locating ? const LinearProgressIndicator(
                      backgroundColor:Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                    ) : Container(),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10,right: 20),
                        child: TextButton.icon(
                          onPressed: () {  },
                          icon: const Icon(Icons.location_searching,color: Colors.orangeAccent,),
                          label:  Text( _locating ? 'Locating.....': locationData
                                .selectedAddress ==null ? 'locating.....':locationData
                        .selectedAddress.featureName ,
                              overflow: TextOverflow.ellipsis
                              ,style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black) ,),
                         ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20,right: 20),
                        child: Text(_locating ? '':locationData
                            .selectedAddress==null ? '': locationData.selectedAddress.addressLine,style: const TextStyle(color: Colors.black54),),
                      ),
                    ),
                     Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width-40,
                          child: AbsorbPointer(
                            absorbing: _locating ? true:false,
                            child: TextButton(
                              child: const Text('CONFIRM LOCATION',style: TextStyle(color: Colors.white),),
                              style: TextButton.styleFrom(
                                backgroundColor: Color(0xff84c225),
                              ),
                              onPressed: (){
                                //save address in shared preference
                                locationData.savePrefs();
                                if(_loggedIn==false){
                                  Navigator.pushNamed(context, LoginScreen.id);
                                }else{
                                  setState(() {
                                    _auth.latitude=locationData.latitude!;
                                    _auth.longitude=locationData.longitude!;
                                    _auth.address=locationData.selectedAddress.addressLine;
                                    _auth.location=locationData.selectedAddress.featureName;
                                  });
                                  _auth.updateUser(
                                    id: user!.uid,
                                    number: user!.phoneNumber,

                                  ).then((value){
                                    if(value==true){
                                      PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                                        context,
                                        settings: RouteSettings(name: MainScreen.id),
                                        screen: MainScreen(),
                                        withNavBar: true,
                                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                      );
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                ),
            ),
          ],
        ),
      ),
    );
  }
}
