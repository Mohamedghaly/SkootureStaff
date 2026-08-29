import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/transportPlanHistoryCubit.dart';
import 'package:eschool_saas_staff/data/models/transportPlanHistoryItem.dart';
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransportPlanHistoryScreen extends StatefulWidget {
  const TransportPlanHistoryScreen._();

  static Widget getRouteInstance() => BlocProvider(
        create: (context) => TransportPlanHistoryCubit(),
        child: const TransportPlanHistoryScreen._(),
      );

  @override
  State<TransportPlanHistoryScreen> createState() =>
      _TransportPlanHistoryScreenState();
}

class _TransportPlanHistoryScreenState
    extends State<TransportPlanHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _fetchPlans);
  }

  void _fetchPlans() {
    final userId = context.read<AuthCubit>().getUserDetails().id ?? 0;
    if (userId > 0) {
      context.read<TransportPlanHistoryCubit>().fetchPlans(userId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const CustomAppbar(
            titleKey: planHistoryKey,
            showBackButton: true,
          ),
          Expanded(
            child: BlocBuilder<TransportPlanHistoryCubit,
                TransportPlanHistoryState>(
              builder: (context, state) {
                if (state is TransportPlanHistoryFetchInProgress) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TransportPlanHistoryFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      errorMessage: state.errorMessage,
                      onTapRetry: _fetchPlans,
                    ),
                  );
                }

                if (state is TransportPlanHistoryFetchSuccess) {
                  if (state.plans.isEmpty) {
                    return Center(
                      child: noDataContainer(titleKey: noDataFoundKey),
                    );
                  }

                  return RefreshIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    onRefresh: () async => _fetchPlans(),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(appContentHorizontalPadding),
                      itemCount: state.plans.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) =>
                          _PlanHistoryCard(plan: state.plans[index]),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Plan History Card ─────────────────────────────────────

class _PlanHistoryCard extends StatelessWidget {
  final TransportPlanHistoryItem plan;

  const _PlanHistoryCard({required this.plan});

  ({Color background, Color foreground}) _statusColor() {
    switch (plan.planStatus?.toLowerCase()) {
      case 'active':
        return (
          background: const Color(0xFFE8F5E8),
          foreground: const Color(0xFF2E7D32),
        );
      case 'inactive':
        return (
          background: const Color(0xFFFFF3E0),
          foreground: const Color(0xFFE65100),
        );
      case 'expired':
        return (
          background: const Color(0xFFFFE8E8),
          foreground: const Color(0xFFE53935),
        );
      default:
        return (
          background: const Color(0xFFE0EDF6),
          foreground: const Color(0xFF29638A),
        );
    }
  }

  String _statusLabel() {
    final s = plan.planStatus ?? '';
    if (s.isEmpty) return '';
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final colors = _statusColor();
    final statusLabel = _statusLabel();

    final shiftDisplay = [
      plan.shift?.name,
      plan.shift?.timeWindow,
    ].whereType<String>().join(' : ');

    final estimatedTime = plan.estimatedPickupTime;

    return EnrollCard(
      title: Utils.getTranslatedLabel(transportationPlanKey),
      trailing: statusLabel.isNotEmpty
          ? EnrollStatusChip(
              title: statusLabel,
              background: colors.background,
              foreground: colors.foreground,
            )
          : const SizedBox.shrink(),
      children: [
        if (plan.route?.name != null)
          LabelValue(
            label: Utils.getTranslatedLabel(routeNameKey),
            value: plan.route!.name!,
          ),
        if (plan.pickupStop?.name != null)
          LabelValue(
            label: Utils.getTranslatedLabel(pickupLocationKey),
            value: plan.pickupStop!.name!,
          ),
        if (shiftDisplay.isNotEmpty)
          LabelValue(
            label: Utils.getTranslatedLabel(shiftKey),
            value: shiftDisplay,
          ),
        if (estimatedTime != null && estimatedTime.isNotEmpty)
          LabelValue(
            label: Utils.getTranslatedLabel(estimatedPickupTimeKey),
            value: '$estimatedTime (${Utils.getTranslatedLabel(estimatedKey)})',
            addBottomSpacing: false,
          ),
      ],
    );
  }
}
