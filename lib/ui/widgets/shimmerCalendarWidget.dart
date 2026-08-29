import 'package:eschool_saas_staff/ui/widgets/monthSelectorWidget.dart';
import 'package:eschool_saas_staff/ui/widgets/weekdayHeadersWidget.dart';
import 'package:flutter/material.dart';

class ShimmerCalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime? sessionStartDate;
  final DateTime? sessionEndDate;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final bool isPreviousMonthDisabled;
  final bool isNextMonthDisabled;
  final Animation<double> shimmerAnimation;

  const ShimmerCalendarWidget({
    Key? key,
    required this.selectedDate,
    this.sessionStartDate,
    this.sessionEndDate,
    this.onPreviousMonth,
    this.onNextMonth,
    required this.isPreviousMonthDisabled,
    required this.isNextMonthDisabled,
    required this.shimmerAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
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
      child: Column(
        children: [
          MonthSelectorWidget(
            selectedDate: selectedDate,
            sessionStartDate: sessionStartDate,
            sessionEndDate: sessionEndDate,
            onPreviousMonth: onPreviousMonth,
            onNextMonth: onNextMonth,
            isPreviousMonthDisabled: isPreviousMonthDisabled,
            isNextMonthDisabled: isNextMonthDisabled,
          ),
          const WeekdayHeadersWidget(),
          Container(
            padding: const EdgeInsets.all(10),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 7,
              childAspectRatio: 1,
              children: List.generate(
                42,
                (index) => Container(
                  margin: const EdgeInsets.all(2),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: shimmerAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 20,
                          height: 20,
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
