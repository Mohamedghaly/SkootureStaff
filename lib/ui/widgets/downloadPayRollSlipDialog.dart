import 'package:eschool_saas_staff/cubits/payRoll/downloadPayRollSlipCubit.dart';
import 'package:eschool_saas_staff/data/models/payRoll.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';
import 'package:open_filex/open_filex.dart';

class DownloadPayRollSlipDialog extends StatefulWidget {
  final PayRoll payRoll;
  const DownloadPayRollSlipDialog({super.key, required this.payRoll});

  @override
  State<DownloadPayRollSlipDialog> createState() =>
      _DownloadPayRollSlipDialogState();
}

class _DownloadPayRollSlipDialogState extends State<DownloadPayRollSlipDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<DownloadPayRollSlipCubit>().downloadPayRollSlip(
            payRollId: widget.payRoll.id ?? 0,
            payRollSlipTitle: widget.payRoll.title ?? "-");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DownloadPayRollSlipCubit, DownloadPayRollSlipState>(
      listener: (context, state) {
        if (state is DownloadPayRollSlipSuccess) {
          Get.back();
          OpenFilex.open(state.downloadedFilePath);
        } else if (state is DownloadPayRollSlipFailure) {
          Get.back();
          Utils.showSnackBar(message: state.errorMessage, context: context);
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
                  child:
                      CustomTextContainer(textKey: downloadingSalarySlipKey)),
            ],
          ),
        ),
      ),
    );
  }
}
