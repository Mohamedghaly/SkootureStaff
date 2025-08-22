import 'package:eschool_saas_staff/cubits/announcement/deleteAnnouncementCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class DeleteAnnouncementDialog extends StatelessWidget {
  final int announcementId;
  const DeleteAnnouncementDialog({super.key, required this.announcementId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const CustomTextContainer(
        textKey: areYouSureToDeleteKey,
      ),
      actions: [
        BlocConsumer<DeleteAnnouncementCubit, DeleteAnnouncementState>(
          listener: (context, state) {
            if (state is DeleteAnnouncementSuccess) {
              Get.back(result: announcementId);
              Utils.showSnackBar(
                  message: announcementDeletedSuccessfullyKey,
                  context: context);
            } else if (state is DeleteAnnouncementFailure) {
              Get.back();
              Utils.showSnackBar(message: state.errorMessage, context: context);
            }
          },
          builder: (context, state) {
            return state is DeleteAnnouncementInProgress
                ? PopScope(
                    canPop: false,
                    child: CustomCircularProgressIndicator(
                      indicatorColor: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomTextButton(
                          buttonTextKey: yesKey,
                          onTapButton: () {
                            context
                                .read<DeleteAnnouncementCubit>()
                                .deleteAnnouncement(
                                    announcementId: announcementId);
                          }),
                      const SizedBox(
                        width: 25.0,
                      ),
                      CustomTextButton(
                          buttonTextKey: noKey,
                          onTapButton: () {
                            Get.back();
                          }),
                    ],
                  );
          },
        )
      ],
    );
  }
}
