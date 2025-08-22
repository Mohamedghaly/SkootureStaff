import 'package:eschool_saas_staff/data/models/role.dart';
import 'package:eschool_saas_staff/data/repositories/academicRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class RolesState {}

class RolesInitial extends RolesState {}

class RolesFetchInProgress extends RolesState {}

class RolesFetchSuccess extends RolesState {
  final List<Role> roles;

  RolesFetchSuccess({required this.roles});
}

class RolesFetchFailure extends RolesState {
  final String errorMessage;

  RolesFetchFailure(this.errorMessage);
}

class RolesCubit extends Cubit<RolesState> {
  final AcademicRepository _academicRepository = AcademicRepository();

  RolesCubit() : super(RolesInitial());

  void getRoles() async {
    try {
      emit(RolesFetchInProgress());
      emit(RolesFetchSuccess(roles: await _academicRepository.getRoles()));
    } catch (e) {
      emit(RolesFetchFailure(e.toString()));
    }
  }
}
