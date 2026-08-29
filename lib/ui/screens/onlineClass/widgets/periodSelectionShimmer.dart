import 'package:flutter/material.dart';

/// Loading placeholder for the "Which period(s)?" section.
///
/// Renders a few shimmering period-card skeletons while the periods are being
/// fetched. Self-contained (owns its [AnimationController]) and uses the same
/// shimmer style as the rest of the app.
class PeriodSelectionShimmer extends StatefulWidget {
  /// Number of skeleton cards to show.
  final int itemCount;

  const PeriodSelectionShimmer({super.key, this.itemCount = 3});

  @override
  State<PeriodSelectionShimmer> createState() => _PeriodSelectionShimmerState();
}

class _PeriodSelectionShimmerState extends State<PeriodSelectionShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < widget.itemCount; i++) ...[
          _buildCard(context),
          if (i != widget.itemCount - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBox(animation: _animation, width: 20, height: 20, radius: 4),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(
                    animation: _animation, width: 130, height: 14, radius: 4),
                const SizedBox(height: 8),
                _ShimmerBox(
                    animation: _animation, width: 80, height: 12, radius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single animated shimmer rectangle.
class _ShimmerBox extends StatelessWidget {
  final Animation<double> animation;
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.animation,
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.onSurface;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(animation.value - 1, 0),
              end: Alignment(animation.value, 0),
              colors: [
                base.withValues(alpha: 0.08),
                base.withValues(alpha: 0.20),
                base.withValues(alpha: 0.08),
              ],
            ),
          ),
        );
      },
    );
  }
}
