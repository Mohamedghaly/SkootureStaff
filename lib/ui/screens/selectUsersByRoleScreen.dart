import 'dart:async';

import 'package:eschool_saas_staff/cubits/academics/usersByRoleCubit.dart';
import 'package:eschool_saas_staff/data/models/userDetails.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/searchContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class SelectUsersByRoleScreen extends StatefulWidget {
  final List<UserDetails> selectedUsers;
  final List<String> roles;
  final String? type;

  const SelectUsersByRoleScreen({
    super.key,
    required this.selectedUsers,
    required this.roles,
    this.type,
  });

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return BlocProvider(
      create: (context) => UsersByRoleCubit(),
      child: SelectUsersByRoleScreen(
        selectedUsers: arguments['selectedUsers'] as List<UserDetails>,
        roles: arguments['roles'] as List<String>,
        type: arguments['type'] as String?,
      ),
    );
  }

  static Map<String, dynamic> buildArguments({
    required List<UserDetails> selectedUsers,
    required List<String> roles,
    String? type,
  }) {
    return {
      "selectedUsers": List<UserDetails>.from(selectedUsers),
      "roles": List<String>.from(roles),
      "type": type,
    };
  }

  @override
  State<SelectUsersByRoleScreen> createState() =>
      _SelectUsersByRoleScreenState();
}

class _SelectUsersByRoleScreenState extends State<SelectUsersByRoleScreen> {
  late final List<UserDetails> _selectedUsers =
      List<UserDetails>.from(widget.selectedUsers);
  late final TextEditingController _searchTextEditingController =
      TextEditingController()..addListener(searchQueryTextControllerListener);

  late int waitForNextRequestSearchQueryTimeInMilliSeconds =
      nextSearchRequestQueryTimeInMilliSeconds;

  Timer? waitForNextSearchRequestTimer;

  late final ScrollController _scrollController = ScrollController()
    ..addListener(scrollListener);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        fetchUsers();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    _searchTextEditingController
        .removeListener(searchQueryTextControllerListener);
    _searchTextEditingController.dispose();
    waitForNextSearchRequestTimer?.cancel();
    super.dispose();
  }

  void scrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<UsersByRoleCubit>().hasMore()) {
        fetchMoreUsers();
      }
    }
  }

  void fetchUsers() {
    final searchQuery = _searchTextEditingController.text.trim();
    context.read<UsersByRoleCubit>().getUsersByRole(
        roles: widget.roles, search: searchQuery, type: widget.type);
  }

  void fetchMoreUsers() {
    final searchQuery = _searchTextEditingController.text.trim();
    context
        .read<UsersByRoleCubit>()
        .fetchMore(roles: widget.roles, search: searchQuery, type: widget.type);
  }

  void searchQueryTextControllerListener() {
    waitForNextSearchRequestTimer?.cancel();
    setWaitForNextSearchRequestTimer();
  }

  void setWaitForNextSearchRequestTimer() {
    if (waitForNextRequestSearchQueryTimeInMilliSeconds !=
        (waitForNextRequestSearchQueryTimeInMilliSeconds -
            searchRequestPerodicMilliSeconds)) {
      waitForNextRequestSearchQueryTimeInMilliSeconds =
          (nextSearchRequestQueryTimeInMilliSeconds -
              searchRequestPerodicMilliSeconds);
    }

    waitForNextSearchRequestTimer = Timer.periodic(
        Duration(milliseconds: searchRequestPerodicMilliSeconds), (timer) {
      if (waitForNextRequestSearchQueryTimeInMilliSeconds == 0) {
        timer.cancel();
        // Trigger new API call with search query
        fetchUsers();
      } else {
        waitForNextRequestSearchQueryTimeInMilliSeconds =
            waitForNextRequestSearchQueryTimeInMilliSeconds -
                searchRequestPerodicMilliSeconds;
      }
    });
  }

  Widget _buildSearchUsersTextContainer() {
    return const Center(
      child: CustomTextContainer(
        textKey: selectUsersKey,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.0,
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return BlocBuilder<UsersByRoleCubit, UsersByRoleState>(
        builder: (context, state) {
      if (state is UsersByRoleSuccess) {
        final displayUsers = state.users;

        if (displayUsers.isEmpty) {
          return const Center(
            child: CustomTextContainer(
              textKey: "No users found",
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
            controller: _scrollController,
            itemCount: displayUsers.length +
                (context.read<UsersByRoleCubit>().hasMore() ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator for pagination
              if (index == displayUsers.length) {
                if (state.fetchMoreError) {
                  return Center(
                    child: CustomTextButton(
                        buttonTextKey: retryKey,
                        onTapButton: () {
                          fetchMoreUsers();
                        }),
                  );
                }

                return Center(
                  child: CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              }

              final userDetails = displayUsers[index];

              final isSelected = _selectedUsers
                      .indexWhere((element) => element.id == userDetails.id) !=
                  -1;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 7.5),
                child: ListTile(
                  onTap: () {
                    if (isSelected) {
                      _selectedUsers.removeWhere(
                          (element) => element.id == userDetails.id);
                    } else {
                      _selectedUsers.add(userDetails);
                    }
                    setState(() {});
                  },
                  subtitle:
                      CustomTextContainer(textKey: userDetails.getRoles()),
                  tileColor: Theme.of(context).colorScheme.surface,
                  title:
                      CustomTextContainer(textKey: userDetails.fullName ?? "-"),
                  trailing: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).colorScheme.primary)),
                    width: 22.5,
                    height: 22.5,
                    alignment: Alignment.center,
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 17.5,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : const SizedBox(),
                  ),
                ),
              );
            });
      }

      if (state is UsersByRoleFailure) {
        return Center(
          child: ErrorContainer(
            errorMessage: state.errorMessage,
            onTapRetry: () {
              fetchUsers();
            },
          ),
        );
      }

      if (state is UsersByRoleInitial) {
        return _buildSearchUsersTextContainer();
      }

      return Center(
        child: CustomCircularProgressIndicator(
          indicatorColor: Theme.of(context).colorScheme.primary,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        Get.back(result: _selectedUsers);
      },
      child: Scaffold(
          appBar: AppBar(
            leadingWidth: 40,
            // Remove scrolled under state to prevent color change
            scrolledUnderElevation: 0,
            // Set fixed background color
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            // Set fixed surface tint color to prevent color change
            surfaceTintColor: Colors.transparent,
            title: SearchContainer(
              showSearchIcon: false,
              padding: const EdgeInsets.all(5.0),
              margin: const EdgeInsets.all(0),
              textEditingController: _searchTextEditingController,
            ),
            leading: IconButton(
                onPressed: () {
                  Get.back(result: _selectedUsers);
                },
                icon: const Icon(Icons.arrow_back)),
          ),
          body: _buildUsersList()),
    );
  }
}
