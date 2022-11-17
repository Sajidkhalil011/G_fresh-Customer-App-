import 'package:flutter/material.dart';
import 'package:g_fresh/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';


class LoginScreen extends StatefulWidget {
  static const String id = 'login-screen';
   const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool _validPhoneNumber = false;
  final _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth=Provider.of<AuthProvider>(context);
    final locationData=Provider.of<LocationProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
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
                      setState(() {
                        _validPhoneNumber = true;
                      });
                    } else {
                      setState(() {
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
                            setState((){
                              auth.loading=true;
                              auth.screen='MapScreen';
                              auth.latitude=locationData.latitude!;
                              auth.longitude=locationData.longitude!;
                              auth.address=locationData.selectedAddress.addressLine;
                            });
                            String number = '+92${_phoneNumberController.text}';
                            auth.verifyPhone(
                                context: context,
                                number: number,
                            ).then((value) {
                              _phoneNumberController.clear();
                              setState(() {
                                auth.loading=false;
                              });
                            });
                          },
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Color(0xff84c225), // Background Color
                          ),
                          child: auth.loading ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)
                          ): Text(
                            _validPhoneNumber
                                ? 'Continue '
                                : 'Enter Your Number',
                          ),

                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
