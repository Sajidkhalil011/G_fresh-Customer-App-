import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:g_fresh/constants.dart';
class OnboardScreen extends StatefulWidget {
  const OnboardScreen({Key? key}) : super(key: key);

  @override
  _OnboardScreenState createState() => _OnboardScreenState();
}


final _controller = PageController(
  initialPage: 0,
);

int _currentPage=0;
List<Widget> _pages=[
  Column(
    children: [
      Expanded(child: Image.asset('images/enteraddress.png')),
      const Text('Set Your Delivery location', style: kPageViewTextStyle,textAlign: TextAlign.center,),
    ],
  ),
  Column(
    children: [
      Expanded(child: Image.asset('images/orderfood.png')),
      const Text('Order Online from your favourite Store',style: kPageViewTextStyle,textAlign: TextAlign.center,),
    ],
  ),
  Column(
    children: [
      Expanded(child: Image.asset('images/deliverfood.png')),
      const Text('Quick Deliver to Your Doorstep',style: kPageViewTextStyle,textAlign: TextAlign.center,),
    ],
  )
  ];

class _OnboardScreenState extends State<OnboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children:[
        Expanded(
          child: PageView(
            controller: _controller ,
            children: _pages,
            onPageChanged: (index){
              setState(() {
                _currentPage=index;

              });
            },
          ),
        ),
        const SizedBox(height: 10,),
        DotsIndicator(
          dotsCount: _pages.length,
          position: _currentPage.toDouble(),
          decorator: DotsDecorator(
              size: const Size.square(9.0),
              activeSize: const Size(18.0, 9.0),
              activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              activeColor: Color(0xff84c225)
          ),
        ),
        const SizedBox(height: 20,),
      ],
    );
  }
}
