import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/task/homeTasksCubit.dart';
import 'package:eschool_saas_staff/cubits/task/tasksCubit.dart';
import 'package:eschool_saas_staff/data/models/staffTask.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeContainer/widgets/contentTitleWithViewmoreButton.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/homeShimmerScaffold.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/teacherHomeContainer/widgets/roundedBackgroundContainer.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/teacherHomeContainer/widgets/taskCardWidget.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

/// Shows the logged-in user's tasks on the home screen (staff + teacher).
///
/// Reads from the global [HomeTasksCubit] which is pre-fetched during the
/// splash screen, so this widget renders immediately with no loading state
/// on first visit.
///
/// Hidden entirely when the API returns no tasks or an error — no empty-state
/// placeholder is shown on the home screen.
///
/// Shows at most [_maxVisibleTasks] entries; "View More" navigates to the
/// full task list.
class MyTasksContainer extends StatelessWidget {
  const MyTasksContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeTasksCubit, TasksState>(
      builder: (context, state) {
        // Hide when there is no data to display.
        if (state is TasksInitial || state is TasksFetchFailure) {
          return const SizedBox.shrink();
        }
        if (state is TasksFetchSuccess && state.tasks.isEmpty) {
          return const SizedBox.shrink();
        }

        return RoundedBackgroundContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContentTitleWithViewMoreButton(
                contentTitleKey: myTaskKey,
                showViewMoreButton: true,
                viewMoreOnTap: () => Get.toNamed(Routes.myTasksScreen),
              ),
              const SizedBox(height: 8),
              if (state is TasksFetchInProgress)
                const MyTasksShimmer()
              else if (state is TasksFetchSuccess)
                _TaskList(
                  tasks: state.tasks.length > _maxVisibleTasks
                      ? state.tasks.sublist(0, _maxVisibleTasks)
                      : state.tasks,
                ),
            ],
          ),
        );
      },
    );
  }
}

const int _maxVisibleTasks = 2;

class _TaskList extends StatelessWidget {
  final List<StaffTask> tasks;

  const _TaskList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => TaskCardWidget(
        task: tasks[index],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
