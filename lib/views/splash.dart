import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:myapp/views/pinscreen.dart';
import 'package:myapp/views/setpin.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<String> images = [
    'assets/images/image1.jpg',
    'assets/images/image2.jpg',
    'assets/images/image3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    // Set a timer to change screen after 5 seconds
    Timer(Duration(seconds: 5), () {
      if (isFirstTime) {
        // Navigate to Set Pin Page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SetPinPage()),
        );
      } else {
        // Navigate to Enter Pin Page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AuthenticationPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 2),
              aspectRatio: MediaQuery.of(context).size.aspectRatio,
            ),
            items: images.map((imagePath) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Image.asset(imagePath, fit: BoxFit.cover),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}



class EnterPinPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Pin'),
      ),
      body: Center(
        child: Text('Enter your PIN here'),
      ),
    );
  }
}
