import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/enrollFormCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/feesCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/pickupPointsCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/shiftsCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/transportEnrollmentSubmissionCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/transportPlanDetailsCubit.dart';
import 'package:eschool_saas_staff/data/models/currentPlan.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/selectTransport/widgets/inlineExpandableSelector.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/widgets/routeReviewCard.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ChangeRouteScreen extends StatefulWidget {
  final TransportPlanDetails currentPlan;

  const ChangeRouteScreen({
    super.key,
    required this.currentPlan,
  });

  static Widget getRouteInstance() {
    final resolvedPlan = _resolvePlanDetails(Get.arguments);

    if (resolvedPlan == null) {
      // Navigate back if no current plan provided
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
      });
      return const Scaffold(
        body: Center(child: Text('No plan data available')),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PickupPointsCubit()..fetch()),
        BlocProvider(create: (_) => ShiftsCubit()),
        BlocProvider(create: (_) => FeesCubit()),
        BlocProvider(create: (_) => TransportEnrollFormCubit()),
        BlocProvider(create: (_) => TransportEnrollmentSubmissionCubit()),
      ],
      child: ChangeRouteScreen(currentPlan: resolvedPlan),
    );
  }

  static TransportPlanDetails? _resolvePlanDetails(dynamic arguments) {
    if (arguments == null) return null;

    if (arguments is TransportPlanDetails) {
      return arguments;
    }

    if (arguments is CurrentPlan) {
      return _mapCurrentPlanToDetails(arguments);
    }

    if (arguments is Map) {
      final dynamic nested = arguments['planDetails'] ??
          arguments['currentPlan'] ??
          arguments['plan'] ??
          arguments['data'];

      if (nested == null) {
        return null;
      }

      return _resolvePlanDetails(nested);
    }

    return null;
  }

  static TransportPlanDetails _mapCurrentPlanToDetails(CurrentPlan plan) {
    return TransportPlanDetails(
      routeName: plan.route?.name,
      pickupStop: plan.pickupStop != null
          ? PlanPickupStopAdapter(
              id: plan.pickupStop!.id,
              name: plan.pickupStop!.name,
            )
          : null,
      duration: plan.duration,
      validFrom: plan.validFrom,
      validTo: plan.validTo,
      shiftId: plan.shiftId,
      paymentId: plan.paymentId,
      totalFee: plan.totalFee,
      paymentMode: plan.paymentMode,
      shiftName: plan.shift?.name,
      shiftTimeWindow: plan.shift?.timeWindow,
      estimatedPickupTime: plan.estimatedPickupTime,
      vehicleId: plan.vehicleId,
      vehicleName: plan.vehicle?.vehicleName,
      vehicleRegistration: plan.vehicle?.vehicleRegistration,
    );
  }

  @override
  State<ChangeRouteScreen> createState() => _ChangeRouteScreenState();
}

class _ChangeRouteScreenState extends State<ChangeRouteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          CustomAppbar(
            titleKey: changeStopKey,
            showBackButton: true,
          ),
          Expanded(
            child: BlocListener<TransportEnrollmentSubmissionCubit,
                TransportEnrollmentSubmissionState>(
              listener: (context, state) {
                if (state is TransportEnrollmentSubmissionSuccess) {
                  // Navigate to success screen with animated check icon
                  final userId = context.read<AuthCubit>().getUserDetails().id;
                  Get.offNamed(
                    Routes.transportEnrollSubmittedScreen,
                    arguments: {
                      'message':
                          'Your route change request has been submitted successfully. The fee will be deducted from your salary.',
                      'userId': userId,
                    },
                  );
                } else if (state is TransportEnrollmentSubmissionFailure) {
                  // Show error message
                  Utils.showSnackBar(
                    context: context,
                    message: state.errorMessage,
                    backgroundColor: Theme.of(context).colorScheme.error,
                  );
                }
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: appContentHorizontalPadding,
                  vertical: 16,
                ),
                child: _buildContent(),
              ),
            ),
          ),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isWide = constraints.maxWidth >= 600;
      final double gap = isWide ? 20.0 : 16.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentRouteCard(),
          SizedBox(height: gap),
          _buildPickupPointsDropdown(),
          SizedBox(height: gap),
          _buildShiftsDropdown(),
          SizedBox(height: gap),
          _buildFeesDropdown(),
          SizedBox(height: gap * 2),
        ],
      );
    });
  }

  Widget _buildCurrentRouteCard() {
    final routeInfo = widget.currentPlan.routeName ?? '-';
    final vehicleReg = widget.currentPlan.vehicleRegistration ?? '-';
    final pickupInfo = widget.currentPlan.pickupStop?.name ?? '-';
    final pickupTime = widget.currentPlan.estimatedPickupTime;

    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F6ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF57CC99)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextContainer(
            textKey:
                '${Utils.getTranslatedLabel(routeNameKey)} : $routeInfo | $vehicleReg',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF212121),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          CustomTextContainer(
            textKey:
                '${Utils.getTranslatedLabel(yourPickupKey)} : $pickupInfo${pickupTime != null ? ' | $pickupTime' : ''}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF212121),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPickupPointsDropdown() {
    return BlocBuilder<PickupPointsCubit, PickupPointsState>(
      builder: (context, pickupState) {
        final formState = context.watch<TransportEnrollFormCubit>().state;
        final bool isLoading = pickupState is PickupPointsFetchInProgress;
        final List<String> values = pickupState is PickupPointsFetchSuccess
            ? pickupState.pickupPoints
                .map((e) => e.name ?? '')
                .where((e) => e.isNotEmpty)
                .toList()
            : <String>[];
        String? selected = formState.selectedPickup?.name;
        bool disabled = isLoading || values.isEmpty;

        if (values.isEmpty) {
          selected = Utils.getTranslatedLabel(noDataFoundKey);
        }

        return InlineExpandableSelector(
          label: selectPickDropPointKey,
          hint: values.isEmpty
              ? Utils.getTranslatedLabel(noDataFoundKey)
              : selectPickDropPointKey,
          selected: selected,
          values: values,
          isOpen: formState.isPickupOpen,
          isDisabled: disabled,
          onHeaderTap: () {
            context.read<TransportEnrollFormCubit>().togglePickupOpen();
          },
          onSelected: (v) {
            if (pickupState is! PickupPointsFetchSuccess) return;
            final picked = pickupState.pickupPoints.firstWhere(
                (element) => (element.name ?? '') == v,
                orElse: () => pickupState.pickupPoints.first);
            context.read<TransportEnrollFormCubit>().selectPickup(picked);

            // Fetch dependent data
            if (picked.id != null) {
              context.read<ShiftsCubit>().fetch(pickupPointId: picked.id!);
              context.read<FeesCubit>().fetch(pickupPointId: picked.id!);
            }
          },
        );
      },
    );
  }

  Widget _buildShiftsDropdown() {
    return BlocBuilder<ShiftsCubit, ShiftsState>(
      builder: (context, shiftsState) {
        final formState = context.watch<TransportEnrollFormCubit>().state;
        final bool isLoading = shiftsState is ShiftsFetchInProgress;
        final List<String> values = shiftsState is ShiftsFetchSuccess
            ? shiftsState.shifts
                .map((e) => e.displayName)
                .where((e) => e.isNotEmpty)
                .toList()
            : <String>[];
        String? selected = formState.selectedShift?.displayName;
        final bool disabled =
            formState.selectedPickup == null || isLoading || values.isEmpty;

        if (values.isEmpty && formState.selectedPickup != null) {
          selected = Utils.getTranslatedLabel(noDataFoundKey);
        }

        return InlineExpandableSelector(
          label: selectShiftKey,
          hint: values.isEmpty
              ? Utils.getTranslatedLabel(noDataFoundKey)
              : selectShiftKey,
          selected: selected,
          values: values,
          isOpen: formState.isShiftOpen,
          isDisabled: disabled,
          onHeaderTap: () {
            if (!disabled) {
              context.read<TransportEnrollFormCubit>().toggleShiftOpen();
            }
          },
          onSelected: (v) {
            if (shiftsState is! ShiftsFetchSuccess) return;
            final picked = shiftsState.shifts.firstWhere(
                (element) => element.displayName == v,
                orElse: () => shiftsState.shifts.first);
            context.read<TransportEnrollFormCubit>().selectShift(picked);
          },
        );
      },
    );
  }

  Widget _buildFeesDropdown() {
    return BlocBuilder<FeesCubit, FeesState>(
      builder: (context, feesState) {
        final formState = context.watch<TransportEnrollFormCubit>().state;
        final bool isLoading = feesState is FeesFetchInProgress;
        final List<String> values = feesState is FeesFetchSuccess
            ? feesState.feesResponse.fees
                .map((e) => e.toString())
                .where((e) => e.isNotEmpty)
                .toList()
            : <String>[];
        String? selected = formState.selectedFee?.toString();
        final bool disabled =
            formState.selectedPickup == null || isLoading || values.isEmpty;

        if (values.isEmpty && formState.selectedPickup != null) {
          selected = Utils.getTranslatedLabel(noDataFoundKey);
        }

        return InlineExpandableSelector(
          label: selectDurationKey,
          hint: values.isEmpty
              ? Utils.getTranslatedLabel(noDataFoundKey)
              : selectDurationKey,
          selected: selected,
          values: values,
          isOpen: formState.isDurationOpen,
          isDisabled: disabled,
          onHeaderTap: () {
            if (!disabled) {
              context.read<TransportEnrollFormCubit>().toggleDurationOpen();
            }
          },
          onSelected: (v) {
            if (feesState is! FeesFetchSuccess) return;
            final picked = feesState.feesResponse.fees.firstWhere(
                (element) => element.toString() == v,
                orElse: () => feesState.feesResponse.fees.first);
            context.read<TransportEnrollFormCubit>().selectFee(picked);
          },
        );
      },
    );
  }

  Widget _buildContinueButton() {
    return BlocBuilder<TransportEnrollmentSubmissionCubit,
        TransportEnrollmentSubmissionState>(
      builder: (context, submissionState) {
        final isSubmitting =
            submissionState is TransportEnrollmentSubmissionInProgress;

        return SafeArea(
          top: false,
          child: Container(
            width: double.maxFinite,
            padding: EdgeInsets.all(appContentHorizontalPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: CustomRoundedButton(
              onTap: isSubmitting ? null : () => _onContinueTap(context),
              backgroundColor: Theme.of(context).colorScheme.primary,
              buttonTitle: continueKey,
              showBorder: false,
              widthPercentage: 1.0,
              height: 50,
              radius: 8,
              child: isSubmitting
                  ? const CustomCircularProgressIndicator(
                      widthAndHeight: 20,
                      strokeWidth: 2,
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  void _onContinueTap(BuildContext context) {
    final formState = context.read<TransportEnrollFormCubit>().state;

    // Validate form data
    if (formState.selectedPickup == null) {
      Utils.showSnackBar(
        context: context,
        message: Utils.getTranslatedLabel(pleaseSelectPickDropPointKey),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (formState.selectedShift == null) {
      Utils.showSnackBar(
        context: context,
        message: Utils.getTranslatedLabel(pleaseSelectShiftKey),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    final feesState = context.read<FeesCubit>().state;
    final bool mustSelectFee =
        feesState is FeesFetchSuccess && feesState.feesResponse.fees.isNotEmpty;

    if (mustSelectFee && formState.selectedFee == null) {
      Utils.showSnackBar(
        context: context,
        message: Utils.getTranslatedLabel(pleaseSelectDurationKey),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    // Show review bottom sheet
    _showReviewBottomSheet(context, formState);
  }

  void _showReviewBottomSheet(
      BuildContext context, TransportEnrollFormState formState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: context.read<TransportEnrollmentSubmissionCubit>(),
          child: BlocBuilder<TransportEnrollmentSubmissionCubit,
              TransportEnrollmentSubmissionState>(
            builder: (bottomSheetContext, submissionState) {
              final isSubmitting =
                  submissionState is TransportEnrollmentSubmissionInProgress;

              return SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: appContentHorizontalPadding,
                    right: appContentHorizontalPadding,
                    top: 15,
                    bottom: MediaQuery.of(ctx).padding.bottom + 15,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextContainer(
                              textKey: routeDetailsKey,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: const Icon(Icons.close),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      RouteReviewCard(
                        currentRouteName: widget.currentPlan.routeName ?? '-',
                        currentPickup:
                            widget.currentPlan.pickupStop?.name ?? '-',
                        requestedRouteName:
                            formState.selectedPickup?.name ?? '-',
                        requestedPickup: formState.selectedPickup?.name ?? '-',
                        currentFee: widget.currentPlan.totalFee ?? '-',
                        requestedFee:
                            formState.selectedFee?.formattedFeeAmount ?? '-',
                        noteText:
                            '${Utils.getTranslatedLabel(noteKey)}: The fee of ${formState.selectedFee?.formattedFeeAmount ?? '0'} will be deducted from your salary. The remaining balance from your current package cannot be applied to the new package. To change the stop, the full price of the new stop will be deducted.',
                      ),
                      const SizedBox(height: 15),
                      CustomRoundedButton(
                        onTap: isSubmitting
                            ? null
                            : () => _handleConfirmSubmission(
                                bottomSheetContext, formState),
                        backgroundColor: Theme.of(ctx).colorScheme.primary,
                        buttonTitle: confirmKey,
                        showBorder: false,
                        widthPercentage: 1.0,
                        height: 50,
                        radius: 8,
                        child: isSubmitting
                            ? const CustomCircularProgressIndicator(
                                widthAndHeight: 20,
                                strokeWidth: 2,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _handleConfirmSubmission(
      BuildContext context, TransportEnrollFormState formState) {
    try {
      // Get user details
      final userId = context.read<AuthCubit>().getUserDetails().id;

      if (userId == null) {
        Utils.showSnackBar(
          context: context,
          message: 'User not authenticated. Please login again.',
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        return;
      }

      // Validate required data
      if (formState.selectedPickup?.id == null) {
        Utils.showSnackBar(
          context: context,
          message: Utils.getTranslatedLabel(invalidPickupPointKey),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        return;
      }

      if (formState.selectedFee?.id == null) {
        Utils.showSnackBar(
          context: context,
          message: Utils.getTranslatedLabel(invalidFeePlanKey),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        return;
      }

      if (formState.selectedShift?.id == null) {
        Utils.showSnackBar(
          context: context,
          message: Utils.getTranslatedLabel(invalidShiftKey),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        return;
      }

      // Close the bottom sheet
      Navigator.of(context).pop();

      // Submit the route change request
      // No payment_method needed - fee will be deducted from staff salary
      // isChangeRoute: true indicates this is a route change, not initial enrollment
      context.read<TransportEnrollmentSubmissionCubit>().submitEnrollment(
            userId: userId,
            pickupPointId: formState.selectedPickup!.id!,
            transportationFeeId: formState.selectedFee!.id!,
            shiftId: formState.selectedShift!.id!,
            isChangeRoute: true,
          );
    } catch (e) {
      Utils.showSnackBar(
        context: context,
        message: 'An error occurred: ${e.toString()}',
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    }
  }
}
