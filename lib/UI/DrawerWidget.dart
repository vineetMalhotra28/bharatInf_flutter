import 'package:docjo/LanguageStrings/StringsEnglish.dart';
import 'package:docjo/LanguageStrings/arabic_strings.dart';
import 'package:docjo/UI/AppointmentScreen.dart';
import 'package:docjo/UI/HomeScreen.dart';
import 'package:docjo/UI/NotificationScreen/notification_screen.dart';
import 'package:docjo/UI/SettingScreens/setting_screen.dart';
import 'package:docjo/controllers/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/Colors.dart';

class ScreensManager extends StatefulWidget {
  const ScreensManager({Key? key}) : super(key: key);

  @override
  State<ScreensManager> createState() => _ScreensManagerState();
}

class _ScreensManagerState extends State<ScreensManager> {
  List<Widget> screens = [
    AppointmentScreen(),
    NotificationScreen(),
  ];
  int currentActive = 0;

  void changeScreen(int index) {
    setState(() {
      currentActive = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Widget drawer = DrawerWidget(
    //     // curentActive: currentActive,
    //     // onChange: changeScreen,
    //     );
    return Scaffold(
      // drawer: drawer,
      body: screens[currentActive],
    );
  }
}

class DrawerWidget extends StatelessWidget {
  const DrawerWidget(
    this.lang, {
    Key? key,
    required this.token,
  }) : super(key: key);

  final String lang;
  final String token;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48.0),
        child: Column(
          children: [
            InkWell(
              // onTap: () => onChange(0),
              child: DrawerItem(
                title: lang == "en"
                    ? EnglishStrings().appointments
                    : ArabicStrings().appointments,
                icon: Icons.home,
                active: true,
              ),
            ),
            InkWell(
              // onTap: () => onChange(1),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationScreen())),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DrawerItem(
                    title: lang == "en"
                        ? EnglishStrings().notifications
                        : ArabicStrings().notifications,
                    icon: Icons.notifications,
                    active: false,
                  ),
                  Container(
                    height: 25,
                    width: 25,
                    margin: EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        NotificationController.count.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              // onTap: () => onChange(1),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingScreen(),
                ),
              ),
              child: DrawerItem(
                title: lang == "en"
                    ? EnglishStrings().settings
                    : ArabicStrings().settings,
                icon: Icons.settings,
                active: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.active,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: active ? commonColor.withOpacity(.1) : null,
      child: Row(
        children: [
          Icon(
            icon,
            size: 28,
            color: commonColor,
          ),
          SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: commonColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
