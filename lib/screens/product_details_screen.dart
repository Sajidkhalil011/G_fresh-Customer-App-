import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:g_fresh/widgets/products/bottom_sheet_container.dart';

class ProductDetailsScreen extends StatefulWidget {

  const ProductDetailsScreen({
    Key? key,
    required this.document,
  }) : super(key: key);
  final DocumentSnapshot document;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String text = '';
  bool shouldDisplay = false;
  double rating=0;
  final _reviewTextController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    var offer = ((widget.document['comparedPrice'] - widget.document['price']) /
        widget.document['comparedPrice'] *
        100);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff84c225),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.search)),
        ],
      ),
      bottomSheet: BottomSheetContainer(document: widget.document,),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .primaryColor
                          .withOpacity(.3),
                      border:
                      Border.all(color: Theme
                          .of(context)
                          .primaryColor)),
                  child: Padding(
                    padding:
                    EdgeInsets.only(left: 8, right: 8, bottom: 2, top: 2),
                    child: Text(widget.document['brand']),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              widget.document['productName'],
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              widget.document['weight'],
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text(
                  '\$${widget.document['price'].toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 10,
                ),
                if (offer > 0) //if discount available only
                  Text(
                    '\$${widget.document['comparedPrice']}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.lineThrough),
                  ),
                SizedBox(
                  width: 10,
                ),
                //   if (offer > 0) //if discount available only
                Container(
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Padding(
                    padding:
                    EdgeInsets.only(left: 8, right: 8, top: 3, bottom: 3),
                    child: Text(
                      '${offer.toStringAsFixed(0)}% OFF',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Hero(
                  tag: 'product${widget.document['productName']}',
                  child: Image.network(widget.document['productImage'])),
            ),
            Divider(
              color: Colors.grey[300],
              thickness: 6,
            ),
            Container(
              child: Padding(
                padding:
                EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
                child: Text(
                  'About this Product',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Divider(
              color: Colors.grey[400],
            ),
            Padding(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: ExpandableText(
                widget.document['description'],
                expandText: 'View more',
                collapseText: 'View less',
                collapseOnTextTap: true,
                maxLines: 2,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Divider(
              color: Colors.grey[400],
            ),
            Text("Review",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),),
            TextFormField(
              controller: _reviewTextController,
              onChanged: (value){
                setState(() {
                  text = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Enter Review',
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary,width: 2)
                ),
              ),
            ),
            ElevatedButton(onPressed: (){
              setState(() {
                _reviewTextController.clear();
                shouldDisplay= !shouldDisplay;
              });
            }, child: Text("Show Review")),
            shouldDisplay? Text(text,style: TextStyle(fontSize: 15),):Spacer(),
            Text("Rating",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),),
            RatingBar.builder(
              minRating: 1,
              itemBuilder: (context,_)=>Icon(Icons.star,color: Colors.amber,),
              onRatingUpdate: (rating)=>setState(() {
                this.rating=rating;
              }),
            ),
            Container(
              child: Padding(
                padding:
                EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
                child: Text(
                  'Other product info',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Divider(
              color: Colors.grey[400],
            ),
            Padding(
              padding:
              const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SKU :  ${widget.document['sku']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Seller :  ${widget.document['seller']['shopName']}',
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 60,
            ),
          ],
        ),
      ),
    );
  }
}
