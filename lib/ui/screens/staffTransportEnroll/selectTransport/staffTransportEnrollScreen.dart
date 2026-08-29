import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/enrollFormCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/pickupPointsCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/shiftsCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/feesCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/transportEnrollmentSubmissionCubit.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/selectTransport/requestSubmittedScreen.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/selectTransport/widgets/inlineExpandableSelector.dart';
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

class StaffTransportEnrollScreen extends StatelessWidget {
  const StaffTransportEnrollScreen({super.key});

  static Widget getRouteInstance() {
    return const StaffTransportEnrollScreen();
  }

  Widget _buildFormContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          BlocBuilder<PickupPointsCubit, PickupPointsState>(
            builder: (context, pickupState) {
              final formState = context.watch<TransportEnrollFormCubit>().state;
              final bool isLoading = pickupState is PickupPointsFetchInProgress;
              final List<String> values =
                  pickupState is PickupPointsFetchSuccess
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
                    context
                        .read<ShiftsCubit>()
                        .fetch(pickupPointId: picked.id!);
                    context.read<FeesCubit>().fetch(pickupPointId: picked.id!);
                  }
                },
              );
            },
          ),
          const SizedBox(height: 20),
          BlocBuilder<ShiftsCubit, ShiftsState>(
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
              final bool disabled = formState.selectedPickup == null ||
                  isLoading ||
                  values.isEmpty;
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
          ),
          const SizedBox(height: 20),
          BlocBuilder<FeesCubit, FeesState>(
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
              final bool disabled = formState.selectedPickup == null ||
                  isLoading ||
                  values.isEmpty;
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
                    context
                        .read<TransportEnrollFormCubit>()
                        .toggleDurationOpen();
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
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.all(appContentHorizontalPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: CustomRoundedButton(
        onTap: () {
          _onContinueTap(context);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        buttonTitle: continueKey,
        showBorder: false,
        widthPercentage: 1.0,
        height: 50,
        radius: 8,
      ),
    );
  }

  void _onContinueTap(BuildContext context) {
    final formState = context.read<TransportEnrollFormCubit>().state;
    if (formState.selectedPickup == null) {
      Utils.showSnackBar(
          context: context, message: pleaseSelectPickDropPointKey);
      return;
    }
    if (formState.selectedShift == null) {
      Utils.showSnackBar(context: context, message: pleaseSelectShiftKey);
      return;
    }
    final feesState = context.read<FeesCubit>().state;
    final bool mustSelectFee =
        feesState is FeesFetchSuccess && feesState.feesResponse.fees.isNotEmpty;
    if (mustSelectFee && formState.selectedFee == null) {
      Utils.showSnackBar(context: context, message: pleaseSelectDurationKey);
      return;
    }
    _showReviewBottomSheet(context);
  }

  void _submitEnrollment(BuildContext context) {
    final formState = context.read<TransportEnrollFormCubit>().state;
    final authCubit = context.read<AuthCubit>();
    final userId = authCubit.getUserDetails().id ?? 0;

    // Get the IDs from the selected items
    final pickupPointId = formState.selectedPickup?.id ?? 0;
    final shiftId = formState.selectedShift?.id ?? 0;
    final transportationFeeId = formState.selectedFee?.id ?? 0;

    // Submit the enrollment
    context.read<TransportEnrollmentSubmissionCubit>().submitEnrollment(
          paymentMethod: 'Razorpay', // Default payment method
          userId: userId,
          pickupPointId: pickupPointId,
          transportationFeeId: transportationFeeId,
          shiftId: shiftId,
        );
  }

  void _showReviewBottomSheet(BuildContext context) {
    final formState = context.read<TransportEnrollFormCubit>().state;
    final String pickup = formState.selectedPickup?.name ?? "-";
    final String shift = formState.selectedShift?.displayName ?? "-";
    final String duration = formState.selectedFee?.toString() ?? "-";

    // Capture the cubit before opening bottom sheet
    final submissionCubit = context.read<TransportEnrollmentSubmissionCubit>();
    final authCubit = context.read<AuthCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        // Provide the cubits to the bottom sheet context
        return MultiBlocProvider(
          providers: [
            BlocProvider<TransportEnrollmentSubmissionCubit>.value(
              value: submissionCubit,
            ),
            BlocProvider<AuthCubit>.value(
              value: authCubit,
            ),
          ],
          child: SafeArea(
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
                          textKey: reviewYourSelectionKey,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close),
                      )
                    ],
                  ),
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Theme.of(ctx).colorScheme.tertiary),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextContainer(
                          textKey:
                              '${Utils.getTranslatedLabel(pickupPointKey)}: $pickup',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(ctx).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextContainer(
                          textKey:
                              '${Utils.getTranslatedLabel(shiftTimeKey)} : $shift',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(ctx).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextContainer(
                          textKey:
                              '${Utils.getTranslatedLabel(durationKey)} : $duration',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(ctx).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  BlocConsumer<TransportEnrollmentSubmissionCubit,
                      TransportEnrollmentSubmissionState>(
                    listener: (ctx, state) {
                      if (state is TransportEnrollmentSubmissionSuccess) {
                        // Close bottom sheet
                        Navigator.of(ctx).pop();

                        // Get user ID
                        final userId =
                            context.read<AuthCubit>().getUserDetails().id;

                        // Navigate to success screen
                        Get.offNamed(
                          Routes.transportEnrollSubmittedScreen,
                          arguments: RequestSubmittedScreen.buildArguments(
                            message: state.response.message,
                            userId: userId,
                          ),
                        );
                      } else if (state
                          is TransportEnrollmentSubmissionFailure) {
                        // Show error message
                        Utils.showSnackBar(
                          context: ctx,
                          message: state.errorMessage,
                        );
                      }
                    },
                    builder: (ctx, state) {
                      final isLoading =
                          state is TransportEnrollmentSubmissionInProgress;

                      return CustomRoundedButton(
                        onTap: isLoading
                            ? null
                            : () {
                                _submitEnrollment(context);
                              },
                        backgroundColor: Theme.of(ctx).colorScheme.primary,
                        buttonTitle: confirmKey,
                        showBorder: false,
                        widthPercentage: 1.0,
                        height: 50,
                        radius: 8,
                        child: isLoading
                            ? const CustomCircularProgressIndicator(
                                strokeWidth: 2,
                                widthAndHeight: 20,
                              )
                            : null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PickupPointsCubit()..fetch()),
        BlocProvider(create: (_) => ShiftsCubit()),
        BlocProvider(create: (_) => FeesCubit()),
        BlocProvider(create: (_) => TransportEnrollFormCubit()),
        BlocProvider(create: (_) => TransportEnrollmentSubmissionCubit()),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Column(
              children: [
                const CustomAppbar(
                    titleKey: transportationKey, showBackButton: true),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildFormContent(context),
                  ),
                ),
                SafeArea(top: false, child: _buildBottomAction(context)),
              ],
            ),
          );
        },
      ),
    );
  }
}
