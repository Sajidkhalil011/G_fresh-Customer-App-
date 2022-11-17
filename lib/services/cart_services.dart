import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class CartServices{
  CollectionReference cart=FirebaseFirestore.instance.collection('cart');
  User? user =FirebaseAuth.instance.currentUser;
  Future<DocumentReference<Map<String, dynamic>>>addToCart(document){
    cart.doc(user!.uid).set({
      'user':user!.uid,
      'sellerUid': document['seller']['sellerUid'],
      'shopName': document['seller']['shopName'],

    });
    return cart.doc(user!.uid).collection('products').add({
      'productId':document['productId'],
      'productName':document['productName'],
      'productImage':document['productImage'],
      'weight':document['weight'],
      'price':document['price'],
      'comparedPrice':document['comparedPrice'],
      'sku':document['sku'],
      'qty':1,
      'total':document['price'], //total price for 1 qty
    });
  }
  Future<void>updateCartQty(docID,qty,total)async{
    // Create a reference to the document the transaction will use
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('cart')
        .doc(user!.uid).collection('products').doc(docID);
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot snapshot = await transaction.get(documentReference);
      if (!snapshot.exists) {
        throw Exception("Product does not exist in Cart!");
      }
      // Perform an update on the document
      transaction.update(documentReference, {
        'qty': qty,
        'total':total,
      });
      // Return the new count
      return qty;
    })
        .then((value) => print("Cart Updated"))
        .catchError((error) => print("Failed to update user Cart: $error"));
  }
  Future<void>removeFromCart(docId)async{
    cart.doc(user!.uid).collection('products').doc(docId).delete();
  }
  Future<void>checkData()async{
    final snapshot= await cart.doc(user!.uid).collection('products').get();
    if(snapshot.docs.length==0){
      cart.doc(user!.uid).delete();
    }
  }
  Future<void>deleteCart()async{
    final result=await cart.doc(user!.uid).collection('products').get().then((snapshot){
      for(DocumentSnapshot ds in snapshot.docs){
        ds.reference.delete();
      }
    });
  }
  Future<String>checkSeller()async{
    final snapshot= await cart.doc(user!.uid).get();
    return snapshot.exists?snapshot['shopName']:null;
  }
}