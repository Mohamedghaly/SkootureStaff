import 'package:eschool_saas_staff/cubits/teacherAcademics/teacherClassSectionDetailsCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/classListItemContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherClassSectionScreen extends StatefulWidget {
  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return BlocProvider(
      create: (context) => TeacherClassSectionDetailsCubit(),
      child: const TeacherClassSectionScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  const TeacherClassSectionScreen({super.key});

  @override
  State<TeacherClassSectionScreen> createState() =>
      _TeacherClassSectionScreenState();
}

class _TeacherClassSectionScreenState extends State<TeacherClassSectionScreen> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      getClassSectionDetails();
    });
    super.initState();
  }

  void getClassSectionDetails() async {
    context
        .read<TeacherClassSectionDetailsCubit>()
        .getTeacherClassSectionDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: BlocBuilder<TeacherClassSectionDetailsCubit,
                TeacherClassSectionDetailsState>(
              builder: (context, state) {
                if (state is TeacherClassSectionDetailsFetchSuccess) {
                  if (state.classSectionDetails.isEmpty) {
                    return const noDataContainer(titleKey: noClassSectionKey);
                  }
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                        bottom: 25,
                        top:
                            Utils.appContentTopScrollPadding(context: context) +
                                25),
                    child: Container(
                      padding: EdgeInsets.all(appContentHorizontalPadding),
                      color: Theme.of(context).colorScheme.surface,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          const CustomTextContainer(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textKey: classListKey,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ...List.generate(
                            state.classSectionDetails.length,
                            (index) => ClassListItemContainer(
                              classSectionDetails:
                                  state.classSectionDetails[index],
                              index: index,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is TeacherClassSectionDetailsFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      errorMessage: state.errorMessage,
                      onTapRetry: () {
                        getClassSectionDetails();
                      },
                    ),
                  );
                }

                return Center(
                  child: CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          const CustomAppbar(titleKey: classSectionKey),
        ],
      ),
    );
  }
}
