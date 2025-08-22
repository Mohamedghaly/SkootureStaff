import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchContainer extends StatelessWidget {
  final TextEditingController textEditingController;
  final Function? additionalCallback;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool? showSearchIcon;

  const SearchContainer(
      {super.key,
      required this.textEditingController,
      this.margin,
      this.padding,
      this.showSearchIcon,
      this.additionalCallback});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ??
          EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
      width: MediaQuery.of(context).size.width,
      height: 50,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(5)),
      padding: padding ??
          EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
      child: Row(
        children: [
          (showSearchIcon ?? true)
              ? const Icon(
                  Icons.search,
                )
              : const SizedBox(),
          SizedBox(
            width: (showSearchIcon ?? true) ? 15 : 0,
          ),
          Expanded(
              child: TextField(
            controller: textEditingController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: searchKey.tr,
            ),
          )),
          IconButton(
              onPressed: () {
                if (textEditingController.text.trim().isNotEmpty) {
                  textEditingController.clear();

                  additionalCallback?.call();
                }
              },
              icon: const Icon(Icons.close))
        ],
      ),
    );
  }
}
