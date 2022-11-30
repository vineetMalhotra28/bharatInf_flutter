import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:firebase_messaging/firebase_messaging.dart';

import '../Network/api.dart';
import '../Utils/CommonUI.dart';

class NotificationController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static int? count;

  Future<String?> messagingToken() async {
    final String? _token = await _firebaseMessaging.getToken();
    return _token;
  }

  static Future<int> getNotificationCount(String token) async {
    if (count == null) {
      await _getNotificationCount(token);
      return count ?? 0;
    }
    return count ?? 0;
  }

  static Future _getNotificationCount(String token) async {
    try {
      var jsonResponse = null;
      var response =
          await http.get(Uri.parse(getUserNotificationCount), headers: {
        // 'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      jsonResponse = json.decode(response.body);
      // String message = jsonResponse["message"];

      if (response.statusCode == 200) {
        count = jsonResponse["notificationCount"];
        print(jsonResponse);
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        customToastMsg(jsonResponse["message"]);
      } else {
        customToastMsg(jsonResponse["message"]);
      }
    } catch (err) {
      customToastMsg(err.toString());
      print("errooor" + err.toString());
    }
  }

  void name(params) {
    // _firebaseMessaging
  }
}
