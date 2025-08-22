import 'dart:math';

import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/announcement/announcementsCubit.dart';
import 'package:eschool_saas_staff/cubits/announcement/deleteAnnouncementCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/data/models/announcement.dart';
import 'package:eschool_saas_staff/ui/screens/editAnnouncementScreen.dart';
import 'package:eschool_saas_staff/ui/screens/manageAnnouncement/widgets/announcementDescriptionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/screens/manageAnnouncement/widgets/announcementFilesBottomsheet.dart';
import 'package:eschool_saas_staff/ui/screens/manageAnnouncement/widgets/deleteAnnouncementDialog.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/readMoreTextButton.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class AnnouncementDetailsContainer extends StatefulWidget {
  final int index;
  final Announcement announcement;
  const AnnouncementDetailsContainer(
      {super.key, required this.index, required this.announcement});

  @override
  State<AnnouncementDetailsContainer> createState() =>
      _AnnouncementDetailsContainerState();
}

class _AnnouncementDetailsContainerState
    extends State<AnnouncementDetailsContainer> with TickerProviderStateMixin {
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: tileCollapsedDuration);

  late final Animation<double> _heightAnimation =
      Tween<double>(begin: 70, end: 250).animate(CurvedAnimation(
          parent: _animationController, curve: const Interval(0.0, 0.5)));

  late final Animation<double> _opacityAnimation =
      Tween<double>(begin: 0, end: 1.0).animate(CurvedAnimation(
          parent: _animationController, curve: const Interval(0.5, 1.0)));

  late final Animation<double> _iconAngleAnimation =
      Tween<double>(begin: 0, end: 180).animate(CurvedAnimation(
          parent: _animationController, curve: Curves.easeInOut));

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              if (_animationController.isAnimating) {
                return;
              }

              if (_animationController.isCompleted) {
                _animationController.reverse();
              } else {
                _animationController.forward();
              }
            },
            child: Container(
              height: _heightAnimation.value,
              padding: EdgeInsets.symmetric(
                  vertical: appContentHorizontalPadding,
                  horizontal: appContentHorizontalPadding),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary))),
              child: LayoutBuilder(builder: (context, boxConstraints) {
                return Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: boxConstraints.maxWidth * (0.15),
                          child: CustomTextContainer(
                              textKey: (widget.index + 1)
                                  .toString()
                                  .padLeft(2, '0')),
                        ),
                        SizedBox(
                          width: boxConstraints.maxWidth * (0.85),
                          child: Row(
                            children: [
                              Expanded(
                                  child: CustomTextContainer(
                                textKey: widget.announcement.title ?? "-",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600),
                              )),
                              Transform.rotate(
                                angle: (pi * _iconAngleAnimation.value) / 180,
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    _animationController.value > 0.5
                        ? Opacity(
                            opacity: _opacityAnimation.value,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Divider(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                  ),
                                  CustomTextContainer(
                                    textKey: descriptionKey,
                                    style: TextStyle(
                                        fontSize: 13.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withValues(alpha: 0.76)),
                                  ),
                                  CustomTextContainer(
                                    textKey:
                                        widget.announcement.description ?? "-",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Utils.calculateLinesForGivenText(
                                              availableMaxWidth:
                                                  boxConstraints.maxWidth,
                                              context: context,
                                              text: widget.announcement
                                                      .description ??
                                                  "-",
                                              textStyle: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w600)) >
                                          2
                                      ? ReadMoreTextButton(
                                          textStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                          onTap: () {
                                            Utils.showBottomSheet(
                                                child:
                                                    AnnouncementDescriptionBottomsheet(
                                                  text: widget.announcement
                                                          .description ??
                                                      "",
                                                ),
                                                context: context);
                                          })
                                      : const SizedBox(),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  (widget.announcement.files ?? []).isNotEmpty
                                      ? CustomTextButton(
                                          buttonTextKey: viewFilesKey,
                                          textStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600),
                                          onTapButton: () {
                                            Utils.showBottomSheet(
                                                child:
                                                    AnnouncementFilesBottomsheet(
                                                  files: widget
                                                          .announcement.files ??
                                                      [],
                                                ),
                                                context: context);
                                          })
                                      : const SizedBox(),
                                  Divider(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                  const SizedBox(
                                    height: 2.5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      context
                                              .read<
                                                  StaffAllowedPermissionsAndModulesCubit>()
                                              .isPermissionGiven(
                                                  permission:
                                                      editAnnouncementPermissionKey)
                                          ? CustomRoundedButton(
                                              height: 35,
                                              widthPercentage: 0.3,
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              buttonTitle: editKey,
                                              fontWeight: FontWeight.w500,
                                              showBorder: false,
                                              onTap: () {
                                                Get.toNamed(
                                                    Routes
                                                        .editAnnouncementScreen,
                                                    arguments: EditAnnouncementScreen
                                                        .buildArguments(
                                                            announcement: widget
                                                                .announcement));
                                              },
                                            )
                                          : const SizedBox(),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      context
                                              .read<
                                                  StaffAllowedPermissionsAndModulesCubit>()
                                              .isPermissionGiven(
                                                  permission:
                                                      deleteAnnouncementPermissionKey)
                                          ? CustomRoundedButton(
                                              height: 35,
                                              widthPercentage: 0.3,
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                              buttonTitle: deleteKey,
                                              fontWeight: FontWeight.w500,
                                              showBorder: false,
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        BlocProvider(
                                                          create: (_) =>
                                                              DeleteAnnouncementCubit(),
                                                          child:
                                                              DeleteAnnouncementDialog(
                                                            announcementId: widget
                                                                    .announcement
                                                                    .id ??
                                                                0,
                                                          ),
                                                        )).then((value) {
                                                  final announcementId =
                                                      value as int?;
                                                  if (announcementId != null) {
                                                    if (context.mounted) {
                                                      context
                                                          .read<
                                                              AnnouncementsCubit>()
                                                          .deleteAnnouncement(
                                                              announcementId:
                                                                  announcementId);
                                                    }
                                                  }
                                                });
                                              },
                                            )
                                          : const SizedBox(),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                );
              }),
            ),
          );
        });
  }
}
