import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomImageWidget extends StatelessWidget {
  final bool isFile;
  final bool isAsset;
  final String imagePath;
  final BoxFit boxFit;
  final Widget? customLoadingPlaceholder;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;
  final ImageWidgetBuilder? imageBuilder;
  final LoadingErrorWidgetBuilder? errorWidget;
  const CustomImageWidget(
      {super.key,
      this.isFile = false,
      this.isAsset = false,
      required this.imagePath,
      this.boxFit = BoxFit.cover,
      this.customLoadingPlaceholder,
      this.progressIndicatorBuilder,
      this.imageBuilder,
      this.errorWidget});

  @override
  Widget build(BuildContext context) {
    return !isFile && !isAsset //it's network in that case
        ? imagePath.toLowerCase().endsWith("svg")
            ? SvgPicture.network(
                imagePath,
                fit: boxFit,
              )
            : CachedNetworkImage(
                errorWidget: errorWidget ??
                    (context, image, _) => const SizedBox.shrink(),
                imageUrl: imagePath,
                memCacheHeight: 500,
                memCacheWidth: 500,
                fit: boxFit,
                placeholder: progressIndicatorBuilder != null
                    ? null
                    : (context, url) =>
                        customLoadingPlaceholder ??
                        Center(
                          child: CustomCircularProgressIndicator(
                            indicatorColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                progressIndicatorBuilder: progressIndicatorBuilder,
                imageBuilder: imageBuilder,
              )
        : isAsset
            ? imagePath.toLowerCase().endsWith("svg")
                ? SvgPicture.asset(
                    imagePath,
                    fit: boxFit,
                  )
                : Image.asset(
                    imagePath,
                    fit: boxFit,
                  )
            : imagePath.toLowerCase().endsWith("svg")
                ? SvgPicture.file(
                    File(imagePath),
                    fit: boxFit,
                  )
                : Image.file(
                    File(imagePath),
                    fit: boxFit,
                  );
  }
}
