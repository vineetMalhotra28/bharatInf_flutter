import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({
    Key? key,
    required this.appointmentDates,
    required this.selectedDate,
    required this.toDate,
    required this.fromDate,
  }) : super(key: key);

  final DateTime toDate;
  final DateTime fromDate;
  final List<DateTime> appointmentDates;
  final void Function(DateTime) selectedDate;

  @override
  Widget build(BuildContext context) {
    final DateTime _currentDate = DateTime.now();
    return TableCalendar(
      focusedDay: _currentDate,
      firstDay: fromDate,
      lastDay: toDate,
      currentDay: _currentDate,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          for (DateTime d in appointmentDates) {
            if (day.day == d.day &&
                day.month == d.month &&
                day.year == d.year) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
          }
          return null;
        },
      ),
      onDaySelected: (selectedDay, focusedDay) {
        print("$selectedDay  $focusedDay");
        selectedDate(selectedDay);
      },
    );
  }
}

class Event {
  final String t;

  Event(this.t);
}
