import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter/material.dart';

/// Reusable shimmer placeholder block.
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);
    final highlight =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.18);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [base, highlight, base],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton matching the staff/teacher home screen layout.
/// Shown while [HomeScreenDataCubit] is fetching data.
class HomeShimmerScaffold extends StatelessWidget {
  const HomeShimmerScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final hp = appContentHorizontalPadding;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 80,
        bottom: 100,
      ),
      child: Column(
        children: [
          // Section title placeholder
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hp, vertical: 12),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 100, height: 18),
                ShimmerBox(width: 60, height: 14),
              ],
            ),
          ),
          // Overview cards row
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: hp),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => const ShimmerBox(
                width: 140,
                height: 150,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tasks / Timetable card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hp),
            child: const ShimmerBox(height: 140),
          ),
          const SizedBox(height: 16),
          // Leaves card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hp),
            child: const ShimmerBox(height: 120),
          ),
          const SizedBox(height: 16),
          // Holidays card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hp),
            child: const ShimmerBox(height: 120),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for the My Tasks list (2 task cards).
class MyTasksShimmer extends StatelessWidget {
  const MyTasksShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
      child: Column(
        children: const [
          ShimmerBox(height: 80),
          SizedBox(height: 12),
          ShimmerBox(height: 80),
        ],
      ),
    );
  }
}
