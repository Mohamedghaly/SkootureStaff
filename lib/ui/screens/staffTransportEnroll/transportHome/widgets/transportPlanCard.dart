import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/routeStopsCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/transportDashboardCubit.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TransportPlanCard extends StatelessWidget {
  const TransportPlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouteStopsCubit, RouteStopsState>(
      builder: (context, routeState) {
        final routeCubit = context.read<RouteStopsCubit>();
        final data = routeCubit.getRouteData();

        // Determine status based on data availability
        String statusText = Utils.getTranslatedLabel(activeKey);
        Color statusBackground = const Color(0xFFE8F5E8);
        Color statusForeground = const Color(0xFF2E7D32);

        if (data == null) {
          statusText = Utils.getTranslatedLabel(notAvailableKey);
          statusBackground = const Color(0xFFFFF3E0);
          statusForeground = const Color(0xFFE65100);
        }

        return BlocBuilder<TransportDashboardCubit, TransportDashboardState>(
          builder: (context, dashboardState) {
            // Get expires_in_days from dashboard API
            final dashboardCubit = context.read<TransportDashboardCubit>();
            final plan = dashboardCubit.getTransportPlan();
            final expiresInDays = plan?.expiresInDays;
            final shouldShowRenewButton =
                expiresInDays != null && expiresInDays <= 7;

            return EnrollCard(
              onTap: () {
                if (data != null) {
                  // Pass existing data to avoid API call
                  Get.toNamed(
                    Routes.transportPlanDetailsScreen,
                    arguments: {'routeStopsData': data},
                  );
                } else {
                  // Fallback to normal navigation if no data
                  Get.toNamed(Routes.transportPlanDetailsScreen);
                }
              },
              title: Utils.getTranslatedLabel(transportationPlanKey),
              trailing: EnrollStatusChip(
                title: statusText,
                background: statusBackground,
                foreground: statusForeground,
              ),
              children: [
                LabelValue(
                  label: Utils.getTranslatedLabel(planDurationKey),
                  value: plan?.duration ??
                      Utils.getTranslatedLabel(notAvailableKey),
                ),
                LabelValue(
                  label: Utils.getTranslatedLabel(validityPeriodKey),
                  value: plan?.validFrom != null && plan?.validTo != null
                      ? '${plan!.validFrom} - ${plan.validTo}'
                      : Utils.getTranslatedLabel(notAvailableKey),
                ),
                LabelValue(
                  label: Utils.getTranslatedLabel(routeNameKey),
                  value: plan?.route?.name ??
                      data?.route.displayName ??
                      Utils.getTranslatedLabel(notAvailableKey),
                ),
                // Plan Expiring Soon Warning with Renew Button
                if (shouldShowRenewButton) ...[
                  const SizedBox(height: 8),
                  // Divider line
                  Container(
                    height: 1,
                    color: const Color(0xFFE0E0E0),
                  ),
                  const SizedBox(height: 12),
                  // Warning row - no background, matching the image
                  Row(
                    children: [
                      // Warning icon with light pink circle
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFEBEE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFE53935),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Utils.getTranslatedLabel(planExpiringSoonKey),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE53935),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Your plan will expire in $expiresInDays ${expiresInDays == 1 ? 'day' : 'days'}.',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6D6E6F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Arrow button
                      GestureDetector(
                        onTap: () {
                          // Navigate to Plan Renewal Screen
                          final authCubit = context.read<AuthCubit>();
                          final userId = authCubit.getUserDetails().id;
                          Get.toNamed(
                            Routes.planRenewalScreen,
                            arguments: {'userId': userId},
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}
