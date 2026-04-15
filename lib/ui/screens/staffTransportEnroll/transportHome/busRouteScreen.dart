import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/currentPlanCubit.dart';
import 'package:eschool_saas_staff/cubits/transport/routeStopsCubit.dart';
import 'package:eschool_saas_staff/data/models/routeStops.dart';
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

class BusRouteScreen extends StatefulWidget {
  const BusRouteScreen({super.key});

  static Widget getRouteInstance() => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => RouteStopsCubit()),
          BlocProvider(create: (context) => CurrentPlanCubit()),
        ],
        child: const BusRouteScreen(),
      );

  @override
  State<BusRouteScreen> createState() => _BusRouteScreenState();
}

class _BusRouteScreenState extends State<BusRouteScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // Start shimmer animation
    _shimmerController.repeat();

    // Always fetch fresh data from API
    _fetchRouteStops();
    _fetchCurrentPlan();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _fetchRouteStops() {
    final userId = context.read<AuthCubit>().getUserDetails().id ?? 0;
    if (userId > 0) {
      context.read<RouteStopsCubit>().fetchRouteStops(userId: userId);
    }
  }

  void _fetchCurrentPlan() {
    final userId = context.read<AuthCubit>().getUserDetails().id ?? 0;
    if (userId > 0) {
      context.read<CurrentPlanCubit>().fetchCurrentPlan(userId: userId);
    }
  }

  void _refreshRouteStops() {
    final userId = context.read<AuthCubit>().getUserDetails().id ?? 0;
    if (userId > 0) {
      context.read<RouteStopsCubit>().refreshRouteStops(userId: userId);
    }
  }

  Widget _currentRouteCard(BuildContext context, RouteStopsData data) {
    final userStop = data.userStop;
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F5EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF57CC99)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RouteMetaRow(
            left:
                '${Utils.getTranslatedLabel(routeNameKey)} : ${data.route.displayName} |',
            right: data.route.registrationDisplay,
          ),
          const SizedBox(height: 4),
          _RouteMetaRow(
            left:
                '${Utils.getTranslatedLabel(yourPickupKey)} : ${userStop?.displayName ?? Utils.getTranslatedLabel(notFoundKey)} |',
            right: userStop?.timeDisplay ??
                Utils.getTranslatedLabel(unknownTimeKey),
          ),
        ],
      ),
    );
  }

  Widget _stopsTimeline(BuildContext context, RouteStopsData data) {
    final stops = data.stops;
    final currentIndex = data.userStopIndex;

    return LayoutBuilder(builder: (context, constraints) {
      final bool isWide = constraints.maxWidth >= 460;
      final double tileHeight = isWide ? 60.0 : 56.0;
      final double totalHeight = tileHeight * stops.length;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: totalHeight,
            child: CustomPaint(
              painter: _TimelineColumnPainter(
                itemCount: stops.length,
                currentIndex: currentIndex,
                tileHeight: tileHeight,
                lineWidth: 3.0,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: List.generate(stops.length, (index) {
                final stop = stops[index];
                final bool isCurrent = index == currentIndex;
                return SizedBox(
                  height: tileHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomTextContainer(
                          textKey: stop.displayName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isCurrent
                                ? const Color(0xFF57CC99)
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomTextContainer(
                        textKey: stop.timeDisplay,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isCurrent
                              ? const Color(0xFF57CC99)
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildChangeStopButton(BuildContext context) {
    return BlocBuilder<CurrentPlanCubit, CurrentPlanState>(
      builder: (context, planState) {
        final bool isLoading = planState is CurrentPlanFetchInProgress;
        final bool hasPlan = planState is CurrentPlanFetchSuccess;

        if (!hasPlan && !isLoading) {
          // Don't show button if no plan data
          return const SizedBox.shrink();
        }

        return CustomRoundedButton(
          onTap: isLoading
              ? null
              : () {
                  if (planState is CurrentPlanFetchSuccess) {
                    // Navigate to change route screen with current plan
                    Get.toNamed(
                      Routes.changeRouteScreen,
                      arguments: planState.plan,
                    );
                  }
                },
          buttonTitle: changeStopKey,
          backgroundColor: Theme.of(context).colorScheme.primary,
          showBorder: false,
          widthPercentage: 1.0,
          height: 50,
          radius: 8,
          child: isLoading
              ? const CustomCircularProgressIndicator(
                  widthAndHeight: 20,
                  strokeWidth: 2,
                )
              : null,
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Route Card Shimmer
        AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Container(
              width: double.maxFinite,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(_shimmerAnimation.value - 1, 0),
                  end: Alignment(_shimmerAnimation.value, 0),
                  colors: [
                    Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.05),
                    Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.1),
                    Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Timeline Shimmer - Multiple stops
        ...List.generate(6, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                // Timeline dot
                AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(_shimmerAnimation.value - 1, 0),
                          end: Alignment(_shimmerAnimation.value, 0),
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.1),
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.2),
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                // Stop name shimmer
                Expanded(
                  child: AnimatedBuilder(
                    animation: _shimmerAnimation,
                    builder: (context, child) {
                      return Container(
                        height: 16,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(_shimmerAnimation.value - 1, 0),
                            end: Alignment(_shimmerAnimation.value, 0),
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.05),
                              Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.1),
                              Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Time shimmer
                AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 60,
                      height: 16,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(_shimmerAnimation.value - 1, 0),
                          end: Alignment(_shimmerAnimation.value, 0),
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.05),
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.1),
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 24),

        // Button Shimmer
        AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Container(
              width: double.maxFinite,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(_shimmerAnimation.value - 1, 0),
                  end: Alignment(_shimmerAnimation.value, 0),
                  colors: [
                    Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.05),
                    Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.1),
                    Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const CustomAppbar(titleKey: busRouteKey, showBackButton: true),
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
                    (state is RouteStopsFetchInProgress && !state.isRefresh)) {
                  return SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: appContentHorizontalPadding,
                      vertical: 16,
                    ),
                    child: _buildShimmerLoading(),
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
                          Utils.getTranslatedLabel(noRouteDataAvailableKey),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomRoundedButton(
                          onTap: _refreshRouteStops,
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

                final data = cubit.getRouteData()!;
                return RefreshIndicator(
                  onRefresh: () async => _refreshRouteStops(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: appContentHorizontalPadding,
                      vertical: 16,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final bool isWide = constraints.maxWidth >= 600;
                        final double contentGap = isWide ? 20.0 : 16.0;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _currentRouteCard(context, data),
                            SizedBox(height: contentGap),
                            _stopsTimeline(context, data),
                            SizedBox(height: contentGap * 1.5),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(
            horizontal: appContentHorizontalPadding,
            vertical: appContentHorizontalPadding),
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
        child: _buildChangeStopButton(context),
      ),
    );
  }
}

class _RouteMetaRow extends StatelessWidget {
  final String left;
  final String right;
  const _RouteMetaRow({required this.left, required this.right});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomTextContainer(
          textKey: left,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF212121),
              height: 1.2),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(width: 3),
        CustomTextContainer(
          textKey: right,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF212121),
              height: 1.2),
        ),
      ],
    );
  }
}

class _TimelineColumnPainter extends CustomPainter {
  final int itemCount;
  final int currentIndex;
  final double tileHeight;
  final double lineWidth;
  _TimelineColumnPainter({
    required this.itemCount,
    required this.currentIndex,
    required this.tileHeight,
    this.lineWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    const double dotRadius = 6;
    final Paint linePaint = Paint()
      ..color = const Color(0xFFEBEEF3)
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.butt;
    for (int i = 0; i < itemCount; i++) {
      final double centerY = (i * tileHeight) + (tileHeight / 2);
      final double topY = i == 0 ? centerY : (i * tileHeight);
      final double bottomY =
          i == itemCount - 1 ? centerY : ((i + 1) * tileHeight);

      if (i != 0) {
        canvas.drawLine(
          Offset(centerX, topY),
          Offset(centerX, centerY - dotRadius),
          linePaint,
        );
      }

      final bool isCurrent = i == currentIndex;
      final Paint dotPaint = Paint()
        ..color = isCurrent ? const Color(0xFF57CC99) : const Color(0xFFEBEEF3);
      canvas.drawCircle(Offset(centerX, centerY), dotRadius, dotPaint);

      if (i != itemCount - 1) {
        canvas.drawLine(
          Offset(centerX, centerY + dotRadius),
          Offset(centerX, bottomY),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TimelineColumnPainter oldDelegate) {
    return oldDelegate.itemCount != itemCount ||
        oldDelegate.currentIndex != currentIndex ||
        oldDelegate.tileHeight != tileHeight ||
        oldDelegate.lineWidth != lineWidth;
  }
}
