import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StartNewChat extends StatelessWidget {
  const StartNewChat({
    super.key,
    required this.title,
    required this.description,
    this.onTapLetsStartChat,
  });

  final String title;
  final String description;
  final VoidCallback? onTapLetsStartChat;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          SvgPicture.asset(
            Utils.getImagePath("new_chat_icon.svg"),
            width: 132,
            height: 132,
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomRoundedButton(
            onTap: onTapLetsStartChat,
            widthPercentage: 0.5,
            height: 50,
            backgroundColor: Theme.of(context).colorScheme.primary,
            buttonTitle: Utils.getTranslatedLabel("letsStartChat"),
            showBorder: false,
            textSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
