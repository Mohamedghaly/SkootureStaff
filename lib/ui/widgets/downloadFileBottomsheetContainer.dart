import 'package:eschool_saas_staff/cubits/downloadFileCubit.dart';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/ui/widgets/customBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class DownloadFileBottomsheetContainer extends StatefulWidget {
  final StudyMaterial studyMaterial;
  const DownloadFileBottomsheetContainer({
    super.key,
    required this.studyMaterial,
  });

  @override
  State<DownloadFileBottomsheetContainer> createState() =>
      _DownloadFileBottomsheetContainerState();
}

class _DownloadFileBottomsheetContainerState
    extends State<DownloadFileBottomsheetContainer> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<DownloadFileCubit>().downloadFile(
              studyMaterial: widget.studyMaterial,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (context.read<DownloadFileCubit>().state is DownloadFileInProgress) {
          context.read<DownloadFileCubit>().cancelDownloadProcess();
        }
      },
      child: CustomBottomsheet(
        titleLabelKey: fileDownloadingKey,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: appContentHorizontalPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 15,
              ),
              CustomTextContainer(
                textKey: widget.studyMaterial.fileName,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 25),
              BlocConsumer<DownloadFileCubit, DownloadFileState>(
                listener: (context, state) {
                  if (state is DownloadFileSuccess) {
                    Get.back(result: {
                      "error": false,
                      "filePath": state.downloadedFileUrl
                    });
                  } else if (state is DownloadFileFailure) {
                    Get.back(result: {
                      "error": true,
                      "message": Utils.getTranslatedLabel(state.errorMessage)
                    });
                  }
                },
                builder: (context, state) {
                  if (state is DownloadFileInProgress) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 6,
                          child: LayoutBuilder(
                            builder: (context, boxConstraints) {
                              return Stack(
                                children: [
                                  Utils.buildProgressContainer(
                                    width: boxConstraints.maxWidth,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                  Utils.buildProgressContainer(
                                    width: boxConstraints.maxWidth *
                                        state.uploadedPercentage *
                                        0.01,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomTextContainer(
                          textKey:
                              "${state.uploadedPercentage.toStringAsFixed(2)} %",
                        )
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 25),
              CustomRoundedButton(
                onTap: () {
                  context.read<DownloadFileCubit>().cancelDownloadProcess();
                  Get.back();
                },
                textSize: 16.0,
                widthPercentage: 0.35,
                titleColor: Theme.of(context).scaffoldBackgroundColor,
                backgroundColor: Theme.of(context).colorScheme.primary,
                buttonTitle: Utils.getTranslatedLabel(cancelKey),
                showBorder: false,
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
