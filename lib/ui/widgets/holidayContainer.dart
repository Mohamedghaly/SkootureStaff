import 'package:eschool_saas_staff/data/models/holiday.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/readMoreTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/textWithFadedBackgroundContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';

import 'package:flutter/material.dart';

class HolidayContainer extends StatelessWidget {
  final Holiday holiday;
  final double width;
  final EdgeInsetsDirectional? margin;
  const HolidayContainer(
      {super.key, required this.width, this.margin, required this.holiday});

  @override
  Widget build(BuildContext context) {
    final holidayDateTime = Utils.parseDateSafely(holiday.date ?? "") ?? DateTime.now();
    return Container(
      margin: margin,
      width: width,
      height: 125,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: double.maxFinite,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadiusDirectional.only(
                    topStart: Radius.circular(8),
                    bottomStart: Radius.circular(8.0))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextContainer(
                  textKey: holidayDateTime.day.toString(),
                  style: TextStyle(
                      fontSize: 30.0,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontWeight: FontWeight.w600),
                ),
                CustomTextContainer(
                  textKey: months[holidayDateTime.month - 1],
                  style: TextStyle(
                    height: 1,
                    fontSize: 18.0,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 15.0,
          ),
          Flexible(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextContainer(
                textKey: holiday.title ?? "",
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.w600),
                maxLines: 1,
              ),
              const SizedBox(
                height: 5.0,
              ),
              LayoutBuilder(builder: (context, boxConstraints) {
                return Column(
                  children: [
                    CustomTextContainer(
                      textKey: holiday.description ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(height: 1.2),
                    ),
                    Utils.calculateLinesForGivenText(
                                text: holiday.description ?? "",
                                textStyle: const TextStyle(height: 1.2),
                                availableMaxWidth: boxConstraints.maxWidth,
                                context: context) >
                            2
                        ? ReadMoreTextButton(onTap: () {
                            Utils.showBottomSheet(
                                child: HolidayDetailsBottomsheet(
                                  holiday: holiday,
                                ),
                                context: context);
                          })
                        : const SizedBox()
                  ],
                );
              }),
            ],
          ))
        ],
      ),
    );
  }
}

class HolidayDetailsBottomsheet extends StatelessWidget {
  final Holiday holiday;
  const HolidayDetailsBottomsheet({super.key, required this.holiday});

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
        titleLabelKey: holidayKey,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 15.0),
                  child: TextWithFadedBackgroundContainer(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      textColor: Theme.of(context).colorScheme.surface,
                      titleKey: () {
                        final parsedDate = Utils.parseDateSafely(holiday.date!);
                        if (parsedDate != null) {
                          return Utils.formatDate(parsedDate);
                        }
                        return holiday.date ?? "";
                      }()),
                ),
              ),
              CustomTextContainer(
                textKey: holiday.title ?? "",
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              CustomTextContainer(textKey: holiday.description ?? "")
            ],
          ),
        ));
  }
}
