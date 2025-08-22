import 'package:eschool_saas_staff/data/models/holiday.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/holidayContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HolidaysScreen extends StatefulWidget {
  final List<Holiday> holidays;
  const HolidaysScreen({super.key, required this.holidays});

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return HolidaysScreen(
      holidays: arguments['holidays'] as List<Holiday>,
    );
  }

  static Map<String, dynamic> buildArguments(
      {required List<Holiday> holidays}) {
    return {"holidays": List<Holiday>.from(holidays)};
  }

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends State<HolidaysScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                  top: Utils.appContentTopScrollPadding(context: context) + 20,
                  right: appContentHorizontalPadding,
                  left: appContentHorizontalPadding),
              child: Column(
                children: widget.holidays
                    .map(
                      (holiday) => HolidayContainer(
                        holiday: holiday,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsetsDirectional.only(bottom: 25),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.topCenter,
            child: CustomAppbar(titleKey: holidaysKey),
          ),
        ],
      ),
    );
  }
}
