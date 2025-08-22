import 'package:flutter/material.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  final Color? indicatorColor;
  final double? strokeWidth;
  final double? widthAndHeight;

  const CustomCircularProgressIndicator(
      {super.key, this.indicatorColor, this.strokeWidth, this.widthAndHeight});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: widthAndHeight ?? 20,
        width: widthAndHeight ?? 20,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth ?? 2,
          color: indicatorColor ?? Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }
}
