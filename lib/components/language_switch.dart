import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../Network/api.dart';
import '../Utils/Colors.dart';
import '../Utils/CommonUI.dart';
import '../Utils/SharedPreferences.dart';

class LanguageSwitchWidget extends StatefulWidget {
  const LanguageSwitchWidget({Key? key, required this.onLanguageChanged})
      : super(key: key);

  final void Function(String language) onLanguageChanged;

  @override
  State<LanguageSwitchWidget> createState() => _LanguageSwitchWidgetState();
}

class _LanguageSwitchWidgetState extends State<LanguageSwitchWidget> {
  bool _isloading = false;

  late String token;
  String whichL = "en";

  Future<void> init() async {
    _isloading = true;
    setState(() {});
    SharedPreferences _data = await SharedPreferences.getInstance();
    token = _data.getString("token").toString();
    whichL = _data.getString("lang").toString();
    _isloading = false;
    setState(() {});
  }

  Future<void> updateAPILangauge(String lang) async {
    try {
      http.Response response = await http.post(
        Uri.parse(set_user_language_api),
        headers: {"Authorization": "Bearer $token"},
        body: {
          "lang": lang,
        },
      );
      if (response.statusCode != 200) {
        customToastMsg("Something went wrong while changing language");
        return;
      }
    } catch (e) {
      customToastMsg(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _isloading
          ? Center(child: CircularProgressIndicator())
          : DropdownButton<String>(
              hint: Text(whichL == "en" ? "English" : "عربى"),
              underline: Container(),
              items: <String>['English', 'عربى'].map((String value) {
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
                  _isloading = true;
                });

                whichL = val.toString();
                if (whichL == "English") {
                  await SaveStringToSF("lang", "en");
                  whichL = "en";
                  // await updateAPILangauge(whichL);
                  print("done - $whichL");
                } else {
                  whichL = "ar";
                  await SaveStringToSF("lang", "ar");
                  // await updateAPILangauge(whichL);
                  print("done - $whichL");
                }

                widget.onLanguageChanged(whichL);

                setState(() {
                  _isloading = false;
                });
              },
            ),
    );
  }
}
