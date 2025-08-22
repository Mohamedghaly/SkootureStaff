import 'package:eschool_saas_staff/cubits/payRoll/payRollYearsCubit.dart';
import 'package:eschool_saas_staff/cubits/payRoll/staffsPayrollCubit.dart';
import 'package:eschool_saas_staff/cubits/payRoll/submitStaffsPayRollCubit.dart';
import 'package:eschool_saas_staff/cubits/userDetails/staffAllowedPermissionsAndModulesCubit.dart';
import 'package:eschool_saas_staff/data/models/staffPayRoll.dart';
import 'package:eschool_saas_staff/ui/screens/managePayrolls/widgets/staffPayrollDetailsContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/appbarFilterBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
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
import 'package:get/get.dart';

class ManagePayrollsScreen extends StatefulWidget {
  const ManagePayrollsScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PayRollYearsCubit(),
        ),
        BlocProvider(
          create: (context) => StaffsPayrollCubit(),
        ),
        BlocProvider(
          create: (context) => SubmitStaffsPayRollCubit(),
        ),
      ],
      child: const ManagePayrollsScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<ManagePayrollsScreen> createState() => _ManagePayrollsScreenState();
}

class _ManagePayrollsScreenState extends State<ManagePayrollsScreen> {
  String? _selectedYear;
  late String _selectedMonthKey = months[(DateTime.now().month - 1)];

  final List<StaffPayRoll> _selectedStaffs = [];

  final List<GlobalKey<StaffPayrollDetailsContainerState>>
      _staffsPayRollDetailsContainerKeys = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<PayRollYearsCubit>().getPayRollYears();
      }
    });
  }

  void changeSelectedYear(String year) {
    _selectedYear = year;
    setState(() {});
    getStaffsPayRoll();
  }

  void changeSelectedMonth(String month) {
    _selectedMonthKey = month;
    setState(() {});
    getStaffsPayRoll();
  }

  int getSelectedMonthNumber() {
    return months.indexOf(_selectedMonthKey) + 1;
  }

  void getStaffsPayRoll() {
    if (_selectedStaffs.isNotEmpty) {
      _selectedStaffs.clear();
      setState(() {});
    }

    // Extract the first year from the session year string (e.g., "2025/26" -> 2025)
    int yearNumber = 0;
    if (_selectedYear != null && _selectedYear!.isNotEmpty) {
      final yearParts = _selectedYear!.split('/');
      if (yearParts.isNotEmpty) {
        yearNumber = int.tryParse(yearParts[0]) ?? 0;
      }
    }

    // Only fetch if we have a valid year
    if (yearNumber > 0) {
      context
          .read<StaffsPayrollCubit>()
          .getStaffsPayroll(year: yearNumber, month: getSelectedMonthNumber());
    }
  }

  Widget _buildSubmitButton() {
    return context
                .read<StaffAllowedPermissionsAndModulesCubit>()
                .isPermissionGiven(permission: createPayRollPermissionKey) ||
            context
                .read<StaffAllowedPermissionsAndModulesCubit>()
                .isPermissionGiven(permission: editPayrollEditPermissionKey)
        ? Align(
            alignment: Alignment.bottomCenter,
            child: BlocBuilder<PayRollYearsCubit, PayRollYearsState>(
              builder: (context, state) {
                if (state is PayRollYearsFetchSuccess) {
                  return Container(
                    padding: EdgeInsets.all(appContentHorizontalPadding),
                    decoration: BoxDecoration(boxShadow: const [
                      BoxShadow(
                          color: Colors.black12, blurRadius: 1, spreadRadius: 1)
                    ], color: Theme.of(context).colorScheme.surface),
                    width: MediaQuery.of(context).size.width,
                    height: 70,
                    child: BlocConsumer<SubmitStaffsPayRollCubit,
                        SubmitStaffsPayRollState>(
                      listener: (context, submitStaffsPayRollState) {
                        if (submitStaffsPayRollState
                            is SubmitStaffsPayRollSuccess) {
                          getStaffsPayRoll();
                          _selectedStaffs.clear();
                          setState(() {});
                        }
                      },
                      builder: (context, submitStaffsPayRollState) {
                        return CustomRoundedButton(
                          height: 40,
                          widthPercentage: 1.0,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(
                                  alpha: _selectedStaffs.isEmpty ? 0.75 : 1.0),
                          buttonTitle: submitKey,
                          showBorder: false,
                          child: submitStaffsPayRollState
                                  is SubmitStaffsPayRollInProgress
                              ? const CustomCircularProgressIndicator()
                              : null,
                          onTap: () {
                            if (_selectedStaffs.isEmpty) {
                              return;
                            }

                            if (submitStaffsPayRollState
                                is SubmitStaffsPayRollInProgress) {
                              return;
                            }

                            List<Map<String, dynamic>> staffPayRolls = [];

                            for (var staffPayRoll in _selectedStaffs) {
                              final index = context
                                  .read<StaffsPayrollCubit>()
                                  .staffsPayRoll()
                                  .indexWhere((element) =>
                                      element.id == staffPayRoll.id);

                              final netSalary = (index != -1)
                                  ? (_staffsPayRollDetailsContainerKeys[index]
                                          .currentState
                                          ?.getNetSalary() ??
                                      0.0)
                                  : 0.0;

                              staffPayRolls.add({
                                "staff_id": staffPayRoll.id,
                                "basic_salary": staffPayRoll.salary ?? 0.0,
                                "amount": netSalary
                              });
                            }

                            // Extract the first year from the session year string
                            int yearNumber = 0;
                            if (_selectedYear != null &&
                                _selectedYear!.isNotEmpty) {
                              final yearParts = _selectedYear!.split('/');
                              if (yearParts.isNotEmpty) {
                                yearNumber = int.tryParse(yearParts[0]) ?? 0;
                              }
                            }
                            context
                                .read<SubmitStaffsPayRollCubit>()
                                .submitStaffsPayRoll(
                                    month: getSelectedMonthNumber(),
                                    year: yearNumber,
                                    allowedLeaves: context
                                        .read<StaffsPayrollCubit>()
                                        .allowedLeaves(),
                                    staffPayRolls: staffPayRolls);
                          },
                        );
                      },
                    ),
                  );
                }

                return const SizedBox();
              },
            ))
        : const SizedBox();
  }

  Widget _buildStaffs() {
    return BlocConsumer<StaffsPayrollCubit, StaffsPayrollState>(
      listener: (context, state) {
        if (state is StaffsPayrollFetchSuccess) {
          for (var _ in state.staffsPayRoll) {
            _staffsPayRollDetailsContainerKeys
                .add(GlobalKey<StaffPayrollDetailsContainerState>());
            setState(() {});
          }
        }
      },
      builder: (context, state) {
        if (state is StaffsPayrollFetchSuccess) {
          if (state.staffsPayRoll.length == 0) {
            return Center(
              child: noDataContainer(
                titleKey: noStaffsPayRollsKey,
              ),
            );
          }
          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                  bottom: 100,
                  top:
                      Utils.appContentTopScrollPadding(context: context) + 100),
              child: Container(
                padding: EdgeInsets.all(appContentHorizontalPadding),
                color: Theme.of(context).colorScheme.surface,
                width: MediaQuery.of(context).size.width,
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
                      child: LayoutBuilder(builder: (context, boxConstraints) {
                        return Row(
                          children: [
                            SizedBox(
                              width: boxConstraints.maxWidth * (0.125),
                              child: const CustomTextContainer(textKey: "#"),
                            ),
                            SizedBox(
                              width: boxConstraints.maxWidth * (0.5),
                              child:
                                  const CustomTextContainer(textKey: nameKey),
                            ),
                            SizedBox(
                              width: boxConstraints.maxWidth * (0.375),
                              child:
                                  const CustomTextContainer(textKey: statusKey),
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
                                  color:
                                      Theme.of(context).colorScheme.tertiary)),
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5)),
                          color: Theme.of(context).colorScheme.surface),
                      child: Column(
                        children: List.generate(
                                state.staffsPayRoll.length, (index) => index)
                            .map((index) {
                          final staffPayRoll = state.staffsPayRoll[index];
                          final isSelected = _selectedStaffs.indexWhere(
                                  (element) => element.id == staffPayRoll.id) !=
                              -1;
                          return StaffPayrollDetailsContainer(
                            key: _staffsPayRollDetailsContainerKeys[index],
                            allowedMonthlyLeaves: state.allowedLeaves,
                            isSelected: isSelected,
                            staffPayRoll: staffPayRoll,
                            onTapCheckBox: () {
                              if (isSelected) {
                                _selectedStaffs.removeWhere(
                                    (element) => element.id == staffPayRoll.id);
                              } else {
                                _selectedStaffs.add(staffPayRoll);
                              }
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }

        if (state is StaffsPayrollFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: state.errorMessage,
              onTapRetry: () {
                getStaffsPayRoll();
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
        BlocBuilder<PayRollYearsCubit, PayRollYearsState>(
          builder: (context, state) {
            if (state is PayRollYearsFetchSuccess) {
              return _buildStaffs();
            }

            if (state is PayRollYearsFetchFailure) {
              return Center(
                child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    context.read<PayRollYearsCubit>().getPayRollYears();
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
        _buildSubmitButton(),
        Align(
          alignment: Alignment.topCenter,
          child: BlocConsumer<PayRollYearsCubit, PayRollYearsState>(
            listener: (context, state) {
              if (state is PayRollYearsFetchSuccess && state.years.isNotEmpty) {
                changeSelectedYear(state.years.last);
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  const CustomAppbar(titleKey: managePayRollsKey),
                  AppbarFilterBackgroundContainer(
                    child: LayoutBuilder(
                      builder: (context, boxConstraints) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FilterButton(
                                onTap: () {
                                  if (state is PayRollYearsFetchSuccess &&
                                      state.years.isNotEmpty) {
                                    Utils.showBottomSheet(
                                        child:
                                            FilterSelectionBottomsheet<String>(
                                                onSelection: (value) {
                                                  changeSelectedYear(value!);
                                                  Get.back();
                                                },
                                                selectedValue:
                                                    _selectedYear ?? "",
                                                titleKey: sessionYearKey,
                                                values: state.years),
                                        context: context);
                                  }
                                },
                                titleKey:
                                    (_selectedYear?.toString()) ?? yearKey,
                                width: boxConstraints.maxWidth * (0.48)),
                            FilterButton(
                                onTap: () {
                                  if (state is PayRollYearsFetchSuccess) {
                                    Utils.showBottomSheet(
                                        child:
                                            FilterSelectionBottomsheet<String>(
                                          selectedValue: _selectedMonthKey,
                                          titleKey: monthKey,
                                          values: months,
                                          onSelection: (value) {
                                            changeSelectedMonth(value!);
                                            Get.back();
                                          },
                                        ),
                                        context: context);
                                  }
                                },
                                titleKey: _selectedMonthKey,
                                width: boxConstraints.maxWidth * (0.49)),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        )
      ],
    ));
  }
}
