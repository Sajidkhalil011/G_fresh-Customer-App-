// ignore_for_file: prefer_function_declarations_over_variables
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:g_fresh/providers/location_provider.dart';
import 'package:g_fresh/screens/landing_screen.dart';
import 'package:g_fresh/screens/main_screen.dart';
import 'package:g_fresh/services/user_services.dart';

class AuthProvider with ChangeNotifier{
  final FirebaseAuth auth = FirebaseAuth.instance;
    String? smsOtp;
    String? verificationId;
   String error='';
   final UserServices _userServices=UserServices();
   bool loading=false;
   LocationProvider locationData=LocationProvider();
   String? screen;
   double? latitude;
   double? longitude;
   String? address;
   String? location;
   DocumentSnapshot? snapshot;


Future<void>verifyPhone({ context,number,})async{
  loading=true;
  notifyListeners();
  final PhoneVerificationCompleted verificationCompleted=
      (PhoneAuthCredential credential)async{
    loading=false;
    notifyListeners();
    await auth.signInWithCredential(credential);
  };


  final PhoneVerificationFailed verificationFailed=(FirebaseAuthException e) async {
    loading=false;
    print(e.code);
    error=e.toString();
    notifyListeners();
  };

  final PhoneCodeSent smsOtpSend=(String verId,int? resendToken)async{
    verificationId=verId;
    smsOtpDialog(context,number);
  };

 try{
   auth.verifyPhoneNumber(
       phoneNumber: number,
       verificationCompleted: verificationCompleted,
       verificationFailed: verificationFailed,
       codeSent: smsOtpSend,
       codeAutoRetrievalTimeout: (String verId){
         verificationId=verId;
       },
     timeout: Duration(seconds: 120),
   );

 }catch(e){
   error=e.toString();
   loading=false;
   notifyListeners();
   print(e);
 }
}
Future<void>smsOtpDialog(context,number)async{
  return showDialog(
    context: context,
    builder: (BuildContext context){
      return AlertDialog(
        title: Column(
          children: const [
            Text('Verification Code'),
            SizedBox(height: 6,),
            Text('Enter 6 digits OTP Code Received as SMS',
              style: TextStyle(color: Colors.grey,fontSize: 12),
            ),
          ],
        ),
        content: SizedBox(
          height: 85,
          child: TextField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 6,
            onChanged: (value){
              smsOtp=value;
            }
          ),
        ),
        actions: [
          TextButton(
              onPressed: ()async{
                try{
                  PhoneAuthCredential credential =
                  PhoneAuthProvider.credential(
                      verificationId: verificationId!, smsCode: smsOtp!);
                  final user =(await auth.signInWithCredential(credential)).user;

                  if(user!=null){
                    loading=false;
                    notifyListeners();
                    _userServices.getUserById(user.uid).then((snapShot){
                      if(snapShot.exists){
                        // user data already exists
                        if(screen=='Login') {
                          //need to check user data already exists in db or not.
                          //if its 'login' no new data, so no need to update
                          if(snapShot['address']!=null){
                            Navigator.pushReplacementNamed(context, MainScreen.id);
                          }

                        }else{
                          //need to update new selected address
                          updateUser(id: user.uid,number: user.phoneNumber,);
                          Navigator.pushReplacementNamed(context, MainScreen.id);
                        }
                      }else{
                        //user data does not exists
                        //will create new data in db
                        _createUser(id:user.uid,number: user.phoneNumber);
                        Navigator.pushReplacementNamed(context, LandingScreen.id);
                      }
                    });

                  }else{
                    print('Login Failed');
                  }
                }catch(e){
                  FocusScope.of(context).unfocus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Invalid OTP"),
                      duration: Duration(seconds: 5),
                    )
                  );
                  //error='Invalid OTP';
                  //notifyListeners();
                  //print(e.toString());
                  //Navigator.of(context).pop();
                }
              },
              child: Text('DONE', style: TextStyle(color:Theme.of(context).primaryColor),),
          ),
      ],
      );
    }).whenComplete((){
      loading=false;
      notifyListeners();
  });
}
Future<void> _createUser({ id, number}) async {
  _userServices.createUserData({
    'id': id,
    'number': number,
    'latitude':latitude,
    'longitude':longitude,
    'address': address,
    'location': location,
  });
  loading=false;
  notifyListeners();
}
 Future<bool>updateUser({ id, number,})async  {
   try{
     _userServices.updateUserData({
       'id': id,
       'number': number,
       'latitude':latitude,
       'longitude':longitude,
       'address': address,
       'location': location,

     });
     loading=false;
     notifyListeners();
     return true;
   }catch(e){
     print('Error $e');
     return false;
   }
  }
  getUserDetails()async{
  DocumentSnapshot result=await FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).get();
  if(result!=null){
    this.snapshot=result;
    notifyListeners();
  }else{
    this.snapshot=null;
    notifyListeners();
  }
  return result;
  }
}