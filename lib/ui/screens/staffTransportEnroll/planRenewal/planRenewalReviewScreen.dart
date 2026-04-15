import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/cubits/transport/transportEnrollmentSubmissionCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/app/routes.dart';

class PlanRenewalReviewScreen extends StatelessWidget {
  final int? userId;
  final int? pickupPointId;
  final int? transportationFeeId;
  final int? shiftId;
  final String? routeName;
  final String? pickupLocation;
  final String? planDuration;
  final String? feeAmount;
  final String? validity;

  const PlanRenewalReviewScreen({
    super.key,
    this.userId,
    this.pickupPointId,
    this.transportationFeeId,
    this.shiftId,
    this.routeName,
    this.pickupLocation,
    this.planDuration,
    this.feeAmount,
    this.validity,
  });

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};

    return BlocProvider(
      create: (_) => TransportEnrollmentSubmissionCubit(),
      child: PlanRenewalReviewScreen(
        userId: arguments['userId'] as int?,
        pickupPointId: arguments['pickupPointId'] as int?,
        transportationFeeId: arguments['transportationFeeId'] as int?,
        shiftId: arguments['shiftId'] as int?,
        routeName: arguments['routeName'] as String?,
        pickupLocation: arguments['pickupLocation'] as String?,
        planDuration: arguments['planDuration'] as String?,
        feeAmount: arguments['feeAmount'] as String?,
        validity: arguments['validity'] as String?,
      ),
    );
  }

  void _submitRenewal(BuildContext context) {
    // Validate all required fields
    if (userId == null ||
        pickupPointId == null ||
        transportationFeeId == null ||
        shiftId == null) {
      Utils.showSnackBar(
        context: context,
        message: "Missing required information. Please try again.",
      );
      return;
    }

    // Submit renewal request
    context.read<TransportEnrollmentSubmissionCubit>().submitEnrollment(
          userId: userId!,
          pickupPointId: pickupPointId!,
          transportationFeeId: transportationFeeId!,
          shiftId: shiftId!,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          CustomAppbar(
            titleKey: 'Review Renewal',
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: appContentHorizontalPadding,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const CustomTextContainer(
                    textKey: 'Review your plan renewal details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details Card
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (routeName != null) ...[
                          LabelValue(
                            label: 'Route Name',
                            value: routeName!,
                            addTopSpacing: false,
                          ),
                        ],
                        if (pickupLocation != null) ...[
                          LabelValue(
                            label: Utils.getTranslatedLabel(pickupLocationKey),
                            value: pickupLocation!,
                          ),
                        ],
                        if (planDuration != null) ...[
                          LabelValue(
                            label: Utils.getTranslatedLabel(planDurationKey),
                            value: planDuration!,
                          ),
                        ],
                        if (validity != null) ...[
                          LabelValue(
                            label: 'New Validity Period',
                            value: validity!,
                          ),
                        ],
                        if (feeAmount != null) ...[
                          LabelValue(
                            label: 'Amount',
                            value: feeAmount!,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info message
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomTextContainer(
                            textKey:
                                'Your current route and pickup location will remain unchanged.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
          child: BlocConsumer<TransportEnrollmentSubmissionCubit,
              TransportEnrollmentSubmissionState>(
            listener: (context, state) {
              if (state is TransportEnrollmentSubmissionSuccess) {
                // Navigate to success screen
                Get.offAllNamed(
                  Routes.transportEnrollSubmittedScreen,
                  arguments: {
                    'message': state.response.message,
                    'userId': userId,
                  },
                );
              } else if (state is TransportEnrollmentSubmissionFailure) {
                Utils.showSnackBar(
                  context: context,
                  message: state.errorMessage,
                );
              }
            },
            builder: (context, state) {
              final isLoading =
                  state is TransportEnrollmentSubmissionInProgress;

              return CustomRoundedButton(
                onTap: isLoading ? null : () => _submitRenewal(context),
                backgroundColor: Theme.of(context).colorScheme.primary,
                buttonTitle: 'Confirm Renewal',
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
              );
            },
          ),
        ),
      ),
    );
  }
}
