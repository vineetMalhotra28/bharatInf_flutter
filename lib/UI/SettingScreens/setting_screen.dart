import 'dart:convert';

import 'package:docjo/LanguageStrings/StringsEnglish.dart';
import 'package:docjo/LanguageStrings/arabic_strings.dart';
import 'package:docjo/Utils/Colors.dart';
import 'package:docjo/components/language_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import '../../Network/api.dart';
import '../../Utils/CommonUI.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late String lang;
  late String token;
  late int is_notification;

  bool _loading = true;

  Future init() async {
    SharedPreferences _data = await SharedPreferences.getInstance();
    token = _data.getString("token").toString();
    lang = _data.getString("lang").toString();
    await getUserData();
  }

  Future<void> getUserData() async {
    setState(() {
      _loading = true;
    });
    try {
      http.Response response = await http.get(
        Uri.parse(getUserProfile),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json"
        },
      );
      Map data = json.decode(response.body);
      print(data["status_code"]);
      print(data["message"]);

      if (data["status_code"] == 200) {
        // customToastMsg(data["message"]);
        is_notification = data["data"]["is_notification"];

        print(data);
        return;
      }
      customToastMsg(data["message"]);
    } catch (e) {
      print(e.toString());
      customToastMsg("Something went wrong while updating.");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> updateUser({
    ///ar - for Arabic , en - for English
    String? language,

    ///1 - on
    ///0 - off
    int? notificationChange,
  }) async {
    setState(() {
      _loading = true;
    });
    try {
      http.Response response = await http.post(
        Uri.parse(changeUserSettings),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json"
        },
        body: {
          if (language != null) "lang": language,
          if (notificationChange != null)
            "is_notification": notificationChange.toString(),
        },
      );
      Map data = json.decode(response.body);
      print(data["status_code"]);
      print(data["message"]);

      if (data["status_code"] == 200) {
        customToastMsg(data["message"]);
        await getUserData();

        print(data);
        return;
      }
      customToastMsg(data["message"]);
    } catch (e) {
      print(e.toString());
      customToastMsg("Something went wrong while updating.");
    } finally {
      if (_loading) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      letterSpacing: .6,
    );
    return _loading
        ? Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back_ios),
              ),
              title: Text(
                lang == "en"
                    ? EnglishStrings().settings
                    : ArabicStrings().settings,
              ),
              centerTitle: true,
            ),
            body: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lang == "en"
                            ? EnglishStrings().language
                            : ArabicStrings().language,
                        style: _textStyle,
                      ),
                      LanguageSwitchWidget(
                        onLanguageChanged: (language) {
                          lang = language;
                          updateUser(language: language);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lang == "en"
                            ? EnglishStrings().notifications
                            : ArabicStrings().notifications,
                        style: _textStyle,
                      ),
                      CupertinoSwitch(
                        onChanged: (value) {
                          if (value) {
                            updateUser(notificationChange: 1);
                            return;
                          } else {
                            updateUser(notificationChange: 0);
                          }
                        },
                        value: is_notification == 1,
                        activeColor: commonColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
