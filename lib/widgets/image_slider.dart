import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageSlider extends StatefulWidget {
  const ImageSlider({Key? key}) : super(key: key);
  @override
  _ImageSliderState createState() => _ImageSliderState();
}
class _ImageSliderState extends State<ImageSlider> {
  int _index = 0;
  int _dataLength = 1;

  @override
  void initState() {
    getSliderImageFromDb();
    super.initState();
  }
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getSliderImageFromDb() async {
    var _fireStore = FirebaseFirestore.instance;
    QuerySnapshot<Map<String,dynamic>> snapshot = await _fireStore.collection('slider').get();
    setState(() {
      _dataLength=snapshot.docs.length;
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
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          if (_dataLength != 0)
            FutureBuilder(
              future: getSliderImageFromDb(),
              builder: (_, AsyncSnapshot<List<QueryDocumentSnapshot<Map<String, dynamic>>>> snapshot) {
                return snapshot.data == null
                    ? Center(
                  child: CircularProgressIndicator(),
                )
                    : Padding(
                  padding: const EdgeInsets.only(top: 4),
                    child: CarouselSlider.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, index, int) {
                          DocumentSnapshot<Map<String,dynamic>> ImageSlider = snapshot.data![index];
                          Map<String, dynamic>? getImage = ImageSlider.data();
                          return SizedBox(
                              width: MediaQuery.of(context).size.width,
                                child: Image.network(getImage!['image'],
                                  fit: BoxFit.fill,
                                ),
                              );
                        },
                        options: CarouselOptions(
                            viewportFraction: 1,
                            initialPage: 0,
                            autoPlay: true,
                            height: 150,
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



