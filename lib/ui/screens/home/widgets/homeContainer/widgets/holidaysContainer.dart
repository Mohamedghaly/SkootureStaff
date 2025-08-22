import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/homeScreenDataCubit.dart';
import 'package:eschool_saas_staff/data/models/holiday.dart';
import 'package:eschool_saas_staff/ui/screens/holidaysScreen.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/contentTitleWithViewmoreButton.dart';

import 'package:eschool_saas_staff/ui/widgets/holidayContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class HolidaysContainer extends StatelessWidget {
  const HolidaysContainer({super.key});

  @override
  Widget build(BuildContext context) {
    List<Holiday> holidays = context.read<HomeScreenDataCubit>().getHolidays();

    holidays = holidays.length > 5 ? holidays.sublist(0, 5) : holidays;

    return holidays.isEmpty
        ? const SizedBox()
        : Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              ContentTitleWithViewMoreButton(
                showViewMoreButton: true,
                contentTitleKey: holidaysKey,
                viewMoreOnTap: () {
                  Get.toNamed(Routes.holidaysScreen,
                      arguments: HolidaysScreen.buildArguments(
                          holidays: context
                              .read<HomeScreenDataCubit>()
                              .getHolidays()));
                },
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                height: 125,
                child: ListView.builder(
                  itemCount: holidays.length,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                      horizontal: appContentHorizontalPadding),
                  itemBuilder: (context, index) {
                    return HolidayContainer(
                        holiday: holidays[index],
                        margin: const EdgeInsetsDirectional.only(end: 25),
                        width: MediaQuery.of(context).size.width * (0.85));
                  },
                ),
              )
            ],
          );
  }
}
