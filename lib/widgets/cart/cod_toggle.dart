import 'package:flutter/material.dart';
import 'package:g_fresh/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:toggle_bar/toggle_bar.dart';


class CodToggleSwitch extends StatelessWidget {
  const CodToggleSwitch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _cart=Provider.of<CartProvider>(context);
    return Container(
      color: Colors.white,
      child: ToggleBar(
        backgroundColor: Colors.grey.shade300,
          textColor: Colors.grey.shade600,
          selectedTabColor: Theme.of(context).primaryColor,
          labels: ["Pay Online", "Cash on delivery",],
          onSelectionUpdated: (index){
            // Do something with index
            _cart.getPaymentMethod(index);
          }
      ),
    );
  }
}
