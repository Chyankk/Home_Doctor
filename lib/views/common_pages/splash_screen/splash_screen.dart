import 'dart:async';

import 'package:flutter/material.dart';
import 'package:homedoctor/views/common_pages/landing_page/landing_page.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  startTime() async {
    var _duration = Duration(seconds: 3);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LandingPage()),
      );

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Text(
          "Home Doctor",
          style: Theme.of(context).textTheme.headline3.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}
