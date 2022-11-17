import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier{
    double ?latitude=37.421632;
    double ?longitude=122.084664;
  bool permissionAllowed=false;
  // ignore: prefer_typing_uninitialized_variables
  var selectedAddress;
  bool loading = false;


  Future<Position>getCurrentPosition()async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if(position!=null){
      latitude=position.latitude;
      longitude=position.longitude;

      final coordinates= Coordinates(latitude, longitude);
      final addresses =  await Geocoder.local.findAddressesFromCoordinates(coordinates);
      selectedAddress=addresses.first;
      permissionAllowed=true;
      notifyListeners();
    }else{
      print('Permission not allowed');
    }
    return position;
  }
  Future<void>onCameraMove(CameraPosition cameraPosition)async{
    latitude=cameraPosition.target.latitude;
    longitude=cameraPosition.target.longitude;
    notifyListeners();
  }
  Future<void>getMoveCamera()async{
    final coordinates= Coordinates(latitude, longitude);
    final addresses =  await Geocoder.local.findAddressesFromCoordinates(coordinates);
    selectedAddress=addresses.first;
    notifyListeners();
    print("${selectedAddress.featureName} : ${selectedAddress.addressLine}");
  }

  Future<void>savePrefs()async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    prefs.setDouble('latitude', latitude!);
    prefs.setDouble('longitude', longitude!);
    prefs.setString('address', selectedAddress?.addressLine);
    prefs.setString('location',selectedAddress?.featureName);


  }
}