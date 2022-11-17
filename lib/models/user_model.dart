


// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
class UserModel {

  static get Number => 'number';
  static get Id => 'id';

   late String  _number;
  late String _id;

String get number  => _number;
  String get id => _id;

  UserModel.fromSnapshot(DocumentSnapshot snapshot){
    (snapshot.data() as dynamic)['Number'];
    (snapshot.data() as dynamic)['Id'];


  }
}