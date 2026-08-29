import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/selectTransport/widgets/inlineExpandableSelector.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/transport/feesCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/transportPlanDetailsCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/data/models/transportRequest.dart';
import 'package:eschool_saas_staff/app/routes.dart';

class PlanRenewalScreen extends StatefulWidget {
  final int? userId;
  final TransportRequest? request;

  const PlanRenewalScreen({
    super.key,
    this.userId,
    this.request,
  });

  static Widget getRouteInstance() {
    final arguments = Get.arguments;
    int? userId;

    // Extract arguments - now only expecting userId
    if (arguments is int) {
      userId = arguments;
    } else if (arguments is Map<String, dynamic>) {
      userId = arguments['userId'] as int?;
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => FeesCubit()),
        BlocProvider(create: (context) => TransportPlanDetailsCubit()),
      ],
      child: PlanRenewalScreen(
        userId: userId,
        request: null, // No longer using request, will fetch from dashboard
      ),
    );
  }

  @override
  State<PlanRenewalScreen> createState() => _PlanRenewalScreenState();
}

class _PlanRenewalScreenState extends State<PlanRenewalScreen> {
  bool _isDurationOpen = false;
  String? _selectedDuration;
  int? _selectedFeeId;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();

    // Get userId from widget or AuthCubit
    _currentUserId = widget.userId;
    if (_currentUserId == null) {
      _currentUserId = context.read<AuthCubit>().getUserDetails().id;
    }

    // Fetch plan details from Current Plan API (transport/plans/current)
    if (_currentUserId != null) {
      Future.delayed(Duration.zero, () {
        context.read<TransportPlanDetailsCubit>().fetchPlanDetails(
              userId: _currentUserId!,
            );
      });
    }
  }

  /// Fetch fees when plan details are loaded
  void _fetchFeesIfNeeded(TransportPlanDetails planDetails) {
    if (planDetails.pickupStop?.id != null) {
      final feesState = context.read<FeesCubit>().state;
      if (feesState is FeesInitial || feesState is FeesFetchFailure) {
        context.read<FeesCubit>().fetch(
              pickupPointId: planDetails.pickupStop!.id!,
            );
      }
    }
  }

  void _navigateToChangeRoute(dynamic planDetails) {
    // Navigate to Change Route screen with current plan
    Get.toNamed(
      Routes.changeRouteScreen,
      arguments: planDetails,
    );
  }

  void _showPlanReviewBottomSheet() {
    // Validate selected duration
    if (_selectedDuration == null || _selectedFeeId == null) {
      Utils.showSnackBar(
        context: context,
        message: "Please select a duration",
      );
      return;
    }

    // Get plan details from cubit
    final planDetailsCubit = context.read<TransportPlanDetailsCubit>();
    final planDetails = planDetailsCubit.getPlanDetails();

    if (planDetails == null) {
      Utils.showSnackBar(
        context: context,
        message: "Plan details not available. Please try again.",
      );
      return;
    }

    // Get the selected fee plan
    final feesState = context.read<FeesCubit>().state;
    if (feesState is! FeesFetchSuccess) {
      Utils.showSnackBar(
        context: context,
        message: "Fee information not available. Please try again.",
      );
      return;
    }

    final selectedFeePlan = feesState.feesResponse.fees.firstWhere(
      (fee) => fee.id == _selectedFeeId,
      orElse: () => feesState.feesResponse.fees.first,
    );

    // Navigate to review screen
    Get.toNamed(
      Routes.planRenewalReviewScreen,
      arguments: {
        'userId': _currentUserId,
        'pickupPointId': planDetails.pickupStop?.id,
        'transportationFeeId': selectedFeePlan.id,
        'shiftId': planDetails.shiftId,
        'routeName': planDetails.route?.name,
        'pickupLocation': planDetails.pickupStop?.name,
        'planDuration': selectedFeePlan.displayLabel,
        'feeAmount': selectedFeePlan.formattedFeeAmount,
        'validity': planDetails.validFrom != null && planDetails.validTo != null
            ? '${planDetails.validFrom} - ${planDetails.validTo}'
            : 'N/A',
      },
    );
  }

  Widget _buildCurrentPlanCard(TransportPlanDetailsState state) {
    if (state is TransportPlanDetailsFetchInProgress) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: CustomCircularProgressIndicator(
            widthAndHeight: 30,
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (state is TransportPlanDetailsFetchFailure) {
      return ErrorContainer(
        errorMessage: state.errorMessage,
        onTapRetry: () {
          if (_currentUserId != null) {
            context
                .read<TransportPlanDetailsCubit>()
                .fetchPlanDetails(userId: _currentUserId!);
          }
        },
      );
    }

    if (state is TransportPlanDetailsNoData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 60,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  if (_currentUserId != null) {
                    context
                        .read<TransportPlanDetailsCubit>()
                        .fetchPlanDetails(userId: _currentUserId!);
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is TransportPlanDetailsFetchSuccess) {
      final planDetails = state.planDetails;

      return LayoutBuilder(
        builder: (context, constraints) {
          final double gap = 12;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomTextContainer(
                textKey: 'Current Plan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.maxFinite,
                padding:
                    EdgeInsets.only(top: 16, bottom: 5, left: 16, right: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Theme.of(context).colorScheme.tertiary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (planDetails.route?.name != null) ...[
                      LabelValue(
                        label: 'Route Name',
                        value: planDetails.route!.name!,
                        addTopSpacing: false,
                      ),
                    ],
                    if (planDetails.pickupStop?.name != null) ...[
                      LabelValue(
                        label: Utils.getTranslatedLabel(pickupLocationKey),
                        value: planDetails.pickupStop!.name!,
                      ),
                    ],
                    if (planDetails.duration != null) ...[
                      LabelValue(
                        label: 'Plan',
                        value: planDetails.duration!,
                      ),
                    ],
                    LabelValue(
                      label: 'Validity',
                      value: planDetails.validFrom != null &&
                              planDetails.validTo != null
                          ? '${planDetails.validFrom} - ${planDetails.validTo}'
                          : 'N/A',
                    ),
                    LabelValue(
                      label: 'Total Fee',
                      value: planDetails.totalFee != null
                          ? '${planDetails.totalFee}'
                          : 'N/A',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              CustomTextContainer(
                textKey:
                    'No changes will be made to your route or pickup point',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: gap + 6),

              // Fee/Duration selector
              BlocBuilder<FeesCubit, FeesState>(
                builder: (context, feesState) {
                  final bool isLoading = feesState is FeesFetchInProgress;
                  final List<String> durations = feesState is FeesFetchSuccess
                      ? feesState.feesResponse.fees
                          .map((fee) => fee.displayLabel)
                          .toList()
                      : [];

                  final bool hasError = feesState is FeesFetchFailure;
                  final bool noPickupPoint = planDetails.pickupStop?.id == null;
                  final bool disabled = isLoading || durations.isEmpty || noPickupPoint;

                  String hint = 'Select Duration';
                  if (noPickupPoint && feesState is FeesInitial) {
                    hint = 'Loading fees...';
                  } else if (isLoading) {
                    hint = 'Loading fees...';
                  } else if (hasError) {
                    hint = 'Failed to load fees';
                  } else if (durations.isEmpty) {
                    hint = Utils.getTranslatedLabel(noDataFoundKey);
                  }

                  return InlineExpandableSelector(
                    label: 'Select Duration',
                    hint: hint,
                    selected: _selectedDuration,
                    values: durations,
                    isOpen: _isDurationOpen,
                    isDisabled: disabled,
                    onHeaderTap: () {
                      if (!disabled) {
                        setState(() => _isDurationOpen = !_isDurationOpen);
                      }
                    },
                    onSelected: (v) {
                      // Get the fee ID for selected duration
                      if (feesState is FeesFetchSuccess) {
                        final selectedFee = feesState.feesResponse.fees
                            .firstWhere((fee) => fee.displayLabel == v);
                        setState(() {
                          _selectedDuration = v;
                          _selectedFeeId = selectedFee.id;
                          _isDurationOpen = false;
                        });
                      }
                    },
                  );
                },
              ),
              SizedBox(height: gap),
            ],
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocListener<TransportPlanDetailsCubit, TransportPlanDetailsState>(
        listener: (context, state) {
          // Fetch fees when plan details are successfully loaded
          if (state is TransportPlanDetailsFetchSuccess) {
            _fetchFeesIfNeeded(state.planDetails);
          }
        },
        child: Column(
          children: [
            CustomAppbar(
              titleKey: Utils.getTranslatedLabel(planRenewalKey),
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: appContentHorizontalPadding,
                  vertical: 16,
                ),
                child: BlocBuilder<TransportPlanDetailsCubit,
                    TransportPlanDetailsState>(
                  builder: (context, state) {
                    return _buildCurrentPlanCard(state);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
        child: Padding(
          padding: EdgeInsets.all(appContentHorizontalPadding),
          child:
              BlocBuilder<TransportPlanDetailsCubit, TransportPlanDetailsState>(
            builder: (context, planDetailsState) {
              return BlocBuilder<FeesCubit, FeesState>(
                builder: (context, feesState) {
                  final isLoading = (planDetailsState
                          is TransportPlanDetailsFetchInProgress) ||
                      (feesState is FeesFetchInProgress);

                  final isDisabled = isLoading ||
                      planDetailsState is! TransportPlanDetailsFetchSuccess ||
                      feesState is! FeesFetchSuccess ||
                      _selectedDuration == null;

                  // Check if current plan is available for Change Route button
                  final hasPlanDetails =
                      planDetailsState is TransportPlanDetailsFetchSuccess;

                  return Row(
                    children: [
                      // Change Route Button
                      Expanded(
                        child: CustomRoundedButton(
                          onTap: hasPlanDetails
                              ? () => _navigateToChangeRoute(
                                  planDetailsState.planDetails)
                              : null,
                          backgroundColor: Colors.transparent,
                          buttonTitle: Utils.getTranslatedLabel(changeRouteKey),
                          showBorder: true,
                          borderColor: Theme.of(context).colorScheme.primary,
                          titleColor: Theme.of(context).colorScheme.primary,
                          widthPercentage: 1.0,
                          height: 50,
                          radius: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Continue Button
                      Expanded(
                        child: CustomRoundedButton(
                          onTap: isDisabled ? null : _showPlanReviewBottomSheet,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          buttonTitle: isLoading ? 'Loading...' : 'Continue',
                          showBorder: false,
                          widthPercentage: 1.0,
                          height: 50,
                          radius: 12,
                          child: isLoading
                              ? CustomCircularProgressIndicator(
                                  widthAndHeight: 20,
                                  strokeWidth: 2,
                                )
                              : null,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
