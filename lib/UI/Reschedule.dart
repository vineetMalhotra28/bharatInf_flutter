import 'package:docjo/Utils/Colors.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../LanguageStrings/StringsEnglish.dart';
import '../LanguageStrings/arabic_strings.dart';
import 'CalanderWidget.dart';

class Reschedule extends StatefulWidget {
  const Reschedule({
    Key? key,
    required this.dates,
    this.dateValue,
    this.timeValue,
    required this.lang,
  }) : super(key: key);

  final List dates;
  final dateValue;
  final timeValue;
  final String lang;

  @override
  State<Reschedule> createState() => _RescheduleState();
}

class _RescheduleState extends State<Reschedule> {
  String? selectedDate;
  String? selectedTime;
  List<String> times = [];
  late Size size;

  ///

  ///
  final Color blueColor = Colors.blueAccent;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> _days = widget.dates.map<DateTime>((e) {
      List date = e["date"].split(" ")[0].split("-");
      // print("$date" + ">>>>>>>>>>>>>>>>>>>");

      return DateTime(
        int.parse(date[0]),
        int.parse(date[1]),
        int.parse(
          date[2],
        ),
      );
    }).toList();
    return Column(
      children: [
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: MyWidget(
                  // appointmentDates: dates,
                  appointmentDates: _days,
                  selectedDate: (p0) {
                    String value = p0.toString().split(" ")[0];
                    times.clear();

                    widget.dates.forEach((element) {
                      if (element["date"] == value) {
                        times.add(element["from"] + ' ' + element["to"]);
                      }
                    });
                    setState(() {
                      selectedDate = value;

                      widget.dateValue(selectedDate);
                      selectedTime = null;
                      widget.timeValue(selectedTime);
                    });
                    print(times);
                    Navigator.of(context).pop();
                  },
                  toDate: DateTime(2024),
                  fromDate: DateTime(2012),
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            height: 40,
            decoration: BoxDecoration(
              color: blueColor.withOpacity(.07),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: blueColor,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate?.toString() ?? "Select Date",
                  style: TextStyle(
                    fontSize: 14,
                    color: blueColor,
                  ),
                ),
                Icon(
                  Icons.calendar_month,
                  size: 16,
                  color: blueColor,
                ),
              ],
            ),
            // child: Center(
            //   child: DropdownButtonHideUnderline(
            //     child: DropdownButton2(
            //       iconDisabledColor: blueColor,
            //       iconEnabledColor: blueColor,
            //       icon: const Icon(Icons.calendar_month, size: 16),
            //       hint: Text(
            //         widget.lang == "en"
            //             ? EnglishStrings().select_date
            //             : ArabicStrings().select_date,
            //         style: TextStyle(
            //           fontSize: 14,
            //           color: blueColor,
            //         ),
            //       ),
            //       items: widget.dates
            //           .map((item) => DropdownMenuItem<String>(
            //                 value: item['date'],
            //                 child: Text(
            //                   item['date'],
            //                   style: TextStyle(
            //                     color: blueColor,
            //                     fontSize: 14,
            //                   ),
            //                 ),
            //               ))
            //           .toList(),
            //       value: selectedDate,
            //       onChanged: (String? value) {
            //         times.clear();

            //         widget.dates.forEach((element) {
            //           if (element["date"] == value) {
            //             times.add(element["from"] + ' ' + element["to"]);
            //           }
            //         });
            //         setState(() {
            //           selectedDate = value;

            //           widget.dateValue(selectedDate);
            //           selectedTime = null;
            //           widget.timeValue(selectedTime);
            //         });
            //         print(times);
            //       },
            //       buttonHeight: 40,
            //       buttonWidth: size.width * 7,
            //       itemHeight: 40,
            //     ),
            //   ),
            // ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          height: 40,
          decoration: BoxDecoration(
            color: blueColor.withOpacity(.07),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: blueColor,
            ),
          ),
          child: Center(
            child: DropdownButtonHideUnderline(
              child: DropdownButton2(
                iconDisabledColor: blueColor,
                iconEnabledColor: blueColor,
                hint: Text(
                  widget.lang == "en"
                      ? EnglishStrings().select_time
                      : ArabicStrings().select_time,
                  style: TextStyle(
                    fontSize: 14,
                    color: blueColor,
                  ),
                ),
                items: times
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyle(
                              color: blueColor,
                              fontSize: 14,
                            ),
                          ),
                        ))
                    .toList(),
                value: selectedTime,
                onChanged: (String? value) {
                  setState(() {
                    selectedTime = value;
                    widget.timeValue(value);
                  });
                },
                buttonHeight: 40,
                buttonWidth: size.width * 7,
                itemHeight: 40,
              ),
            ),
          ),
        ),
        // Container(
        //   padding: EdgeInsets.zero,
        //   height: 40,
        //   width: size.width * .5,
        //   decoration: BoxDecoration(
        //       borderRadius: BorderRadius.circular(40),
        //       border: Border.all(
        //         color: blueColor,
        //       )),
        //   child: Center(
        //     child: DropdownButton(
        //       underline: SizedBox(),
        //       value: selectedTime,
        //       hint: Text(
        //         'Time*        ',
        //         style: TextStyle(color: blueColor),
        //       ),
        //       style: TextStyle(color: blueColor),
        //       icon: Icon(Icons.timer_outlined, size: 16),
        //       iconDisabledColor: blueColor,
        //       iconEnabledColor: blueColor,
        //       items: times
        //           .map(
        //               (e) => DropdownMenuItem<String>(value: e, child: Text(e)))
        //           .toList(),
        //       onChanged: (String? value) {
        //         setState(() {
        //           selectedTime = value;
        //           widget.timeValue(value);
        //         });
        //       },
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
