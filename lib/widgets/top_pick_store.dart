import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:g_fresh/providers/store_provider.dart';
import 'package:g_fresh/screens/vendor_home_screen.dart';
import 'package:g_fresh/services/store_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

class TopPickStore extends StatefulWidget {
  const TopPickStore({Key? key}) : super(key: key);

  @override
  State<TopPickStore> createState() => _TopPickStoreState();
}

class _TopPickStoreState extends State<TopPickStore> {




  @override
  Widget build(BuildContext context) {
    final StoreServices _storeServices = StoreServices();
   final _storeData = Provider.of<StoreProvider>(context);
    _storeData.getUserLocationData(context);

    String getDistance(location) {
      var distance = Geolocator.distanceBetween(
          _storeData.userLatitude, _storeData.userLongitude, location.latitude, location.longitude);
      var distanceInKm = distance / 1000; //this will show in Km
      return distanceInKm.toStringAsFixed(2);
    }

    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: _storeServices.getTopPickedStore(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapShot) {
          if (!snapShot.hasData) return Center(child: CircularProgressIndicator());
          List shopDistance = [];
          for (int i = 0; i <= snapShot.data!.docs.length - 1; i++) {
            var distance = Geolocator.distanceBetween(
                _storeData.userLatitude,
                _storeData.userLongitude,
                snapShot.data!.docs[i]['location'].latitude,
                snapShot.data!.docs[i]['location'].longitude);
            var distanceInKm = distance / 1000;
            shopDistance.add(distanceInKm);
          }
          shopDistance.sort();
          if (shopDistance[0] > 10) {
            return Container();
          }
          return Container(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 20),
                    child: Row(
                      children: [
                        SizedBox(
                            height: 30, child: Image.asset('images/like.gif')),
                        Text(
                          'Top Picked Stores For You',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 20),
                        )
                      ],
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapShot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot document =
                              snapShot.data!.docs[index];
                          if (double.parse(getDistance(document['location'])) <=
                              10) {
                            //show the stores only with in 10km
                            // also we can increase the stores
                            return InkWell(
                              onTap: () {
                                _storeData.getSelectedStore(document,getDistance(document['location']));
                                PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                                  context,
                                  settings:
                                      const RouteSettings(name: VendorHomeScreen.id),
                                  screen: const VendorHomeScreen(),
                                  withNavBar: true,
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  width: 80,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: Card(
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Image.network(
                                                  document['imageUrl'],
                                                  fit: BoxFit.cover)),
                                        ),
                                      ),
                                      Container(
                                        height: 35,
                                        child: Text(
                                          document['shopName'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${getDistance(document['location'])}Km',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 10),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
