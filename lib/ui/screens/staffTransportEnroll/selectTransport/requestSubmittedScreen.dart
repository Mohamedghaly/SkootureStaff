import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/transport/transportRequestCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestSubmittedScreen extends StatefulWidget {
  final String message;
  final int? userId;

  const RequestSubmittedScreen({
    super.key,
    required this.message,
    this.userId,
  });

  @override
  State<RequestSubmittedScreen> createState() => _RequestSubmittedScreenState();

  static Widget getRouteInstance() {
    final args = Get.arguments as Map<String, dynamic>?;
    return RequestSubmittedScreen(
      message: args?['message'] as String? ??
          'Your transportation plan renewal has been submitted with updated route.',
      userId: args?['userId'] as int?,
    );
  }

  static Map<String, dynamic> buildArguments({
    required String message,
    int? userId,
  }) {
    return {
      'message': message,
      if (userId != null) 'userId': userId,
    };
  }
}

class _RequestSubmittedScreenState extends State<RequestSubmittedScreen> {
  final TransportRequestCubit _transportRequestCubit = TransportRequestCubit();
  bool _isNavigating = false;

  @override
  void dispose() {
    _transportRequestCubit.close();
    super.dispose();
  }

  /// Fetch transport request and navigate to details screen
  Future<void> _handleViewRequest() async {
    if (_isNavigating) return;

    if (widget.userId == null) {
      // If no userId, just go back
      Get.back();
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    try {
      // Fetch the transport request data
      await _transportRequestCubit.fetchTransportRequests(
          userId: widget.userId!);

      // Check if we have request data
      if (_transportRequestCubit.hasRequests) {
        final mainRequest = _transportRequestCubit.mainRequest;

        if (mainRequest != null) {
          // Navigate to transport request details screen with the first request
          Get.offNamed(
            Routes.transportRequestDetailsScreen,
            arguments: mainRequest,
          );
          return;
        }
      }

      // Fallback: If no request data found, navigate to transport home
      Get.offAllNamed(
        Routes.transportEnrollHomeScreen,
        arguments: widget.userId,
      );
    } catch (e) {
      // On error, show a snackbar and navigate to transport home
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load request details',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }

      // Navigate to transport home as fallback
      Get.offAllNamed(
        Routes.transportEnrollHomeScreen,
        arguments: widget.userId,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: appContentHorizontalPadding,
            vertical: 24,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success Icon
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 80,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),

              const SizedBox(height: 32),

              // Success Title
              CustomTextContainer(
                textKey: requestSubmittedKey,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 16),

              // Success Message
              CustomTextContainer(
                textKey: widget.message,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // View Request Button
              _isNavigating
                  ? Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: CustomCircularProgressIndicator(
                          strokeWidth: 2,
                          widthAndHeight: 24,
                        ),
                      ),
                    )
                  : CustomRoundedButton(
                      onTap: _handleViewRequest,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      buttonTitle: viewRequestKey,
                      showBorder: false,
                      widthPercentage: 1.0,
                      height: 50,
                      radius: 8,
                    ),

              const SizedBox(height: 12),

              // Home Button
              AbsorbPointer(
                absorbing: _isNavigating,
                child: Opacity(
                  opacity: _isNavigating ? 0.5 : 1.0,
                  child: TextButton(
                    onPressed: () {
                      // Navigate back to home screen
                      Get.offAllNamed(Routes.homeScreen);
                    },
                    child: CustomTextContainer(
                      textKey: homeKey,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
