import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:g_fresh/services/store_services.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';

class VendorBanner extends StatefulWidget {
  const VendorBanner({Key? key}) : super(key: key);
  @override
  State<VendorBanner> createState() => _VendorBannerState();
}
class _VendorBannerState extends State<VendorBanner> {
  int _index = 0;
  int _dataLength=1;
  @override
  void didChangeDependencies() {
    var _storeProvider = Provider.of<StoreProvider>(context);
    getBannerImageFromDb(_storeProvider);
    super.didChangeDependencies();
  }

  Future<List> getBannerImageFromDb(StoreProvider storeProvider) async {
    var _fireStore = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection('vendorbanner')
        .where('sellerUid', isEqualTo: storeProvider.storedetails!['uid'])
        .get();
    setState(() {
      _dataLength = snapshot.docs.length;
    });
    if (mounted) {
      setState(() {
        _dataLength = snapshot.docs.length;
      });
    }
    return snapshot.docs;
  }
  @override
  Widget build(BuildContext context) {
    var _storeProvider = Provider.of<StoreProvider>(context);
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          if (_dataLength != 0)
            FutureBuilder(
              future: getBannerImageFromDb(_storeProvider),
              builder: (_, AsyncSnapshot snapshot) {
                return snapshot.data == null
                    ? Center(
                  child: CircularProgressIndicator(),
                )
                    : Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: CarouselSlider.builder(
                      itemCount: snapshot.data.length<=0?1:snapshot.data.length,
                      itemBuilder: (BuildContext context, index, int) {
                        DocumentSnapshot<Map<String,dynamic>> imageSlider = snapshot.data![index];
                        Map<String, dynamic>? getImage = imageSlider.data();
                        return SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Image.network(getImage!['imageUrl'],
                            fit: BoxFit.fill,
                          ),
                        );
                      },
                      options: CarouselOptions(
                          viewportFraction: 1,
                          initialPage: 0,
                          autoPlay: true,
                          height: 180,
                          onPageChanged:
                              (int i, carouselPageChangedReason) {
                            setState(() {
                              _index = i;
                            });
                          })),
                );
              },
            ),
          if(_dataLength!=0)
          DotsIndicator(
            dotsCount: _dataLength,
            position: _index.toDouble(),
            decorator: DotsDecorator(
                size: const Size.square(5.0),
                activeSize: const Size(18.0, 5.0),
                activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                activeColor: Color(0xff84c225)
            ),
          ),
        ],
      ),
    );
  }
}
