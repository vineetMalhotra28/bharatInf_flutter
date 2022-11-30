import 'dart:async';
import 'dart:convert';
import 'package:docjo/UI/LoginScreen.dart';
import 'package:docjo/Utils/CommonUI.dart';
import 'package:docjo/Utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../LanguageStrings/StringsEnglish.dart';
import '../Network/api.dart';
import '../Utils/Colors.dart';


import 'package:connectivity_plus/connectivity_plus.dart';
  import 'dart:developer' as developer;


class HomeScreenPage extends StatefulWidget {
  HomeScreenPage({Key? key}) : super(key: key);

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var token = "";
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;


  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  void initState() {
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    getUserDetails();
    super.initState();
  }

  getUserDetails() async {
    SharedPreferences _data = await _prefs;
    token = _data.getString("token").toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              box(height: 100),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  "assets/logo.jpg",
                ),
              ),
              box(height: 70),
              Text(
                "Welcome to Docjo",
                style: TextStyle(
                    fontSize: 40,
                    color: commonColor,
                    fontWeight: FontWeight.bold),
              ),
              box(height: height(context) / 8),
              Text(
                "You are successfully login....",
                style: TextStyle(
                    fontSize: 25,
                    color: Color.fromARGB(255, 62, 103, 163),
                    fontWeight: FontWeight.bold),
              ),
              box(height: height(context) / 10),
              InkWell(
                onTap: () {
                  checkConnection()
                      ? logout()
                      : customToastMsg(EnglishStrings().internet_connection_lost);
                  ;

                },
                child: Container(
                  decoration: BoxDecoration(
                    color: commonColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                        fontSize: 20,
                        color: white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //login
  Future<void> logout() async {
    showProgressDialogBox(context);

   try{
     var jsonResponse = null;
     var response = await http.get(Uri.parse(Logout_api),
         headers: {"Authorization": "Bearer $token"});
     jsonResponse = json.decode(response.body);
     var message = jsonResponse["message"];
     print(message);
     Navigator.pop(context);
     if (response.statusCode == 200) {
       SharedPreferences preferences = await SharedPreferences.getInstance();
       await preferences.clear();
       Navigator.pushReplacement(
           context, MaterialPageRoute(builder: (builder) => LoginScreenPage()));
     } else if(response.statusCode==400||response.statusCode==401) {
       customToastMsg(message);
     }else{
       customToastMsg(EnglishStrings().server_error);
     }
   }catch(err) {
     Navigator.pop(context);
     customToastMsg(EnglishStrings().server_error);
     print("errooor"+err.toString());
   }
  }

  checkConnection() {
    if (_connectionStatus.name.toString() == "none") {
      return false;
    } else {
      return true;
    }
  }
}
