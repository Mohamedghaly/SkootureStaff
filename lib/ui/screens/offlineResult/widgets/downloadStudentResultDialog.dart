import 'package:eschool_saas_staff/cubits/exam/downloadStudentResultCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

class DownloadStudentResultDialog extends StatefulWidget {
  final int examId;
  final int childId;
  const DownloadStudentResultDialog(
      {super.key, required this.childId, required this.examId});

  @override
  State<DownloadStudentResultDialog> createState() =>
      _DownloadStudentResultDialogState();
}

class _DownloadStudentResultDialogState
    extends State<DownloadStudentResultDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<DownloadStudentResultCubit>().downloadStudentResult(
            childId: widget.childId, examId: widget.examId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DownloadStudentResultCubit, DownloadStudentResultState>(
      listener: (context, state) {
        if (state is DownloadStudentResultSuccess) {
          Get.back();
          OpenFilex.open(state.downloadedFilePath);
        } else if (state is DownloadStudentResultFailure) {
          Get.back();
          Utils.showSnackBar(context: context, message: state.errorMessage);
        }
      },
      child: AlertDialog(
        title: Row(
          children: [
            CustomCircularProgressIndicator(
              widthAndHeight: 15.0,
              strokeWidth: 2.0,
              indicatorColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10.0),
            const Flexible(
                child: CustomTextContainer(
              textKey: downloadingResultKey,
              style: TextStyle(fontSize: 15.0),
            )),
          ],
        ),
      ),
    );
  }
}
