import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:g_fresh/widgets/products/add_to_cart_widget.dart';


class BottomSheetContainer extends StatefulWidget {
  final DocumentSnapshot document;
  const BottomSheetContainer({Key? key, required this.document}) : super(key: key);

  @override
  State<BottomSheetContainer> createState() => _BottomSheetContainerState();
}

class _BottomSheetContainerState extends State<BottomSheetContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Flexible(flex:1,child: AddToCartWidget(document: widget.document,)),
        ],
      ),
    );
  }
}
