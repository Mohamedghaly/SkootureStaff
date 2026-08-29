import 'package:flutter/material.dart';

class WeekdayHeadersWidget extends StatelessWidget {
  const WeekdayHeadersWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: weekdays
            .map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
