import 'package:docjo/UI/AppointmentScreen.dart';
import 'package:docjo/UI/DrawerWidget.dart';
import 'package:docjo/UI/HomeScreen.dart';
import 'package:docjo/UI/LoginScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils/Colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

//
class _SplashScreenState extends State<SplashScreen> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? login;
  @override
  void initState() {
    getUserDetails();
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      print(login);
      if (login != null) {
        Future.delayed(Duration(seconds: 0), () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (builder) => ScreensManager()));
        });
      } else {
        Future.delayed(Duration(seconds: 5), () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (builder) => LoginScreenPage()));
        });
      }
    });
  }

  getUserDetails() async {
    SharedPreferences _data = await _prefs;
    login = _data.getString("login")?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 25),
        child: Center(
          child: Stack(
            children: [
              Image.asset(
                "assets/logo.jpg",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
