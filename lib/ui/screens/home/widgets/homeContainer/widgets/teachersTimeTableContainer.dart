import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/homeScreenDataCubit.dart';
import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/ui/screens/teacherTimeTableDetailsScreen.dart';
import 'package:eschool_saas_staff/ui/screens/teachersScreen.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/profileImageContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class TeachersTimeTableContainer extends StatelessWidget {
  const TeachersTimeTableContainer({super.key});

  Widget _buildTeacherDetailsContainer(
      {required double width,
      required BuildContext context,
      required UserDetails teacher}) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.teacherTimeTableDetailsScreen,
            arguments: TeacherTimeTableDetailsScreen.buildArguments(
                teacherDetails: teacher));
      },
      child: Container(
        width: width,
        height: 110,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: BorderRadius.circular(8.0),
            color: Theme.of(context).colorScheme.surface),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileImageContainer(
              imageUrl: teacher.image ?? "",
              heightAndWidth: 50,
            ),
            const Spacer(),
            CustomTextContainer(
              textKey: teacher.fullName ?? "",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<UserDetails> teachers =
        context.read<HomeScreenDataCubit>().getTeachers();

    teachers = teachers.length > 4 ? teachers.sublist(0, 4) : teachers;

    return teachers.isEmpty
        ? const SizedBox()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: appContentHorizontalPadding),
                    child: Text(
                      "Teachers Timetable",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(Routes.teachersScreen,
                          arguments: TeachersScreen.buildArguments(
                              teacherNavigationType:
                                  TeacherNavigationType.timetable));
                    },
                    child: Text(
                      "View More",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Teacher List
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: appContentHorizontalPadding),
                child: LayoutBuilder(builder: (context, boxConstraints) {
                  return Wrap(
                    alignment: WrapAlignment.start,
                    spacing: boxConstraints.maxWidth * 0.04,
                    runSpacing: 15,
                    children: teachers
                        .map(
                          (teacher) => _buildTeacherDetailsContainer(
                              teacher: teacher,
                              width: boxConstraints.maxWidth * 0.48,
                              context: context),
                        )
                        .toList(),
                  );
                }),
              ),
            ],
          );
  }
}
