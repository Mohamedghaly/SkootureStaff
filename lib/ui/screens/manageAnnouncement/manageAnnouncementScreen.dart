import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/announcement/announcementsCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/ui/screens/manageAnnouncement/widgets/announcementDetailsContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/systemModulesAndPermissions.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class ManageAnnouncementScreen extends StatefulWidget {
  const ManageAnnouncementScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AnnouncementsCubit(),
        ),
        BlocProvider(
          create: (context) => ClassesCubit(),
        ),
      ],
      child: const ManageAnnouncementScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<ManageAnnouncementScreen> createState() =>
      _ManageAnnouncementScreenState();
}

class _ManageAnnouncementScreenState extends State<ManageAnnouncementScreen> {
  ClassSection? _selectedClassSection;

  late final ScrollController _scrollController = ScrollController()
    ..addListener(scrollListener);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<ClassesCubit>().getClasses();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
  }

  void scrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<AnnouncementsCubit>().hasMore()) {
        getMoreAnnouncements();
      }
    }
  }

  void getAnnouncements() {
    context
        .read<AnnouncementsCubit>()
        .getAnnouncements(classSectionId: [_selectedClassSection?.id ?? 0]);
  }

  void getMoreAnnouncements() {
    context
        .read<AnnouncementsCubit>()
        .fetchMore(classSectionId: [_selectedClassSection?.id ?? 0]);
  }

  void changeSelectedClassSection(ClassSection value) {
    _selectedClassSection = value;
    setState(() {});
    getAnnouncements();
  }

  Widget _buildAddAnnouncementButton() {
    return context
            .read<StaffAllowedPermissionsAndModulesCubit>()
            .isPermissionGiven(permission: createAnnouncementPermissionKey)
        ? Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(appContentHorizontalPadding),
              decoration: BoxDecoration(boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 1, spreadRadius: 1)
              ], color: Theme.of(context).colorScheme.surface),
              width: MediaQuery.of(context).size.width,
              height: 70,
              child: CustomRoundedButton(
                height: 40,
                widthPercentage: 1.0,
                backgroundColor: Theme.of(context).colorScheme.primary,
                buttonTitle: addAnnouncementKey,
                showBorder: false,
                onTap: () {
                  Get.toNamed(Routes.addAnnouncementScreen);
                },
              ),
            ))
        : const SizedBox();
  }

  Widget _buildAnnouncements() {
    return BlocBuilder<AnnouncementsCubit, AnnouncementsState>(
      builder: (context, state) {
        if (state is AnnouncementsFetchSuccess) {
          if (state.announcements.length == 0) {
            return Center(
              child: noDataContainer(
                titleKey: noAnnouncementsKey,
              ),
            );
          }
          return Align(
            alignment: Alignment.topCenter,
            child: RefreshIndicator(
              onRefresh: () async {
                getAnnouncements();
              },
              displacement:
                  Utils.appContentTopScrollPadding(context: context) + 100,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(
                    bottom: 80,
                    top: Utils.appContentTopScrollPadding(context: context) +
                        100),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Theme.of(context).colorScheme.surface,
                  padding: EdgeInsets.all(appContentHorizontalPadding),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: appContentHorizontalPadding),
                        height: 40,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).colorScheme.tertiary),
                        child:
                            LayoutBuilder(builder: (context, boxConstraints) {
                          return Row(
                            children: [
                              SizedBox(
                                width: boxConstraints.maxWidth * (0.15),
                                child: const CustomTextContainer(textKey: "#"),
                              ),
                              SizedBox(
                                width: boxConstraints.maxWidth * (0.85),
                                child: const CustomTextContainer(
                                    textKey: announcementKey),
                              ),
                            ],
                          );
                        }),
                      ),
                      Container(
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                                left: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiary)),
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(5),
                                bottomRight: Radius.circular(5)),
                            color: Theme.of(context).colorScheme.surface),
                        child: Column(
                          children: List.generate(state.announcements.length,
                              (index) {
                            if (context.read<AnnouncementsCubit>().hasMore()) {
                              if (index == (state.announcements.length - 1)) {
                                if (state.fetchMoreError) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: CustomTextButton(
                                          buttonTextKey: retryKey,
                                          onTapButton: () {
                                            getMoreAnnouncements();
                                          }),
                                    ),
                                  );
                                }

                                return Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Center(
                                    child: CustomCircularProgressIndicator(
                                      indicatorColor:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                );
                              }
                            }
                            return AnnouncementDetailsContainer(
                                announcement: state.announcements[index],
                                index: index);
                          }).toList(),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (state is AnnouncementsFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: state.errorMessage,
              onTapRetry: () {
                getAnnouncements();
              },
            ),
          );
        }

        return Center(
          child: CustomCircularProgressIndicator(
            indicatorColor: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        SafeArea(
          child: BlocBuilder<ClassesCubit, ClassesState>(
            builder: (context, state) {
              if (state is ClassesFetchSuccess) {
                return _buildAnnouncements();
              }

              if (state is ClassesFetchFailure) {
                return Center(
                  child: ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      context.read<ClassesCubit>().getClasses();
                    },
                  ),
                );
              }

              return Center(
                child: CustomCircularProgressIndicator(
                  indicatorColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
        ),
        BlocBuilder<ClassesCubit, ClassesState>(
          builder: (context, state) {
            if (state is ClassesFetchSuccess) {
              return _buildAddAnnouncementButton();
            }
            return const SizedBox();
          },
        ),
        Align(
          alignment: Alignment.topCenter,
          child: BlocConsumer<ClassesCubit, ClassesState>(
            listener: (context, state) {
              if (state is ClassesFetchSuccess) {
                if (context.read<ClassesCubit>().getAllClasses().isNotEmpty) {
                  changeSelectedClassSection(
                      context.read<ClassesCubit>().getAllClasses().first);
                }
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  const CustomAppbar(titleKey: manageAnnouncementKey),
                  AppbarFilterBackgroundContainer(
                      child: LayoutBuilder(builder: (context, boxConstraints) {
                    return FilterButton(
                        onTap: () {
                          if (state is ClassesFetchSuccess &&
                              context
                                  .read<ClassesCubit>()
                                  .getAllClasses()
                                  .isNotEmpty) {
                            Utils.showBottomSheet(
                                child: FilterSelectionBottomsheet<ClassSection>(
                                    onSelection: (value) {
                                      changeSelectedClassSection(value!);
                                      Get.back();
                                    },
                                    selectedValue: _selectedClassSection!,
                                    titleKey: classKey,
                                    values: context
                                        .read<ClassesCubit>()
                                        .getAllClasses()),
                                context: context);
                          }
                        },
                        titleKey: _selectedClassSection?.name ?? classKey,
                        width: boxConstraints.maxWidth);
                  }))
                ],
              );
            },
          ),
        )
      ],
    ));
  }
}
