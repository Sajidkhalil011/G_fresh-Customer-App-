import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
children: [
  Hero(
      tag: 'logo',
      child: Image.asset('images/logo-1.png',
      height: 270,
        width: 100,
      )),
  const TextField(),
  const TextField(),
  const TextField(),
  const TextField(),

],
          ),
        ),
      ),
    );
  }
}
