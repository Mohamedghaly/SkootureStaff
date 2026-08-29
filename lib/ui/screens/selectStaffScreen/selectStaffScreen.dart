import 'dart:async';

import 'package:eschool_saas_staff/cubits/rolesCubit.dart';
import 'package:eschool_saas_staff/cubits/task/usersRoleWiseCubit.dart';
import 'package:eschool_saas_staff/data/models/staffMember.dart';
import 'package:eschool_saas_staff/ui/screens/selectStaffScreen/widgets/staffCard.dart';
import 'package:eschool_saas_staff/ui/screens/selectStaffScreen/widgets/staffRoleFilterBar.dart';
import 'package:eschool_saas_staff/ui/screens/selectStaffScreen/widgets/staffSearchBar.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class SelectStaffScreen extends StatefulWidget {
  const SelectStaffScreen._();

  static Widget getRouteInstance() => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => RolesCubit()..getRoles(),
          ),
          // Do NOT auto-fetch users here. The screen triggers the user fetch
          // only after roles have loaded so both loaders never show at once.
          BlocProvider(
            create: (_) => UsersRoleWiseCubit(),
          ),
        ],
        child: const SelectStaffScreen._(),
      );

  /// Build arguments for navigation.
  static Map<String, dynamic> buildArguments({
    StaffMember? preselected,
  }) {
    return {
      'preselected': preselected,
    };
  }

  @override
  State<SelectStaffScreen> createState() => _SelectStaffScreenState();
}

class _SelectStaffScreenState extends State<SelectStaffScreen> {
  final _searchController = TextEditingController();
  String? _selectedRole;
  String _searchQuery = '';

  /// Currently selected staff member. Null means no selection.
  StaffMember? _selectedStaff;

  /// Debounce timer for search to avoid excessive API calls.
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _selectedStaff = args?['preselected'] as StaffMember?;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  /// Triggers a fresh API call with current role + search filters.
  void _fetchUsers() {
    context.read<UsersRoleWiseCubit>().getUsers(
          roleName: _selectedRole,
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
        );
  }

  void _onRoleSelected(String? role) {
    setState(() => _selectedRole = role);
    _fetchUsers();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
      () {
        setState(() => _searchQuery = query);
        _fetchUsers();
      },
    );
  }

  void _onStaffTapped(StaffMember staff) {
    setState(() {
      // Toggle: tap selected staff to deselect, tap another to switch.
      _selectedStaff = _selectedStaff?.id == staff.id ? null : staff;
    });
  }

  void _onConfirm() {
    Get.back(result: _selectedStaff);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocConsumer<RolesCubit, RolesState>(
        listener: (context, state) {
          // Roles are ready — now it's safe to load users.
          // This fires exactly once per screen open (or on retry),
          // ensuring only one loader is visible at any given time.
          if (state is RolesFetchSuccess) {
            _fetchUsers();
          }
        },
        builder: (context, rolesState) {
          // While roles are loading, show a single full-screen loader.
          // The user list has NOT started fetching yet, so there is only
          // one progress indicator visible on screen.
          if (rolesState is RolesFetchInProgress ||
              rolesState is RolesInitial) {
            return Column(
              children: [
                const CustomAppbar(titleKey: selectStaffKey),
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }

          // Roles failed — show appbar + error message in the body.
          if (rolesState is RolesFetchFailure) {
            return Column(
              children: [
                const CustomAppbar(titleKey: selectStaffKey),
                Expanded(
                  child: Center(child: Text(rolesState.errorMessage)),
                ),
              ],
            );
          }

          // Roles loaded — render the full layout.
          // The user list has its own loader for this phase.
          final roleNames = rolesState is RolesFetchSuccess
              ? rolesState.roles
                  .map((r) => r.name ?? '')
                  .where((name) => name.isNotEmpty)
                  .toList()
              : <String>[];

          return Column(
            children: [
              const CustomAppbar(titleKey: selectStaffKey),

              // Role filter chips
              StaffRoleFilterBar(
                selectedRole: _selectedRole,
                roles: roleNames,
                onRoleSelected: _onRoleSelected,
              ),

              // Search bar
              StaffSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
              ),

              // User list
              Expanded(
                child: _UserListSection(
                  selectedId: _selectedStaff?.id,
                  onStaffTapped: _onStaffTapped,
                  selectedRole: _selectedRole,
                  searchQuery: _searchQuery,
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _ConfirmButton(onTap: _onConfirm),
    );
  }
}

// ─── User List Section ─────────────────────────────────────

class _UserListSection extends StatelessWidget {
  final int? selectedId;
  final ValueChanged<StaffMember> onStaffTapped;
  final String? selectedRole;
  final String searchQuery;

  const _UserListSection({
    required this.selectedId,
    required this.onStaffTapped,
    required this.selectedRole,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersRoleWiseCubit, UsersRoleWiseState>(
      builder: (context, state) {
        if (state is UsersRoleWiseFetchInProgress) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is UsersRoleWiseFetchFailure) {
          return Center(child: Text(state.errorMessage));
        }

        if (state is UsersRoleWiseFetchSuccess) {
          if (state.users.isEmpty) {
            return noDataContainer(
              titleKey: noDataFoundKey,
            );
          }

          return _PaginatedUserList(
            users: state.users,
            selectedId: selectedId,
            onStaffTapped: onStaffTapped,
            hasMore: context.read<UsersRoleWiseCubit>().hasMore(),
            fetchMoreInProgress: state.fetchMoreInProgress,
            onFetchMore: () {
              context.read<UsersRoleWiseCubit>().fetchMore(
                    roleName: selectedRole,
                    search: searchQuery.isNotEmpty ? searchQuery : null,
                  );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Paginated User List ──────────────────────────────────

class _PaginatedUserList extends StatelessWidget {
  final List<StaffMember> users;
  final int? selectedId;
  final ValueChanged<StaffMember> onStaffTapped;
  final bool hasMore;
  final bool fetchMoreInProgress;
  final VoidCallback onFetchMore;

  const _PaginatedUserList({
    required this.users,
    required this.selectedId,
    required this.onStaffTapped,
    required this.hasMore,
    required this.fetchMoreInProgress,
    required this.onFetchMore,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = fetchMoreInProgress ? users.length + 1 : users.length;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 100 &&
            hasMore &&
            !fetchMoreInProgress) {
          onFetchMore();
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          // Loading indicator for pagination.
          if (index >= users.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final staff = users[index];
          return StaffCard(
            staff: staff,
            isSelected: selectedId == staff.id,
            onTap: () => onStaffTapped(staff),
          );
        },
      ),
    );
  }
}

// ─── Confirm Button ────────────────────────────────────────

class _ConfirmButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ConfirmButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1C1D).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: double.maxFinite,
          height: 40,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 20 / 14,
              ),
              elevation: 0,
            ),
            child: Text(
              Utils.getTranslatedLabel(confirmKey),
            ),
          ),
        ),
      ),
    );
  }
}
