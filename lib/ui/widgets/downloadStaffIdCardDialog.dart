import 'package:eschool_saas_staff/cubits/staff/downloadStaffIdCardCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';
import 'package:open_filex/open_filex.dart';

class DownloadStaffIdCardDialog extends StatefulWidget {
  const DownloadStaffIdCardDialog({super.key});

  @override
  State<DownloadStaffIdCardDialog> createState() =>
      _DownloadStaffIdCardDialogState();
}

class _DownloadStaffIdCardDialogState extends State<DownloadStaffIdCardDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<DownloadStaffIdCardCubit>().downloadStaffIdCard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DownloadStaffIdCardCubit, DownloadStaffIdCardState>(
      listener: (context, state) {
        if (state is DownloadStaffIdCardSuccess) {
          Get.back();
          OpenFilex.open(state.downloadedFilePath);
        } else if (state is DownloadStaffIdCardFailure) {
          Get.back();
          Utils.showSnackBar(
            message: state.errorMessage,
            context: context,
          );
        }
      },
      child: AlertDialog(
        content: SizedBox(
          height: 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomCircularProgressIndicator(
                widthAndHeight: 15.0,
                strokeWidth: 2.0,
                indicatorColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10.0),
              const Flexible(
                child: CustomTextContainer(
                  textKey: downloadingIdCardKey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
