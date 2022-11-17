import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:g_fresh/providers/auth_provider.dart';
import 'package:g_fresh/providers/location_provider.dart';
import 'package:g_fresh/screens/home_screen.dart';
import 'package:g_fresh/screens/main_screen.dart';
import 'package:g_fresh/screens/map_screen.dart';
import 'package:g_fresh/screens/onboard_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome-screen';
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  get auth => Provider.of<AuthProvider>(context, listen: false);

  bool _validPhoneNumber = false;
  final _phoneNumberController = TextEditingController();
  void showBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, myState) {
          return Container(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: auth.error == 'Invalid OTP' ? true : false,
                    child: Container(
                      child: Column(
                        children: [
                          Text(
                            auth.error,
                            style:
                                const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Text(
                    'LOGIN',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Enter Your Phone Number To Proceed',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      prefixText: '+92',
                      labelText: '10 digit mobile number',
                    ),
                    autofocus: true,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    controller: _phoneNumberController,
                    onChanged: (value) {
                      if (value.length == 10) {
                        myState(() {
                          _validPhoneNumber = true;
                        });
                      } else {
                        myState(() {
                          _validPhoneNumber = false;
                        });
                      }
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: AbsorbPointer(
                          absorbing: _validPhoneNumber ? false : true,
                          child: TextButton(
                            onPressed: () {
                              myState((){
                                auth.loading=true;
                              });
                              String number = '+92${_phoneNumberController.text}';
                              auth.verifyPhone(context:context,number:number).then((value) {
                                _phoneNumberController.clear();

                              });
                            },
                            style: TextButton.styleFrom(
                              backgroundColor:Color(0xff84c225) ,
                            ),
                            child: auth.loading ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                            ): Text(
                              _validPhoneNumber
                                  ? 'Continue '
                                  : 'Enter Your Number',
                              style: const TextStyle(color: Colors.white),
                            ),

                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete((){
      setState(() {
        auth.loading=false;
        _phoneNumberController.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationData=Provider.of<LocationProvider>(context,listen: false);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Positioned(
              right: 0.0,
              top: 10.0,
              child: InkWell(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MainScreen()));
                },
                child: Text(
                  'Skip',
                  style: TextStyle(color: Color(0xff84c225),fontSize: 15,fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                    child: OnboardScreen()
            ),
            const Text(
              'Ready to order from your nearest shop?',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton(
              style : TextButton.styleFrom(
                backgroundColor: Color(0xff84c225), // Background Color
              ),
              child: locationData.loading ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ): const Text(
                'Set Delivery Location',
                style: TextStyle(color: Colors.white,fontSize: 15),
              ),
              onPressed: () async {
                setState(() {
                  locationData.loading=true;
                });

               await locationData.getCurrentPosition();
               if(locationData.permissionAllowed==true){
                 locationData.getCurrentPosition().then((value){
                   Navigator.pushReplacementNamed(context, MapScreen.id);
                   setState(() {
                     locationData.loading=false;
                   });
                 });
                }else{
                   print('Permission not allowed');
                   setState(() {
                     locationData.loading=false;
                  });
               }
               },
            ),
            const SizedBox(height: 20,),
            TextButton(
              child: RichText(
                text: const TextSpan(
                  text: 'Already a Customer?',
                  style: TextStyle(color: Colors.grey),
                  children: [
                    TextSpan(
                      text: 'Login',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent)),
                  ],
                ),
              ),
              onPressed: ()  {
                setState(() {
                  auth.screen='Login';
                });
                showBottomSheet(context);
              },
            ),
          ],
        ),
        ]
        )
      ),
    );
  }
}
