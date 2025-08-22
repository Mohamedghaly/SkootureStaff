import 'dart:async';

import 'package:eschool_saas_staff/cubits/academics/searchUsersCubit.dart';
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

class SearchUsersScreen extends StatefulWidget {
  final List<UserDetails> selectedUsers;
  const SearchUsersScreen({super.key, required this.selectedUsers});

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return BlocProvider(
      create: (context) => SearchUsersCubit(),
      child: SearchUsersScreen(
        selectedUsers: arguments['selectedUsers'] as List<UserDetails>,
      ),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required List<UserDetails> selectedUsers}) {
    return {"selectedUsers": List<UserDetails>.from(selectedUsers)};
  }

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  late final List<UserDetails> _selectedUsers =
      List<UserDetails>.from(widget.selectedUsers);
  late final TextEditingController _textEditingController =
      TextEditingController()..addListener(searchQueryTextControllerListener);

  late int waitForNextRequestSearchQueryTimeInMilliSeconds =
      nextSearchRequestQueryTimeInMilliSeconds;

  Timer? waitForNextSearchRequestTimer;

  late final ScrollController _scrollController = ScrollController()
    ..addListener(scrollListener);

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    _textEditingController.removeListener(searchQueryTextControllerListener);
    _textEditingController.dispose();
    waitForNextSearchRequestTimer?.cancel();
    super.dispose();
  }

  void scrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<SearchUsersCubit>().hasMore()) {
        fetchMoreUsers();
      }
    }
  }

  void searchUsers() {
    context
        .read<SearchUsersCubit>()
        .searchUsers(search: _textEditingController.text.trim());
  }

  void fetchMoreUsers() {
    context
        .read<SearchUsersCubit>()
        .fetchMore(search: _textEditingController.text.trim());
  }

  void searchQueryTextControllerListener() {
    if (_textEditingController.text.trim().isEmpty) {
      return;
    }
    waitForNextSearchRequestTimer?.cancel();
    setWaitForNextSearchRequestTimer();
  }

  void setWaitForNextSearchRequestTimer() {
    if (waitForNextRequestSearchQueryTimeInMilliSeconds !=
        (waitForNextRequestSearchQueryTimeInMilliSeconds -
            searchRequestPerodicMilliSeconds)) {
      //
      waitForNextRequestSearchQueryTimeInMilliSeconds =
          (nextSearchRequestQueryTimeInMilliSeconds -
              searchRequestPerodicMilliSeconds);
    }
    //
    waitForNextSearchRequestTimer = Timer.periodic(
        Duration(milliseconds: searchRequestPerodicMilliSeconds), (timer) {
      if (waitForNextRequestSearchQueryTimeInMilliSeconds == 0) {
        timer.cancel();
        searchUsers();
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
        textKey: searchUsersKey,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.0,
        ),
      ),
    );
  }

  Widget _buildSearchedResult() {
    return BlocBuilder<SearchUsersCubit, SearchUsersState>(
        builder: (context, state) {
      if (state is SearchUsersSuccess) {
        return ListView.builder(
            controller: _scrollController,
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              if (context.read<SearchUsersCubit>().hasMore()) {
                if (index == (state.users.length - 1)) {
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
              }

              final userDetails = state.users[index];

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

      if (state is SearchUsersFailure) {
        return Center(
          child: ErrorContainer(
            errorMessage: state.errorMessage,
            onTapRetry: () {
              searchUsers();
            },
          ),
        );
      }
      if (state is SearchUsersInitial) {
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
            title: SearchContainer(
              showSearchIcon: false,
              padding: const EdgeInsets.all(5.0),
              margin: const EdgeInsets.all(0),
              textEditingController: _textEditingController,
            ),
            leading: IconButton(
                onPressed: () {
                  Get.back(result: _selectedUsers);
                },
                icon: const Icon(Icons.arrow_back)),
          ),
          body: _buildSearchedResult()),
    );
  }
}
