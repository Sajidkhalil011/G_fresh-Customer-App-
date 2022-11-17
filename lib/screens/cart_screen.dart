import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:g_fresh/providers/auth_provider.dart';
import 'package:g_fresh/providers/cart_provider.dart';
import 'package:g_fresh/providers/coupon_provider.dart';
import 'package:g_fresh/providers/location_provider.dart';
import 'package:g_fresh/screens/map_screen.dart';
import 'package:g_fresh/screens/profile_screen.dart';
import 'package:g_fresh/services/cart_services.dart';
import 'package:g_fresh/services/store_services.dart';
import 'package:g_fresh/services/user_services.dart';
import 'package:g_fresh/widgets/cart/cart_list.dart';
import 'package:g_fresh/widgets/cart/cod_toggle.dart';
import 'package:g_fresh/widgets/cart/coupon_widget.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/order_services.dart';

class CartScreen extends StatefulWidget {
  final DocumentSnapshot document;
  const CartScreen({Key? key, required this.document}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final StoreServices _store = StoreServices();
  final UserServices _userService = UserServices();
  final OrderServices _orderServices=OrderServices();
  final CartServices _cartServices=CartServices();
  User? user = FirebaseAuth.instance.currentUser;
   DocumentSnapshot? doc;
  var textStyle = const TextStyle(color: Colors.grey);
  int deliveryFee = 50;
  String? _location = '';
  String? _address = '';
  bool _loading = false;
  final bool _checkingUser = false;
  double discount = 0;

  @override
  void initState() {
    getPrefs();
    _store.getShopDetails(widget.document['sellerUid']).then((value) {
      setState(() {
        doc = value;
      });
    });
    super.initState();
  }

  getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? location = prefs.getString('location');
    String? address = prefs.getString('address');
    setState(() {
      _location = location!;
      _address = address!;
    });
  }

  @override
  Widget build(BuildContext context) {
    var _cartProvider = Provider.of<CartProvider>(context);
    final locationData = Provider.of<LocationProvider>(context);
    var userDetails = Provider.of<AuthProvider>(context);
    var _coupon=Provider.of<CouponProvider>(context);
    userDetails.getUserDetails().then((value){
      double subTotal=_cartProvider.subTotal;
      double discountRate=_coupon.discountRate/100;
      setState(() {
        discount=subTotal*discountRate;
      });
    });
    var _payable = _cartProvider.subTotal + deliveryFee - discount;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey.shade200,
      bottomSheet: userDetails.snapshot==null?Container():Container(
        height: 180,
        color: Colors.blueGrey[800],
        child: Column(
          children: [
            Divider(
              color: Colors.grey,
            ),
            Container(
              height: 100,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Deliver to this address: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _loading = true;
                            });
                            locationData.getCurrentPosition().then((value) {
                              setState(() {
                                _loading = false;
                              });
                              if (value != null) {
                                PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                                  context,
                                  settings: RouteSettings(name: MapScreen.id),
                                  screen: MapScreen(),
                                  withNavBar: false,
                                  pageTransitionAnimation: PageTransitionAnimation
                                      .cupertino,
                                );
                              } else {
                                setState(() {
                                  _loading = false;
                                });
                                print('Permission not Allowed');
                              }
                            });
                          },
                          child: _loading ? CircularProgressIndicator() : Text(
                            'Change',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      userDetails.snapshot!['firstName'] != null ? '${userDetails
                          .snapshot!['firstName']}''${userDetails
                          .snapshot!['lastName']} : $_location, $_address' : '$_location, $_address',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${_payable.toStringAsFixed(0)}',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '(Including all Taxes)',
                          style: TextStyle(color: Colors.green, fontSize: 10),
                        )
                      ],
                    ),
                    ElevatedButton(
                      child: _checkingUser ? CircularProgressIndicator() : Text(
                        'CHECKOUT',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.redAccent, // Background color
                      ),
                      onPressed: () {
                        EasyLoading.show(status: 'Please wait...');
                        _userService.getUserById(user!.uid).then((value) {
                          if (value['id'] == null) {
                            EasyLoading.dismiss();
                            //need to confirm user name before placing order
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ProfileScreen()),
                            );
                          } else {
                            EasyLoading.show(status: 'Please wait...');
                            //TODO:Payment gateway integration.
                            _saveOrder(_cartProvider,_payable,_coupon);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                floating: true,
                snap: true,
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                elevation: 0.0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.document['shopName'],
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Row(
                      children: [
                        Text(
                          '${_cartProvider.cartQty} ${_cartProvider.cartQty > 1
                              ? 'Items, '
                              : 'Item, '}Item',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Text(
                          'To pay : \$ ${_payable.toStringAsFixed(
                              0)}',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ];
          },
          body: doc==null?Center(child: CircularProgressIndicator()):_cartProvider.cartQty > 0
              ? SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 80),
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery
                      .of(context)
                      .viewInsets
                      .bottom),
              child: Column(
                children: [
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            tileColor: Colors.white,
                            leading: Container(
                              height: 60,
                              width: 60,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  doc!['imageUrl'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(doc!['shopName']),
                            subtitle: Text(
                              doc!['address'],
                              maxLines: 1,
                              style:
                              TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                          CodToggleSwitch(),
                          Divider(color: Colors.grey.shade300
                          ),
                        ],
                      ),
                    ),
                  CartList(
                    document: widget.document,
                  ),
                  // coupon
                  CouponWidget(couponVendor: doc!['uid'],),
                  //bill details card
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 4, left: 4, top: 4, bottom: 80),
                    child: SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bill detail',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Cart value',
                                      style: textStyle,
                                    ),
                                  ),
                                  Text(
                                    '\$ ${_cartProvider.subTotal
                                        .toStringAsFixed(0)}',
                                    style: textStyle,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              if(discount>0) //this will show if only discount is available
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Discount',
                                      style: textStyle,
                                    ),
                                  ),
                                  Text(
                                    '\$ ${discount.toStringAsFixed(0)}',
                                    style: textStyle,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Delivery Fee',
                                      style: textStyle,
                                    ),
                                  ),
                                  Text(
                                    '\$ $deliveryFee',
                                    style: textStyle,
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Total amount payable',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    '\$ ${_payable.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(4),
                                    color: Theme
                                        .of(context)
                                        .primaryColor
                                        .withOpacity(.3)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Total Saving',
                                          style: TextStyle(
                                              color: Colors.green),
                                        ),
                                      ),
                                      Text(
                                        '\$ ${_cartProvider.saving
                                            .toStringAsFixed(0)}',
                                        style: TextStyle(
                                            color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
              : Center(
            child: Text('Cart Empty, Do some shopping'),
          )),
    );
  }
  _saveOrder(cartProvider,payable,CouponProvider coupon){
    _orderServices.saveOrder({
      'products': cartProvider.cartList,
      'userId':user!.uid,
      'deliveryFee':deliveryFee,
      'total':payable,
      'discount':discount.toStringAsFixed(0),
      'cod':cartProvider.cod, //cash on delivery or not
      'discountCode':coupon.document==null?null:coupon.document?['title'],
      'seller':{
        'shopName':widget.document['shopName'],
        'sellerId':widget.document['sellerUid'],
      },
      'timestamp':DateTime.now().toString(),
      'orderStatus':'Ordered',
      'deliveryBoy':{
        'name':'',
        'phone':'',
        'location':'',
      },
    }).then((value){
      //after submitting order, need to clear cart list
      _cartServices.deleteCart().then((value){
        _cartServices.checkData().then((value){
          EasyLoading.showSuccess('Your order is submitted');
          Navigator.pop(context); //close cart screen
        });
      });
    });
  }
}
