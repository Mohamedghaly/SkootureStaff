import 'package:flutter/material.dart';

class ShowHidePasswordButton extends StatelessWidget {
  final bool hidePassword;
  final Function()? onTapButton;

  const ShowHidePasswordButton(
      {super.key, required this.hidePassword, required this.onTapButton});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
      child: GestureDetector(
        onTap: onTapButton,
        child: Icon(
          hidePassword ? Icons.visibility : Icons.visibility_off,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}
