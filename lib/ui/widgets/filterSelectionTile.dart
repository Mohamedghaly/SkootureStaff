import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/languageFlagImage.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter/material.dart';

class FilterSelectionTile extends StatelessWidget {
  final bool isSelected;
  final String title;

  /// Whether a leading flag/icon circle is shown before the title (e.g. for a
  /// language picker). Off for every other use of this shared tile.
  ///
  /// Kept separate from [leadingImageUrl] so a language whose panel has no
  /// flag set still gets the placeholder icon and stays aligned with the rows
  /// that do have one.
  final bool showLeadingImage;

  /// Url of the leading flag/icon. May be null even when [showLeadingImage] is
  /// true, in which case a placeholder icon is shown.
  final String? leadingImageUrl;

  final Function onTap;
  const FilterSelectionTile(
      {super.key,
      required this.onTap,
      required this.isSelected,
      required this.title,
      this.showLeadingImage = false,
      this.leadingImageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: () {
          onTap.call();
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding:
              EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
          alignment: Alignment.topCenter,
          child: Row(
            children: [
              if (showLeadingImage) ...[
                LanguageFlagImage(imageUrl: leadingImageUrl),
                const SizedBox(width: 12),
              ],
              Expanded(
                  child: CustomTextContainer(
                textKey: title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16.0),
              )),
              const SizedBox(
                width: 15,
              ),
              Container(
                width: 20,
                height: 20,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 1.5,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                child: isSelected
                    ? Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.secondary),
                      )
                    : const SizedBox(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
