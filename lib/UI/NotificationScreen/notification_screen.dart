import 'dart:convert';

import 'package:docjo/LanguageStrings/StringsEnglish.dart';
import 'package:docjo/LanguageStrings/arabic_strings.dart';
import 'package:docjo/UI/DrawerWidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Network/api.dart';
import '../../Utils/Colors.dart';
import '../../Utils/CommonUI.dart';
import '../../Utils/SharedPreferences.dart';
import 'notification_item.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isloading = true;

  late String token;
  String whichL = "en";

  List _data = [];

  @override
  void initState() {
    super.initState();

    getUserDetails();
  }

  void getUserDetails() async {
    SharedPreferences _data = await SharedPreferences.getInstance();
    token = _data.getString("token").toString();
    whichL = _data.getString("lang").toString();
    await fetchUserNotifications();
  }

  Future<void> fetchUserNotifications() async {
    setState(() {
      _isloading = true;
    });
    try {
      http.Response response = await http.get(
        Uri.parse(user_notifications_api),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json"
        },
        // body: {},
      );
      Map data = json.decode(response.body);
      print(data["status_code"]);
      print(data["message"]);

      if (data["status_code"] == 200) {
        _data = data["data"];
        print(_data);
        return;
      }
      customToastMsg("Server Error : ${data['message']}");
    } catch (e) {
      print(e.toString());
      customToastMsg(e.toString());
    } finally {
      setState(() {
        _isloading = false;
      });
    }
  }

  Future<void> updateUserNotifications(int type, [int? notificationId]) async {
    setState(() {
      _isloading = true;
    });
    try {
      http.Response response = await http.post(
        Uri.parse(readAndDeleteNotification),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json"
        },
        body: {
          "type": type.toString(),
          if (notificationId != null)
            "notification_id": notificationId.toString(),
        },
      );
      Map data = json.decode(response.body);
      print(data["status_code"]);
      print(data["message"]);

      if (data["status_code"] == 200) {
        customToastMsg(data["message"]);
        await fetchUserNotifications();
        print(_data);
        return;
      }
      if (data["status_code"] == 400) {
        customToastMsg(data["message"]);
        // await fetchUserNotifications();
        print(_data);
        return;
      }
      customToastMsg(data["message"]);
    } catch (e) {
      print(e.toString());
      customToastMsg("Something went wrong while updating.");
    } finally {
      if (_isloading && mounted) {
        setState(() {
          _isloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          whichL == "en"
              ? EnglishStrings().notifications
              : ArabicStrings().notifications,
        ),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        backgroundColor: commonColor,
        elevation: 0,
        actions: [
          PopupMenuButton<int>(
            onSelected: (item) => updateUserNotifications(item),
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 3,
                child: Text('Delete All'),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Text('Mark all as read'),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: Text('Mark all as unread'),
              ),
            ],
          ),
        ],
      ),
      body: _isloading
          ? const Center(child: CircularProgressIndicator())
          : _data.isEmpty
              ? const Center(
                  child: Text('No Notifications'),
                )
              : ListView.builder(
                  itemCount: _data.length,
                  itemBuilder: (context, index) => NotificationItem(
                    data: _data[index],
                    onDelete: (id) => updateUserNotifications(3, id),
                  ),
                ),
    );
  }
}
