import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/transportRequestCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/vehicleAssignmentStatusCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customMenuTile.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class TransportNavigationTile extends StatefulWidget {
  const TransportNavigationTile({super.key});

  @override
  State<TransportNavigationTile> createState() =>
      _TransportNavigationTileState();
}

class _TransportNavigationTileState extends State<TransportNavigationTile> {
  bool _isNavigating = false;
  final TransportRequestCubit _transportRequestCubit = TransportRequestCubit();

  @override
  void dispose() {
    _transportRequestCubit.close();
    super.dispose();
  }

  /// Main navigation handler that determines which screen to navigate to based on vehicle assignment status
  Future<void> _handleTransportNavigation() async {
    // Prevent multiple simultaneous navigation attempts
    if (_isNavigating) {
      debugPrint('[TransportNav] Already navigating, ignoring tap');
      return;
    }

    setState(() {
      _isNavigating = true;
    });
    debugPrint('[TransportNav] Starting navigation - fetching fresh status');

    try {
      final vehicleAssignmentCubit =
          context.read<VehicleAssignmentStatusCubit>();
      final authCubit = context.read<AuthCubit>();
      final userId = authCubit.getUserDetails().id ?? 0;

      debugPrint('[TransportNav] User ID: $userId');

      // ALWAYS fetch fresh status from API before navigating
      debugPrint('[TransportNav] Fetching fresh vehicle assignment status...');
      await vehicleAssignmentCubit.fetchVehicleAssignmentStatus(
        userId: userId,
      );

      // After fetch, check if it was successful
      if (!vehicleAssignmentCubit.isStatusLoaded()) {
        debugPrint(
            '[TransportNav] Failed to load status, navigating to enrollment');
        // Status fetch failed, navigate to enrollment screen as fallback
        Get.toNamed(
          Routes.staffTransportEnrollScreen,
          arguments: userId,
        );
        return;
      }

      // Get the fresh status from the cubit
      final status = vehicleAssignmentCubit.getVehicleAssignmentStatus();

      if (status == null) {
        // No status available, navigate to enrollment screen
        await _navigateToEnrollment(userId);
        return;
      }

      // Get the data value from the API response
      final dataValue = status.data?.toLowerCase() ?? '';

      debugPrint("this is the data valuse: $dataValue");

      // Route based on exact data value for maximum reliability
      switch (dataValue) {
        case 'assigned':
          // User is assigned to vehicle - navigate to transport home

          await _navigateToTransportHome(userId);
          break;

        case 'expired':
          // Plan has expired - navigate to plan renewal screen
          debugPrint(
              '[TransportNav] Plan expired, navigating to renewal screen');
          Get.toNamed(
            Routes.planRenewalScreen,
            arguments: userId,
          );
          break;

        case 'pending':
          // Request is pending - fetch request data and navigate to request details
          await _navigateToRequestDetails(userId);
          break;

        case 'false':
        default:
          // No assignment (data = "false" or any other value) - navigate to enrollment

          await _navigateToEnrollment(userId);
          break;
      }
    } catch (e) {
      // On error, navigate to enrollment screen as fallback
      final userId = context.read<AuthCubit>().getUserDetails().id ?? 0;
      Get.toNamed(
        Routes.staffTransportEnrollScreen,
        arguments: userId,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  /// Navigate to transport home screen (when user is assigned)
  Future<void> _navigateToTransportHome(int userId) async {
    Get.toNamed(
      Routes.transportEnrollHomeScreen,
      arguments: userId,
    );
  }

  /// Navigate to request details screen (when request is pending)
  Future<void> _navigateToRequestDetails(int userId) async {
    try {
      // Fetch the transport request details from API
      await _transportRequestCubit.fetchTransportRequests(userId: userId);

      // Check if we have request data
      if (_transportRequestCubit.hasRequests) {
        final mainRequest = _transportRequestCubit.mainRequest;

        if (mainRequest != null) {
          // Navigate to request details screen with transport request data
          Get.toNamed(
            Routes.transportRequestDetailsScreen,
            arguments: mainRequest,
          );
          return;
        }
      }

      // Fallback: If no request data found, navigate to enrollment
      Get.toNamed(
        Routes.staffTransportEnrollScreen,
        arguments: userId,
      );
    } catch (e) {
      // On error, fallback to enrollment screen
      Get.toNamed(
        Routes.staffTransportEnrollScreen,
        arguments: userId,
      );
    }
  }

  /// Navigate to enrollment screen (when user is not assigned)
  Future<void> _navigateToEnrollment(int userId) async {
    Get.toNamed(
      Routes.staffTransportEnrollScreen,
      arguments: userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _isNavigating,
      child: Opacity(
        opacity: _isNavigating ? 0.6 : 1.0,
        child: CustomMenuTile(
          iconImageName: "transportation.svg",
          titleKey: transportationKey,
          onTap: _handleTransportNavigation,
          trailingWidget: _isNavigating
              ? const SizedBox(
                  width: 30,
                  height: 30,
                  child: CustomCircularProgressIndicator(
                    strokeWidth: 2,
                    widthAndHeight: 20,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
