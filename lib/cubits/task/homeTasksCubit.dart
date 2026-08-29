import 'package:eschool_saas_staff/cubits/task/tasksCubit.dart';

/// Global cubit that holds the "My Tasks" list shown on the home screen.
///
/// Kept alive at app level so splash can prefetch and home renders instantly.
/// All API behaviour is inherited from [TasksCubit].
class HomeTasksCubit extends TasksCubit {}
