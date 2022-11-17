import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:g_fresh/providers/store_provider.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorAppBar extends StatefulWidget {
  const VendorAppBar({Key? key}) : super(key: key);

  @override
  State<VendorAppBar> createState() => _VendorAppBarState();
}

class _VendorAppBarState extends State<VendorAppBar> {
  double rating=0;
  @override
  Widget build(BuildContext context) {
    var _store = Provider.of<StoreProvider>(context);
    final Uri _url = Uri.parse('tel:${_store.storedetails!['mobile']}');
    void _launchUrl() async {
      if (!await launchUrl(_url)) throw 'Could not launch $_url';
    }

    mapLauncher()async{
      GeoPoint location=_store.storedetails!['location'];
      final availableMaps = await MapLauncher.installedMaps;
      await availableMaps.first.showMarker(
        coords: Coords(location.latitude, location.longitude),
        title: '${_store.storedetails!['shopName']} is here',
      );
    }

    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Color(0xff84c225),
      iconTheme: IconThemeData(
        color: Colors.white, //to make back button white
      ),
      expandedHeight: 260,
      flexibleSpace: SizedBox(
          child: Padding(
        padding: const EdgeInsets.only(top: 86),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(_store.storedetails!['imageUrl']),
                  )),
              child: Container(
                color: Colors.grey.withOpacity(.7),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Text(
                        _store.storedetails!['dialog'],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _store.storedetails!['address'],
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _store.storedetails!['email'],
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Distance:${_store.distance}km',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6,),
                      Column(
                        children: [
                          Text('Rating: $rating',style: TextStyle(fontSize: 15,color: Colors.white),),
                          Row(
                            children: [
                             RatingBar.builder(
                               minRating: 1,
                               itemBuilder: (context, _)=>Icon(Icons.star,color: Colors.amber,),
                               onRatingUpdate: (rating)=>setState((){
                                 this.rating=rating;
                               }),
                             ),
                              SizedBox(
                                width: 5,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: Icon(Icons.phone,
                                color: Theme.of(context).primaryColor,),
                              onPressed: _launchUrl,
                            ),
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon:Icon(
                                Icons.map,
                                color: Theme.of(context).primaryColor,),
                              onPressed: (){
                                mapLauncher();
                              },
                          ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      )),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(CupertinoIcons.search),
        ),
      ],
      title: Text(
        _store.storedetails!['shopName'],
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

