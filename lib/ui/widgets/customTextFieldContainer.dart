import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFieldContainer extends StatelessWidget {
  final String hintTextKey;
  final bool hideText;
  final String? initialValue;
  final Color? borderColor;
  final String? labelTextKey;
  final double? bottomPadding;
  final Widget? suffixWidget;
  final Color? backgroundColor;
  final Widget? prefixWidget;
  final EdgeInsetsGeometry? padding;
  final TextEditingController? textEditingController;
  final int? maxLines;
  final double? height;
  final bool? enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  const CustomTextFieldContainer({
    super.key,
    this.bottomPadding,
    this.enabled,
    this.suffixWidget,
    this.prefixWidget,
    this.hideText = false,
    this.backgroundColor,
    required this.hintTextKey,
    this.height,
    this.maxLines,
    this.textEditingController,
    this.initialValue,
    this.borderColor,
    this.labelTextKey,
    this.padding,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: EdgeInsets.only(bottom: bottomPadding ?? 15.0),
      decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
              color: borderColor ?? Theme.of(context).colorScheme.tertiary)),
      alignment: Alignment.center,
      padding: padding ??
          EdgeInsetsDirectional.only(
              start: prefixWidget == null ? appContentHorizontalPadding : 0),
      child: TextFormField(
        keyboardType: keyboardType,
        initialValue: initialValue,
        enabled: enabled,
        controller: textEditingController,
        obscureText: hideText,
        maxLines: maxLines ?? 1,
        style: TextStyle(
            color: labelTextKey == null
                ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.76)
                : Theme.of(context).colorScheme.secondary,
            fontSize: 15.0),
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: labelTextKey != null
              ? Utils.getTranslatedLabel(labelTextKey!)
              : null,
          prefixIcon: prefixWidget,
          suffixIcon: suffixWidget,
          hintText: Utils.getTranslatedLabel(hintTextKey),
          labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.76),
              fontSize: 13.0),
          hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.76),
              fontSize: 15.0),
          contentPadding:
              prefixWidget != null ? const EdgeInsets.only(top: 12.5) : null,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
