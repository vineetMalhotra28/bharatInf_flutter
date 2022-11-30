import 'dart:async';
import 'dart:convert';
import 'package:docjo/UI/AppointmentScreen.dart';
import 'package:docjo/controllers/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../LanguageStrings/StringsEnglish.dart';
import '../LanguageStrings/arabic_strings.dart';
import '../Network/LanguageLoginModel.dart';
import '../Network/api.dart';
import '../Utils/Colors.dart';
import '../Utils/CommonUI.dart';
import '../Utils/SharedPreferences.dart';
import 'dart:developer' as developer;

import '../Utils/Utils.dart';
import 'HomeScreen.dart';

class LoginScreenPage extends StatefulWidget {
  LoginScreenPage({Key? key}) : super(key: key);

  @override
  State<LoginScreenPage> createState() => _LoginScreenPageState();
}

class _LoginScreenPageState extends State<LoginScreenPage> {
  var which = 1;
  var hintClose = false;
  var lng = "English";
  var _passwordVisible = false;
  LanguageModel? languageModel;
  TextEditingController _phonwNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String whichL = "en";
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
    Future.delayed(Duration.zero, () {
      getDetails();
      setState(() {});
    });
    _passwordVisible = false;
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    super.initState();
  }

  getDetails() async {
    SharedPreferences _data = await _prefs;
    whichL = _data.getString("lang").toString();
    if (whichL == "en") {
      setState(() {
        lng = "English";
      });
    } else {
      setState(() {
        lng = "عربى";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        height: height(context),
        width: width(context),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              box(height: height(context) / 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    whichL == "en"
                        ? EnglishStrings().login
                        : ArabicStrings().login,
                    style: TextStyle(fontSize: 30),
                  ),
                  Row(
                    children: [
                      Text(
                        lng,
                        style: TextStyle(
                            fontSize: 17,
                            color: black,
                            fontWeight: FontWeight.bold),
                      ),
                      Container(
                        child: DropdownButton<String>(
                          underline: Container(),
                          items:
                              <String>['English', 'عربى'].map((String value) {
                            return DropdownMenuItem<String>(
                              onTap: () {},
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: black),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) async {
                            setState(() {
                              lng = val.toString();
                              if (lng == "English") {
                                SaveStringToSF("lang", "en");
                                whichL = "en";
                                print("done");
                              } else {
                                whichL = "ar";
                                SaveStringToSF("lang", "ar");
                                print("done");
                              }
                              lng = val.toString();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              box(height: 30),
              Container(
                width: width(context) - 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: commonColor, width: 2)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          which = 1;
                        });
                      },
                      child: Container(
                        decoration: which == 1
                            ? BoxDecoration(
                                color: commonColor,
                                borderRadius: BorderRadius.circular(50),
                              )
                            : null,
                        padding:
                            EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                        child: Text(
                          whichL == "en"
                              ? EnglishStrings().byEmail
                              : ArabicStrings().byEmail,
                          style: TextStyle(
                              fontSize: 14,
                              color: which == 1 ? white : black,
                              fontWeight: which == 1 ? FontWeight.bold : null),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          which = 2;
                        });
                      },
                      child: Container(
                        decoration: which == 2
                            ? BoxDecoration(
                                color: commonColor,
                                borderRadius: BorderRadius.circular(50),
                              )
                            : null,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        child: Text(
                          whichL == "en"
                              ? EnglishStrings().phone
                              : ArabicStrings().phone,
                          style: TextStyle(
                              fontSize: 14,
                              color: which == 2 ? white : black,
                              fontWeight: which == 2 ? FontWeight.bold : null),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              box(height: 30),
              // Container(
              //   padding: hintClose
              //       ? null
              //       : EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              //   decoration: hintClose
              //       ? null
              //       : BoxDecoration(
              //           color: Color.fromARGB(255, 180, 199, 233),
              //           borderRadius: BorderRadius.circular(10)),
              //   child: hintClose
              //       ? Container()
              //       : SingleChildScrollView(
              //           child: Row(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               InkWell(
              //                 onTap: () {
              //                   setState(() {
              //                     hintClose = true;
              //                   });
              //                 },
              //                 child: Icon(Icons.close),
              //               ),
              //               box(width: 15),
              //               Text(
              //                 whichL == "en"
              //                     ? EnglishStrings().alert
              //                     : ArabicStrings().alert,
              //                 style: TextStyle(
              //                   color: white,
              //                   fontSize: 18,
              //                 ),
              //                 maxLines: 3,
              //                 overflow: TextOverflow.ellipsis,
              //               ),
              //             ],
              //           ),
              //         ),
              // ),
              // box(height: 30),
              which == 1 ? emailDesign() : phoneNumderDesign(),
              box(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    whichL == "en"
                        ? EnglishStrings().bottomAcc
                        : ArabicStrings().bottomAcc,
                    style: TextStyle(fontSize: 17),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      whichL == "en"
                          ? EnglishStrings().start
                          : ArabicStrings().start,
                      style: TextStyle(fontSize: 17),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  //Email layout design
  Widget emailDesign() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: commonColor, width: 2)),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: whichL == "en"
                  ? EnglishStrings().email
                  : ArabicStrings().email,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
                borderSide: BorderSide(width: 0.6),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
                borderSide: BorderSide(color: Colors.white, width: 0.6),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
                borderSide: BorderSide(color: commonColor, width: 0.6),
              ),
              hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: grey,
                  fontFamily: 'Poppins'),
            ),
            keyboardType: TextInputType.text,
            controller: emailController,
            //onSaved: (value)=>_phoneNumber=value,
          ),
        ),
        box(height: 15),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: commonColor, width: 2)),
          child: TextFormField(
            obscureText: !_passwordVisible, //This will obscure text dynamically
            decoration: InputDecoration(
              hintText: whichL == "en"
                  ? EnglishStrings().password
                  : ArabicStrings().password,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: Icon(
                  // Based on passwordVisible state choose the icon
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Theme.of(context).primaryColorDark,
                ),
                onPressed: () {
                  // Update the state i.e. toogle the state of passwordVisible variable
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
                borderSide: BorderSide(width: 0.6),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
                borderSide: BorderSide(color: Colors.white, width: 0.6),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
                borderSide: BorderSide(color: commonColor, width: 0.6),
              ),
              hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: grey,
                  fontFamily: 'Poppins'),
            ),
            keyboardType: TextInputType.text,
            controller: passwordController,
          ),
        ),
        box(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                checkConnection()
                    ? login(emailController.text.toString(),
                        passwordController.text.toString())
                    : customToastMsg(whichL == "en"
                        ? EnglishStrings().internet_connection_lost
                        : ArabicStrings().internet_connection_lost);
                ;
              },
              child: Container(
                decoration: BoxDecoration(
                  color: commonColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                child: Text(
                  whichL == "en"
                      ? EnglishStrings().login
                      : ArabicStrings().login,
                  style: TextStyle(
                      fontSize: 17, color: white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                whichL == "en"
                    ? EnglishStrings().forgetPassword
                    : ArabicStrings().forgetPassword,
                style: TextStyle(fontSize: 17),
              ),
            )
          ],
        ),
      ],
    );
  }

  // Phone number layout design
  Widget phoneNumderDesign() {
    return Container(
        child: Column(children: [
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: commonColor, width: 2)),
        child: TextFormField(
          decoration: InputDecoration(
            hintText:
                whichL == "en" ? EnglishStrings().phone : ArabicStrings().phone,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(width: 0.6),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.white, width: 0.6),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: commonColor, width: 0.6),
            ),
            hintStyle: TextStyle(
                fontWeight: FontWeight.w400,
                color: grey,
                fontFamily: 'Poppins'),
          ),
          keyboardType: TextInputType.phone,
          controller: _phonwNumberController,
          obscureText: true,
        ),
      ),
      Container(
        margin: EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: commonColor,
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
        child: Text(
          whichL == "en" ? EnglishStrings().sendcode : ArabicStrings().sendcode,
          style: TextStyle(
              fontSize: 20, color: white, fontWeight: FontWeight.bold),
        ),
      ),
    ]));
  }

  //login
  Future<void> login(String email, String password) async {
    Map data = {};
    if (email.isEmpty) {
      customToastMsg(whichL == "en"
          ? EnglishStrings().email_alert
          : ArabicStrings().email_alert);
      return;
    } else if (password.isEmpty) {
      customToastMsg(whichL == "en"
          ? EnglishStrings().password_alert
          : ArabicStrings().password_alert);
      return;
    } else if (isValidEmail(email) == false) {
      customToastMsg(whichL == "en"
          ? EnglishStrings().valid_alert
          : ArabicStrings().valid_alert);
      return;
    }

    data["email"] = email.toString();
    data["password"] = password.toString();
    data["lang"] = whichL;
    data["device_type"] = "android";
    String token = (await NotificationController().messagingToken())!;
    print(token);
    data["device_token"] = token;

    showProgressDialogBox(context);

    try {
      var jsonResponse = null;
      var response = await http.post(Uri.parse(Login_api), body: data);
      jsonResponse = json.decode(response.body);
      var message = jsonResponse["message"];
      Navigator.pop(context);
      if (response.statusCode == 200) {
        var token = jsonResponse["data"]["token"];
        SaveStringToSF("login", "1");
        SaveStringToSF("token", token.toString());
        print("save");
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (builder) => AppointmentScreen()));
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        customToastMsg(message);
      } else {
        customToastMsg(whichL == "en"
            ? EnglishStrings().server_error
            : ArabicStrings().server_error);
      }
    } catch (err) {
      Navigator.pop(context);
      customToastMsg(whichL == "en"
          ? EnglishStrings().server_error
          : ArabicStrings().server_error);
      print("errooor" + err.toString());
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
