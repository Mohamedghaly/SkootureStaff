import 'package:eschool_saas_staff/data/models/countryCode.dart';
import 'package:eschool_saas_staff/ui/widgets/countryCodePickerBottomsheet.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

/// Mobile number input with its dialling code built in.
///
/// Deliberately one field — same height, fill, border and radius as every other
/// field on the form — with the code as a tappable prefix behind a hairline.
/// Two boxes side by side read as two unrelated inputs and break the rhythm of
/// the form they sit in.
class MobileNumberFieldContainer extends StatelessWidget {
  final TextEditingController textEditingController;
  final CountryCode? selectedCountryCode;
  final ValueChanged<CountryCode> onCountryCodeSelected;
  final String hintTextKey;

  /// Matches the height and bottom spacing of [CustomTextFieldContainer] so the
  /// field lines up with the rest of the form.
  static const double _fieldHeight = 50.0;
  static const double _bottomSpacing = 15.0;

  const MobileNumberFieldContainer({
    super.key,
    required this.textEditingController,
    required this.selectedCountryCode,
    required this.onCountryCodeSelected,
    this.hintTextKey = mobileNumberKey,
  });

  Future<void> _openCountryCodePicker(BuildContext context) async {
    final result = await Utils.showBottomSheet(
      context: context,
      child: CountryCodePickerBottomsheet.getInstance(
        selectedCountryCode: selectedCountryCode,
      ),
    );

    if (result is CountryCode) {
      onCountryCodeSelected(result);
    }
  }

  Widget _buildCountryCodePrefix(BuildContext context) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final countryCode = selectedCountryCode;
    final flag = countryCode?.flag ?? "";

    return GestureDetector(
      onTap: () => _openCountryCodePicker(context),
      // The padding around the code is part of the tap target, not dead space.
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 14, end: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (flag.isNotEmpty) ...[
              Text(flag, style: const TextStyle(fontSize: 18.0)),
              const SizedBox(width: 8),
            ],
            Text(
              countryCode?.dialCode ?? Utils.getTranslatedLabel(codeKey),
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: secondaryColor.withValues(
                    alpha: countryCode == null ? 0.6 : 0.85),
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 20, color: secondaryColor.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  /// Hairline between the code and the number — the one cue that the prefix is
  /// its own control, without splitting the field into two boxes.
  Widget _buildSeparator(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: Theme.of(context).colorScheme.tertiary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Container(
      height: _fieldHeight,
      margin: const EdgeInsets.only(bottom: _bottomSpacing),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
      ),
      child: Row(
        children: [
          _buildCountryCodePrefix(context),
          _buildSeparator(context),
          Expanded(
            child: TextFormField(
              controller: textEditingController,
              keyboardType: TextInputType.phone,
              style: TextStyle(
                color: secondaryColor.withValues(alpha: 0.76),
                fontSize: 15.0,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding:
                    const EdgeInsetsDirectional.only(start: 12, end: 14),
                hintText: Utils.getTranslatedLabel(hintTextKey),
                hintStyle: TextStyle(
                  color: secondaryColor.withValues(alpha: 0.76),
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
