import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomAnimatedRadioButton extends StatefulWidget {
  final String textKey;
  final bool isSelected;
  final Function() onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedBackgroundColor;
  final Color unselectedBackgroundColor;
  final double borderRadius;
  final double height;
  final Color? fixedBorderColor; // NEW PARAMETER

  const CustomAnimatedRadioButton({
    super.key,
    required this.textKey,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    required this.selectedBackgroundColor,
    required this.unselectedBackgroundColor,
    this.borderRadius = 8.0,
    this.height = 50.0,
    this.fixedBorderColor,
  });

  @override
  State<CustomAnimatedRadioButton> createState() =>
      _CustomAnimatedRadioButtonState();
}

class _CustomAnimatedRadioButtonState extends State<CustomAnimatedRadioButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(CustomAnimatedRadioButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: widget.height,
        padding: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? widget.selectedBackgroundColor
              : widget.unselectedBackgroundColor,
          border: Border.all(
            color: widget.fixedBorderColor ??
                (widget.isSelected
                    ? widget.selectedColor
                    : Theme.of(context).colorScheme.tertiary),
            width: widget.isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Expanded(
                  child: CustomTextContainer(
                    textKey: widget.textKey,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: widget.isSelected
                          ? widget.selectedColor
                          : widget.unselectedColor,
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.fixedBorderColor ??
                              (widget.isSelected
                                  ? widget.selectedColor
                                  : Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withValues(alpha: 0.5)),
                          width: 2,
                        ),
                        color: Colors.transparent,
                      ),
                      child: Center(
                        child: widget.isSelected
                            ? FadeTransition(
                                opacity: _opacityAnimation,
                                child: ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: widget.selectedColor,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
