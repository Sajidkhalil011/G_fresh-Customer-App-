import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:g_fresh/screens/landing_screen.dart';
import 'package:g_fresh/screens/main_screen.dart';
import 'package:g_fresh/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'welcome_screen.dart';


class SplashScreen extends StatefulWidget {
  static const String id = 'splash-screen';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    Timer(
        const Duration(
          seconds: 2,
        ),(){
      FirebaseAuth.instance.authStateChanges().listen((user) async {
        if(user==null){
          Navigator.pushReplacementNamed(context, WelcomeScreen.id);
        }else{
          //if user has data in firestore check delivery address set or not
          getUserData();
        }
      });
    }
    );

    super.initState();
  }

  getUserData()async{
    UserServices _userServices=UserServices();
    _userServices.getUserById(user!.uid).then((result){
      //check address details has or not
      if(result['address']!=null){
        //if address details exists
        updatePrefs(result);
      }
      //if address details does not exists
      Navigator.pushReplacementNamed(context, LandingScreen.id);
    });
  }

  Future<void>updatePrefs(result)async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    prefs.setDouble('latitude', result['latitude']);
    prefs.setDouble('longitude', result['longitude']);
    prefs.setString('address', result['address']);
    prefs.setString('location',result['location']);
    //after update prefs navigate to home screen
    Navigator.pushReplacementNamed(context, MainScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Hero(
            tag: 'logo',
            child: Image.asset('images/logo-1.png',
              height: 125,
              width: 125,
            ),
          )
      ),
    );
  }
}
