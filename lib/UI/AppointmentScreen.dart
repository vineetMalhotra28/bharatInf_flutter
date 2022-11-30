import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:docjo/LanguageStrings/StringsEnglish.dart';
import 'package:docjo/Network/api.dart';
import 'package:docjo/UI/DrawerWidget.dart';
import 'package:docjo/UI/HomeScreen.dart';
import 'package:docjo/UI/Reschedule.dart';
import 'package:docjo/Utils/Colors.dart';
import 'package:docjo/Utils/CommonUI.dart';
import 'package:docjo/controllers/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../LanguageStrings/arabic_strings.dart';
import '../Utils/SharedPreferences.dart';
import 'LoginScreen.dart';
// import 'package:shared_preferences/shared_preferences.dart'

// dart' as http;

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  var token = "";

  String whichL = "";

  bool? conn;

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool isloading = true;
  bool alertloading = false;

  List appointmentList = [];
  List filterassignment = [];

  fetchAllhomedata(String lang) async {
    var res = await fetchAllAppointment();

    setState(() {
      isloading = false;
      if (isloading == false) {
        appointmentList = res["data"];
      } else {
        Image.asset('assets/images/nointernet.jpg');
      }
    });
  }

  fetchAllAppointment() async {
    try {
      var jsonResponse = null;
      Response response = await http.get(Uri.parse(UserHome_api), headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json"
      });
      jsonResponse = json.decode(response.body);
      var message = jsonResponse["message"];

      if (jsonResponse["status_code"] == 200) {
        var response = jsonResponse;
        return response;
      } else {}
    } catch (err) {
      customToastMsg(EnglishStrings().server_error);
    }
  }

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
    checkConnection();

    super.initState();
    getUserDetails();
  }

  checkConnection() {
    if (_connectionStatus.name.toString() == "none" ||
        _connectionStatus.name.toString() == "wifi" ||
        _connectionStatus.name.toString() == "mobile") {
      conn = false;
      return false;
    } else {
      conn = true;
      return true;
    }
  }

  getUserDetails() async {
    //checkConnection();
    SharedPreferences _data = await _prefs;
    token = _data.getString("token").toString();
    whichL = _data.getString("lang").toString();
    NotificationController.getNotificationCount(token);
    print('get from prefs -- $whichL');
    // print(whichL);
    // await updateAPILangauge(whichL);
    fetchAllhomedata(whichL);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(whichL, token: token),
      appBar: AppBar(
          leading: Builder(builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.format_align_justify_rounded),
            );
          }),
          title: Container(
              // margin: EdgeInsets.only(left: 10),
              child: Image.asset(
            'assets/logo.jpg',
            height: 90,
            width: 90,
          )),
          backgroundColor: commonColor,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                logout();
              },
              icon: Icon(
                Icons.logout,
                color: black,
              ),
            ),
          ]),
      body: conn == true
          ? Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset("assets/nointernet.jpg"),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15.0),
                      topLeft: Radius.circular(15.0)),
                ),
                child: isloading == true
                    ? Container(
                        child: Center(child: CircularProgressIndicator()))
                    : RefreshIndicator(
                        onRefresh: _pullRefresh,
                        child: ListView.builder(
                          itemCount: appointmentList.length,
                          itemBuilder: (context, index) {
                            return Container(
                              child: Card(
                                  color: lightBlue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(
                                                              appointmentList[
                                                                      index]
                                                                  ["image"]),
                                                    ),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    Text(
                                                      appointmentList[index]
                                                          ["name"],
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: textBlue),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              OutlinedButton(
                                                onPressed: null,
                                                style: OutlinedButton.styleFrom(
                                                    backgroundColor:
                                                        appointmentList[index][
                                                                    "status"] ==
                                                                "confirmed"
                                                            ? lightGreen
                                                            : lightPink,
                                                    primary: Colors.black,
                                                    //<-- SEE HERE

                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30.0))),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                        appointmentList[index][
                                                                    "status"] ==
                                                                "confirmed"
                                                            ? ((appointmentList[index]
                                                                            [
                                                                            "status"] ==
                                                                        "confirmed" &&
                                                                    whichL ==
                                                                        "en")
                                                                ? EnglishStrings()
                                                                    .confirmed
                                                                : ArabicStrings()
                                                                    .confirmed)
                                                            : (whichL == "en")
                                                                ? EnglishStrings()
                                                                    .unconfirmed
                                                                : ArabicStrings()
                                                                    .unconfirmed,
                                                        style: TextStyle(
                                                          color: appointmentList[
                                                                          index]
                                                                      [
                                                                      "status"] ==
                                                                  "confirmed"
                                                              ? darkGreen
                                                              : darkPink,
                                                        )),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    Icon(
                                                      Icons.info,
                                                      color: appointmentList[
                                                                      index]
                                                                  ["status"] ==
                                                              "confirmed"
                                                          ? darkGreen
                                                          : darkPink,
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8.0,
                                                bottom: 8.0,
                                                left: 4.0),
                                            child: Row(
                                              children: [
                                                SizedBox(width: 10),
                                                Text(
                                                  appointmentList[index]
                                                      ["type"],
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: textBlueDark),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(width: 10),
                                              Icon(Icons.calendar_month,
                                                  color: textBlue),
                                              Text(
                                                appointmentList[index]
                                                    ["follow_up_date"],
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: textBlueDark,
                                                    fontWeight:
                                                        FontWeight.w800),
                                              ),
                                            ],
                                          ),
                                          appointmentList[index]["status"] ==
                                                  "confirmed"
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10.0,
                                                          left: 10.0,
                                                          right: 0.0),
                                                  child: Row(
                                                    children: [
                                                      OutlinedButton(
                                                        style: ButtonStyle(
                                                          shape:
                                                              MaterialStateProperty
                                                                  .all(
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30.0),
                                                            ),
                                                          ),
                                                          side: MaterialStateProperty
                                                              .resolveWith<
                                                                      BorderSide>(
                                                                  (states) =>
                                                                      BorderSide(
                                                                          color:
                                                                              commonColor,
                                                                          width:
                                                                              1)),
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .resolveWith<
                                                                          Color>(
                                                                      (states) =>
                                                                          white),
                                                        ),
                                                        onPressed: () {
                                                          onReschedule(
                                                              appointmentList[
                                                                      index][
                                                                  "follow_up_id"]);
                                                        },
                                                        child: Text(
                                                          whichL == 'en'
                                                              ? EnglishStrings()
                                                                  .reschedule
                                                              : ArabicStrings()
                                                                  .reschedule,
                                                          style: const TextStyle(
                                                              color:
                                                                  commonColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              fontSize: 13),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 18.0),
                                                        child: CircleAvatar(
                                                          backgroundColor:
                                                              lightPink,
                                                          child: IconButton(
                                                              onPressed: () {
                                                                conn == false
                                                                    ? showAlertDialogDelete(
                                                                        context,
                                                                        int.parse(appointmentList[index]["follow_up_id"]
                                                                            .toString()),
                                                                        appointmentList[index]
                                                                            [
                                                                            "status"],
                                                                        appointmentList[index]
                                                                            [
                                                                            "follow_up_date"])
                                                                    : customToastMsg(whichL ==
                                                                            "en"
                                                                        ? EnglishStrings()
                                                                            .internet_connection_lost
                                                                        : ArabicStrings()
                                                                            .internet_connection_lost);
                                                              },
                                                              icon: Icon(
                                                                Icons.delete,
                                                                color: darkPink,
                                                              )),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10.0,
                                                          left: 10.0),
                                                  child: Row(
                                                    children: [
                                                      OutlinedButton(
                                                        onPressed: () {
                                                          conn == false
                                                              ? showAlertDialog(
                                                                  context,
                                                                  int.parse(appointmentList[
                                                                              index]
                                                                          [
                                                                          "follow_up_id"]
                                                                      .toString()),
                                                                  appointmentList[
                                                                          index]
                                                                      [
                                                                      "status"],
                                                                  appointmentList[
                                                                          index]
                                                                      [
                                                                      "follow_up_date"])
                                                              : customToastMsg(whichL ==
                                                                      "en"
                                                                  ? EnglishStrings()
                                                                      .internet_connection_lost
                                                                  : ArabicStrings()
                                                                      .internet_connection_lost);
                                                        },
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(
                                                                      commonColor),
                                                          shape: MaterialStateProperty
                                                              .all(
                                                                  RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30.0),
                                                          )),
                                                        ),
                                                        child: Text(
                                                          whichL == 'en'
                                                              ? EnglishStrings()
                                                                  .confirmed
                                                              : ArabicStrings()
                                                                  .confirmed,
                                                          style: TextStyle(
                                                              color: white),
                                                        ),
                                                      ),

                                                      /*OutlinedButton(
                                                                                onPressed: null,
                                                                                style: ButtonStyle(
                                                                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(30.0),
                                                                                  side: BorderSide(color: Colors.red, width: 10),)
                                                                                  ),
                                                                                  ),
                                                                                  child: Text("Reschedule", style: TextStyle(color: commonColor),),
                                                                                  ),*/

                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 18.0),
                                                        child: OutlinedButton(
                                                          style: ButtonStyle(
                                                            shape:
                                                                MaterialStateProperty
                                                                    .all(
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30.0),
                                                              ),
                                                            ),
                                                            side: MaterialStateProperty.resolveWith<
                                                                    BorderSide>(
                                                                (states) =>
                                                                    BorderSide(
                                                                        color:
                                                                            commonColor,
                                                                        width:
                                                                            1)),
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .resolveWith<
                                                                            Color>(
                                                                        (states) =>
                                                                            white),
                                                          ),
                                                          onPressed: () {
                                                            onReschedule(
                                                                appointmentList[
                                                                        index][
                                                                    "follow_up_id"]);
                                                          },
                                                          child: Text(
                                                            whichL == 'en'
                                                                ? EnglishStrings()
                                                                    .reschedule
                                                                : ArabicStrings()
                                                                    .reschedule,
                                                            style: const TextStyle(
                                                                color:
                                                                    commonColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                fontSize: 13),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 18.0),
                                                        child: CircleAvatar(
                                                          backgroundColor:
                                                              lightPink,
                                                          child: IconButton(
                                                              onPressed: () {
                                                                conn == false
                                                                    ? showAlertDialogDelete(
                                                                        context,
                                                                        int.parse(appointmentList[index]["follow_up_id"]
                                                                            .toString()),
                                                                        appointmentList[index]
                                                                            [
                                                                            "status"],
                                                                        appointmentList[index]
                                                                            [
                                                                            "follow_up_date"])
                                                                    : customToastMsg(whichL ==
                                                                            "en"
                                                                        ? EnglishStrings()
                                                                            .internet_connection_lost
                                                                        : ArabicStrings()
                                                                            .internet_connection_lost);
                                                              },
                                                              icon: Icon(
                                                                Icons.delete,
                                                                color: darkPink,
                                                              )),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                        ],
                                      ))),
                            );
                          },
                        ),
                      ),
              ),
            ),
    );
  }

  Future<void> confirmAppointment(var followUpId, var isConfirmed) async {
    String vale = '';
    if (isConfirmed == 'unconfirmed') {
      vale = "1";
    }
    final Map<String, dynamic> data = {
      "follow_up_id": "$followUpId",
      "is_confirm": vale,
    };

    showProgressDialogBox(context);

    try {
      var jsonResponse = null;
      var response =
          await http.post(Uri.parse(confirm_api), body: data, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      Map<String, dynamic> data1 =
          new Map<String, dynamic>.from(json.decode(response.body));
      if (response.statusCode == 200) {
        setState(() {
          // checkConnection();
          ConnectivityResult _connectionStatus = ConnectivityResult.none;
          final Connectivity _connectivity = Connectivity();
          late StreamSubscription<ConnectivityResult>
              _connectivitySubscription = _connectivity.onConnectivityChanged
                  .listen(_updateConnectionStatus);
          if (_connectionStatus.name.toString() == "wifi" ||
              _connectionStatus.name.toString() == "mobile" ||
              _connectionStatus.name.toString() == "none") {
            conn = false;
            getUserDetails();
            Navigator.pop(context);
          } else {
            conn = true;
            Navigator.pop(context);
          }
          // initConnectivity();
        });

        customToastMsg(data1['message']);
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        customToastMsg("Please try again");
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
      // print("errooor" + err.toString());
    }
  }

  Future<void> deleteAppointment(var followUpId, var isConfirmed) async {
    String vale = '';
    if (isConfirmed == 'confirmed' || isConfirmed == 'unconfirmed') {
      vale = "2";
    }
    final Map<String, dynamic> data = {
      "follow_up_id": "$followUpId",
      "is_confirm": vale,
    };

    showProgressDialogBox(context);

    try {
      var jsonResponse = null;
      var response =
          await http.post(Uri.parse(confirm_api), body: data, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      Map<String, dynamic> data1 =
          new Map<String, dynamic>.from(json.decode(response.body));
      if (response.statusCode == 200) {
        setState(() {
          // checkConnection();
          ConnectivityResult _connectionStatus = ConnectivityResult.none;
          final Connectivity _connectivity = Connectivity();
          late StreamSubscription<ConnectivityResult>
              _connectivitySubscription = _connectivity.onConnectivityChanged
                  .listen(_updateConnectionStatus);
          if (_connectionStatus.name.toString() == "wifi" ||
              _connectionStatus.name.toString() == "mobile" ||
              _connectionStatus.name.toString() == "none") {
            conn = false;
            getUserDetails();
            Navigator.pop(context);
          } else {
            conn = true;
            Navigator.pop(context);
          }
          // initConnectivity();
        });

        customToastMsg(data1['message']);
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        customToastMsg("Please try again");
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
    }
  }

  Future<void> logout() async {
    showProgressDialogBox(context);

    try {
      var jsonResponse = null;
      var response = await http.get(Uri.parse(Logout_api),
          headers: {"Authorization": "Bearer $token"});
      jsonResponse = json.decode(response.body);
      var message = jsonResponse["message"];
      Navigator.pop(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
      Navigator.popUntil(
        context,
        (route) => false,
      );
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => LoginScreenPage(),
      ));
      if (response.statusCode == 200) {
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        customToastMsg(message);
      } else {
        customToastMsg(EnglishStrings().server_error);
      }
    } catch (err) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
      Navigator.popUntil(
        context,
        (route) => false,
      );
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => LoginScreenPage(),
      ));
      customToastMsg(EnglishStrings().server_error);
    }
  }

  Future<void> _pullRefresh() async {
    setState(() {
      // checkConnection();
      ConnectivityResult _connectionStatus = ConnectivityResult.none;
      final Connectivity _connectivity = Connectivity();
      late StreamSubscription<ConnectivityResult> _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
      if (_connectionStatus.name.toString() == "wifi" ||
          _connectionStatus.name.toString() == "mobile" ||
          _connectionStatus.name.toString() == "none") {
        conn = false;
        getUserDetails();
      } else {
        conn = true;
      }
      // initConnectivity();
    });
  }

  showAlertDialog(
      BuildContext context, var followUpId, var isConfirmed, var followUpDate) {
    // set up the buttons

    // Widget continueButton = TextButton(
    //   child: Text("Confirm"),
    //   onPressed:  () {
    //     confirmAppointment(followUpId, isConfirmed);
    //   },
    // );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Center(child: Text("Confirm")),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "Are you sure you want to confirm this Appointment?\n\n$followUpDate",
                style: TextStyle(fontSize: 11, color: commonColor),
                textAlign: TextAlign.center),
          ],
        ),
      ),
      actions: [
        // cancelButton,
        // continueButton,
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              OutlinedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  side: MaterialStateProperty.resolveWith<BorderSide>(
                      (states) => BorderSide(color: commonColor, width: 1)),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) => white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  whichL == "en"
                      ? EnglishStrings().cancel
                      : ArabicStrings().cancel,
                  style: TextStyle(
                      color: commonColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13),
                ),
              ), // button 1
              SizedBox(
                width: 15,
              ),
              OutlinedButton(
                onPressed: () {
                  confirmAppointment(followUpId, isConfirmed);
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(commonColor),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  )),
                ),
                child: Text(
                  "Confirm",
                  style: TextStyle(color: white),
                ),
              ), // button 2
            ])
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialogDelete(
      BuildContext context, var followUpId, var isConfirmed, var followUpDate) {
    AlertDialog alert = AlertDialog(
      title: Center(
          child: Text(
        whichL == "en" ? EnglishStrings().delete : ArabicStrings().delete,
      )),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                whichL == "en"
                    ? EnglishStrings()
                        .are_you_sure_you_want_to_delete_this_appointment
                    : ArabicStrings()
                            .are_you_sure_want_to_delete_this_appointment +
                        "\n\n$followUpDate",
                style: TextStyle(fontSize: 11, color: commonColor),
                textAlign: TextAlign.center),
          ],
        ),
      ),
      actions: [
        // cancelButton,
        // continueButton,
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              OutlinedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  side: MaterialStateProperty.resolveWith<BorderSide>(
                      (states) => BorderSide(color: commonColor, width: 1)),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) => white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  whichL == "en"
                      ? EnglishStrings().cancel
                      : ArabicStrings().cancel,
                  style: TextStyle(
                      color: commonColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13),
                ),
              ), // button 1
              SizedBox(
                width: 15,
              ),
              OutlinedButton(
                onPressed: () {
                  deleteAppointment(followUpId, isConfirmed);
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(commonColor),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  )),
                ),
                child: Text(
                  whichL == "en"
                      ? EnglishStrings().delete
                      : ArabicStrings().delete,
                  style: TextStyle(color: white),
                ),
              ), // button 2
            ])
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  reschedule(BuildContext context, List dates, int id) {
    String? selectedDate;
    String? selectedTime;
    // List<String> times = [];
    AlertDialog alert = AlertDialog(
      title: Text(whichL == "en"
          ? EnglishStrings().reschedule
          : ArabicStrings().reschedule),
      content: alertloading
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Reschedule(
                    lang: whichL,
                    dates: dates,
                    dateValue: (value) {
                      selectedDate = value;
                    },
                    timeValue: (value) {
                      selectedTime = value;
                    },
                  ),
                ],
              ),
            ),
      actions: [
        // cancelButton,
        // continueButton,
        Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              OutlinedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  side: MaterialStateProperty.resolveWith<BorderSide>(
                      (states) => BorderSide(color: commonColor, width: 1)),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) => white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  whichL == "en"
                      ? EnglishStrings().cancel
                      : ArabicStrings().cancel,
                  style: TextStyle(
                      color: commonColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13),
                ),
              ), // button 1
              SizedBox(
                width: 15,
              ),
              OutlinedButton(
                onPressed: () {
                  if (selectedDate == null || selectedTime == null) {
                    customToastMsg('Date or time can\'t be empty!');
                    return;
                  }
                  submitReschedule(selectedDate, selectedTime, id);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(commonColor),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  )),
                ),
                child: Text(
                  whichL == "en"
                      ? EnglishStrings().reschedule
                      : ArabicStrings().reschedule,
                  style: TextStyle(color: white),
                ),
              ), // button 2
            ])
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> onReschedule(int id) async {
    List? dates = await fetchAllAvailableDates(id);

    if (dates != null) {
      reschedule(context, dates, id);
    }
  }

  Future<List?> fetchAllAvailableDates(int followUpId) async {
    try {
      Response response =
          await http.post(Uri.parse(showAvailableSlots_api), headers: {
        "Authorization": "Bearer $token"
      }, body: {
        "follow_up_id": followUpId.toString(),
      });

      var jsonResponse = json.decode(response.body);

      if (jsonResponse["status_code"] == 200) {
        List data = jsonResponse["data"] as List;

        return data;
      } else {
        customToastMsg(jsonResponse["message"]);
        return null;
      }
    } catch (err) {
      customToastMsg(EnglishStrings().server_error + ' $err!');
      return null;
    }
  }

  Future<void> submitReschedule(
      String? selectedDate, String? selectedTime, int id) async {
    selectedTime = selectedTime!.split(' ')[0];

    try {
      setState(() {
        alertloading = true;
      });
      Response response = await http.post(
        Uri.parse(rescheduleMeeting_api),
        headers: {"Authorization": "Bearer $token"},
        body: {
          "follow_up_id": id.toString(),
          "date": selectedDate,
          "time": selectedTime,
        },
      );

      setState(() {
        alertloading = false;
      });
      var jsonResponse = json.decode(response.body);

      if (jsonResponse["status_code"] == 200) {
        List data = jsonResponse["data"] as List;
        await _pullRefresh();
        Navigator.pop(context);
        customToastMsg(jsonResponse["message"]);
        // return data;
      } else {
        setState(() {
          alertloading = false;
        });
        customToastMsg(jsonResponse["message"]);
        return null;
        // Navigator.pop(context);
      }
    } catch (err) {
      setState(() {
        alertloading = false;
      });
      customToastMsg(EnglishStrings().server_error + ' Please try again!');
      return null;
      // Navigator.pop(context);
    }
  }

  updateAPILangauge(String lang) async {
    try {
      Response response = await http.post(
        Uri.parse(set_user_language_api),
        headers: {"Authorization": "Bearer $token"},
        body: {
          "lang": lang,
        },
      );
      if (response.statusCode != 200) {
        customToastMsg("Something went wrong while changing language");
      }
    } catch (e) {
      customToastMsg(e.toString());
    }
  }
}
