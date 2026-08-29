import 'package:flutter/material.dart';

/// Shimmer widget for Transport Home Screen loading state
class TransportHomeShimmerWidget extends StatelessWidget {
  final Animation<double> shimmerAnimation;

  const TransportHomeShimmerWidget({
    Key? key,
    required this.shimmerAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Transport Plan Card Shimmer
          _buildCardShimmer(context, height: 180),
          const SizedBox(height: 12),

          // Bus Info Card Shimmer
          _buildCardShimmer(context, height: 140),
          const SizedBox(height: 12),

          // Live Tracking Card Shimmer
          _buildCardShimmer(context, height: 200),
          const SizedBox(height: 12),

          // Attendance Card Shimmer
          _buildCardShimmer(context, height: 160),
          const SizedBox(height: 12),

          // Transport Request Card Shimmer
          _buildCardShimmer(context, height: 140),
        ],
      ),
    );
  }

  Widget _buildCardShimmer(BuildContext context, {required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}

class ShimmerSummaryWidget extends StatelessWidget {
  final Animation<double> shimmerAnimation;

  const ShimmerSummaryWidget({
    Key? key,
    required this.shimmerAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left shimmer card
          Expanded(
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: shimmerAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(shimmerAnimation.value - 1, 0),
                          end: Alignment(shimmerAnimation.value, 0),
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.1),
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.1),
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3),
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                AnimatedBuilder(
                  animation: shimmerAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(shimmerAnimation.value - 1, 0),
                          end: Alignment(shimmerAnimation.value, 0),
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.1),
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3),
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Divider
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).colorScheme.tertiary,
          ),

          // Right shimmer card
          Expanded(
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: shimmerAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(shimmerAnimation.value - 1, 0),
                          end: Alignment(shimmerAnimation.value, 0),
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.1),
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3),
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                AnimatedBuilder(
                  animation: shimmerAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(shimmerAnimation.value - 1, 0),
                          end: Alignment(shimmerAnimation.value, 0),
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.1),
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3),
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
