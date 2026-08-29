import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/routeStopsCubit.dart';
import 'package:eschool_saas_staff/data/models/routeStops.dart';
import 'package:eschool_saas_staff/data/models/transportRequest.dart'
    as TransportRequestModel;
import 'package:eschool_saas_staff/ui/screens/staffTransportEnroll/transportHome/widgets/commonTransportWidgets.dart';
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
import 'package:eschool_saas_staff/app/routes.dart';

class TransportPlanDetailsScreen extends StatefulWidget {
  const TransportPlanDetailsScreen({super.key});

  static Widget getRouteInstance() => BlocProvider(
        create: (context) => RouteStopsCubit(),
        child: const TransportPlanDetailsScreen(),
      );

  @override
  State<TransportPlanDetailsScreen> createState() =>
      _TransportPlanDetailsScreenState();
}

class _TransportPlanDetailsScreenState
    extends State<TransportPlanDetailsScreen> {
  RouteStopsData? _passedData;
  TransportRequestModel.TransportRequest? _transportRequest;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Check if data was passed via navigation arguments
    final arguments = Get.arguments as Map<String, dynamic>?;
    _passedData = arguments?['routeStopsData'] as RouteStopsData?;
    _transportRequest = arguments?['transportRequest']
        as TransportRequestModel.TransportRequest?;

    if (_passedData != null) {
      // Use passed data to initialize cubit state without API call
      final response = RouteStopsResponse(
        error: false,
        message: 'Data passed from previous screen',
        data: _passedData!,
        code: 200,
      );
      context.read<RouteStopsCubit>().setRouteData(response);
    } else {
      // No data passed, fetch from API
      _fetchRouteStops();
    }
  }

  void _fetchRouteStops() {
    final userId = context.read<AuthCubit>().getUserDetails().id ?? 0;
    if (userId > 0) {
      context.read<RouteStopsCubit>().fetchRouteStops(userId: userId);
    }
  }

  Widget _buildRoutePickupSection(RouteStopsData data) {
    final userStop = data.userStop;
    return _SectionCard(
      title: Utils.getTranslatedLabel(routeAndPickupDetailsKey),
      children: [
        LabelValue(
          label: Utils.getTranslatedLabel(routeNameKey),
          value: data.route.displayName,
          addTopSpacing: false,
        ),
        LabelValue(
          label: Utils.getTranslatedLabel(vehicleKey),
          value:
              '${data.route.vehicleDisplayName} - ${data.route.registrationDisplay}',
        ),
        LabelValue(
          label: Utils.getTranslatedLabel(pickupLocationKey),
          value: userStop?.displayName ?? Utils.getTranslatedLabel(notAssignedKey),
        ),
        LabelValue(
          label: Utils.getTranslatedLabel(pickupTimeKey),
          value: userStop?.timeDisplay ?? Utils.getTranslatedLabel(notAvailableKey),
          addBottomSpacing: false,
        ),
      ],
    );
  }

  Widget _buildPlanSection(RouteStopsData data) {
    return _SectionCard(
      title: Utils.getTranslatedLabel(planDetailsKey),
      children: [
        LabelValue(
          label: Utils.getTranslatedLabel(routeIdKey),
          value: data.route.id.toString(),
          addTopSpacing: false,
        ),
        LabelValue(
          label: Utils.getTranslatedLabel(totalStopsKey),
          value: '${data.stops.length} ${Utils.getTranslatedLabel(stopsLowerKey)}',
        ),
        LabelValue(
          label: Utils.getTranslatedLabel(yourStopPositionKey),
          value: data.hasUserStop
              ? '${data.userStopIndex + 1} ${Utils.getTranslatedLabel(ofKey)} ${data.stops.length}'
              : Utils.getTranslatedLabel(notAssignedKey),
        ),
        LabelValue(
          label: Utils.getTranslatedLabel(serviceStatusKey),
          value: data.hasUserStop ? Utils.getTranslatedLabel(activeKey) : Utils.getTranslatedLabel(inactiveKey),
          addBottomSpacing: false,
        ),
      ],
    );
  }

  Widget _buildTransportRequestSection(
      TransportRequestModel.TransportRequest request) {
    return _SectionCard(
      title: Utils.getTranslatedLabel(requestDetailsKey),
      children: [
        LabelValue(
          label: Utils.getTranslatedLabel(requestIdKey),
          value: '#${request.id}',
          addTopSpacing: false,
        ),
        LabelValue(
          label: Utils.getTranslatedLabel(statusKey),
          value: request.statusDisplay,
        ),
        LabelValue(
          label: Utils.getTranslatedLabel(planDurationKey),
          value: request.details.plan.duration,
        ),
        LabelValue(
          label: Utils.getTranslatedLabel(validityPeriodKey),
          value: request.details.plan.validity,
        ),
        LabelValue(
          label: Utils.getTranslatedLabel(pickupLocationKey),
          value: request.details.pickupStop.name,
        ),
        LabelValue(
          label: Utils.getTranslatedLabel(paymentModeKey),
          value: request.mode.toUpperCase(),
          addBottomSpacing: false,
        ),
      ],
    );
  }

  Widget _buildContactSection(TransportRequestModel.TransportRequest request) {
    return _SectionCard(
      title: Utils.getTranslatedLabel(contactInformationKey),
      children: [
        LabelValue(
          label: Utils.getTranslatedLabel(schoolEmailKey),
          value: request.contactDetails.schoolEmail,
          addTopSpacing: false,
        ),
        LabelValue(
          label: Utils.getTranslatedLabel(schoolPhoneKey),
          value: request.contactDetails.schoolPhone,
          addBottomSpacing: false,
        ),
      ],
    );
  }

  Widget _buildRouteStopsView(RouteStopsData data) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: appContentHorizontalPadding,
        vertical: 16,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= 860;
          final double gap = isWide ? 20.0 : 14.0;

          final Widget routePickupSection = _buildRoutePickupSection(data);
          final Widget planSection = _buildPlanSection(data);

          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                routePickupSection,
                SizedBox(height: gap),
                planSection,
                SizedBox(height: gap),
                const SizedBox(height: 8),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: routePickupSection),
                  SizedBox(width: gap),
                  Expanded(child: planSection),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransportRequestView(
      TransportRequestModel.TransportRequest request) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: appContentHorizontalPadding,
        vertical: 16,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= 860;
          final double gap = isWide ? 20.0 : 14.0;

          final Widget requestSection = _buildTransportRequestSection(request);
          final Widget contactSection = _buildContactSection(request);

          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                requestSection,
                SizedBox(height: gap),
                contactSection,
                SizedBox(height: gap),
                const SizedBox(height: 8),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: requestSection),
                  SizedBox(width: gap),
                  Expanded(child: contactSection),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const CustomAppbar(
            titleKey: transportationKey,
            showBackButton: true,
          ),
          Expanded(
            child: BlocConsumer<RouteStopsCubit, RouteStopsState>(
              listener: (context, state) {
                if (state is RouteStopsFetchFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is RouteStopsInitial ||
                    state is RouteStopsFetchInProgress) {
                  return const Center(
                    child: CustomCircularProgressIndicator(),
                  );
                }

                final cubit = context.read<RouteStopsCubit>();
                if (!cubit.hasData) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          Utils.getTranslatedLabel(noTransportPlanDataAvailableKey),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomRoundedButton(
                          onTap: _fetchRouteStops,
                          buttonTitle: retryKey,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          showBorder: false,
                          widthPercentage: 0.3,
                        ),
                      ],
                    ),
                  );
                }

                // Check if we have RouteStopsData or TransportRequest data
                if (cubit.hasData) {
                  final data = cubit.getRouteData()!;
                  return _buildRouteStopsView(data);
                } else if (_transportRequest != null) {
                  return _buildTransportRequestView(_transportRequest!);
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          Utils.getTranslatedLabel(noTransportPlanDataAvailableKey),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
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
              child: BlocBuilder<RouteStopsCubit, RouteStopsState>(
                builder: (context, state) {
                  final cubit = context.read<RouteStopsCubit>();
                  final data = cubit.getRouteData();

                  return CustomRoundedButton(
                    onTap: () {
                      if (data != null) {
                        // Pass existing data to avoid API call
                        Get.toNamed(
                          Routes.busRouteScreen,
                          arguments: {'routeStopsData': data},
                        );
                      } else if (_transportRequest != null) {
                        // For transport request data, dial the support phone
                        if (_transportRequest!
                            .contactDetails.schoolPhone.isNotEmpty) {
                          Utils.launchCallLog(
                              mobile: _transportRequest!
                                  .contactDetails.schoolPhone);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(Utils.getTranslatedLabel(phoneNumberNotAvailableKey)),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        // Fallback to normal navigation if no data
                        Get.toNamed(Routes.busRouteScreen);
                      }
                    },
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    buttonTitle: _transportRequest != null
                        ? contactSupportKey
                        : busRouteKey,
                    showBorder: false,
                    widthPercentage: 1.0,
                    height: 50,
                    radius: 8,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: CustomTextContainer(
            textKey: title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        EnrollCard(
          title: '',
          trailing: const SizedBox(),
          showHeader: false,
          children: children,
        ),
      ],
    );
  }
}
