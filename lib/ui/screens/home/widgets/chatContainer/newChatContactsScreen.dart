import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/academics/classesCubit.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/chat/chatUsersCubit.dart';
import 'package:eschool_saas_staff/cubits/chat/staffChatUsersCubit.dart';
import 'package:eschool_saas_staff/cubits/studentsByClassSectionCubit.dart';
import 'package:eschool_saas_staff/data/models/chatUserRole.dart';
import 'package:eschool_saas_staff/data/models/classSection.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/chatContainer/chatScreen.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTabContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/filterButton.dart';
import 'package:eschool_saas_staff/ui/widgets/filterSelectionBottomsheet.dart';
import 'package:eschool_saas_staff/ui/widgets/tabBackgroundContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class NewChatContactsScreen extends StatefulWidget {
  const NewChatContactsScreen({super.key});

  @override
  State<NewChatContactsScreen> createState() => _NewChatContactsScreenState();

  static Widget getRouteInstance() {
    // final arguments = Get.arguments as Map<String,dynamic>;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ChatUsersCubit()),
        BlocProvider(create: (_) => StaffChatUsersCubit()),
        BlocProvider(create: (_) => ClassesCubit()),
        BlocProvider(create: (_) => StudentsByClassSectionCubit()),
      ],
      child: const NewChatContactsScreen(),
    );
  }
}

class _NewChatContactsScreenState extends State<NewChatContactsScreen>
    with AutomaticKeepAliveClientMixin {
  final tabTitles = [studentsKey, parentsKey, staffsKey];
  late String selectedTabTitleKey = tabTitles.first;

  ClassSection? _selectedClassSection;

  final _parentScrollController = ScrollController();
  final _studentsSearchController = TextEditingController();
  final _parentsSearchController = TextEditingController();
  final _staffsSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (!context.read<AuthCubit>().isTeacher()) {
      tabTitles.remove(studentsKey);
    }

    context.read<ClassesCubit>().getClasses();
    _parentScrollController.addListener(_onParentScrollListener);
  }

  @override
  void dispose() {
    _parentScrollController.removeListener(_onParentScrollListener);
    _parentScrollController.dispose();
    _studentsSearchController.dispose();
    _parentsSearchController.dispose();
    _staffsSearchController.dispose();
    super.dispose();
  }

  void _onParentScrollListener() {
    if (_parentScrollController.position.maxScrollExtent ==
        _parentScrollController.offset) {
      if (context.read<ChatUsersCubit>().hasMore) {
        context.read<ChatUsersCubit>().fetchMoreChatUsers(
              role: ChatUserRole.guardian,
              classSectionId: (_selectedClassSection?.id ?? 0).toString(),
            );
      }
    }
  }

  void changeSelectedClassSection(ClassSection? classSection) {
    if (_selectedClassSection != classSection) {
      _selectedClassSection = classSection;
      setState(() {});
      getStudents();
      getParents();
      getStaffs();
    }
  }

  void getStudents() {
    context.read<StudentsByClassSectionCubit>().fetchStudents(
          status: StudentListStatus.all,
          classSectionId: _selectedClassSection?.id ?? 0,
        );
  }

  void getParents() {
    context.read<ChatUsersCubit>().fetchChatUsers(
          role: ChatUserRole.guardian,
          classSectionId: (_selectedClassSection?.id ?? 0).toString(),
        );
  }

  void getStaffs() {
    context.read<StaffChatUsersCubit>().fetchChatUsers(
          role: ChatUserRole.staff,
          classSectionId: (_selectedClassSection?.id ?? 0).toString(),
        );
  }

  void _clearAllSearchControllers() {
    _studentsSearchController.clear();
    _parentsSearchController.clear();
    _staffsSearchController.clear();
  }

  void _resetAllSearchStates() {
    // Reset search states in all cubits
    context.read<StudentsByClassSectionCubit>().clearSearch();
    context.read<ChatUsersCubit>().clearSearch();
    context.read<StaffChatUsersCubit>().clearSearch();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppbar(),
            Flexible(
              child: switch (selectedTabTitleKey) {
                studentsKey => _buildStudentsList(),
                parentsKey => _buildParentsList(),
                staffsKey => _buildStaffsList(),
                _ => throw Exception("Invalid tab title key"),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppbar() {
    void changeTab(String value) {
      // Clear search controllers and reset search state when switching tabs
      _clearAllSearchControllers();
      _resetAllSearchStates();

      setState(() {
        selectedTabTitleKey = value;
      });
    }

    return BlocConsumer<ClassesCubit, ClassesState>(
      listener: (context, state) {
        if (_selectedClassSection == null) {
          changeSelectedClassSection(
            context.read<ClassesCubit>().getAllClasses().firstOrNull,
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            CustomAppbar(titleKey: Utils.getTranslatedLabel("contacts")),
            TabBackgroundContainer(
              child: LayoutBuilder(
                builder: (context, constraints) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: tabTitles
                      .map(
                        (tab) => CustomTabContainer(
                          titleKey: tab,
                          isSelected: tab == selectedTabTitleKey,
                          width: constraints.maxWidth *
                              ((1 / tabTitles.length) - .01),
                          onTap: changeTab,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            selectedTabTitleKey == staffsKey
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                Utils.getTranslatedLabel(classKey),
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              FilterButton(
                                onTap: () {
                                  if (state is ClassesFetchSuccess &&
                                      context
                                          .read<ClassesCubit>()
                                          .getAllClasses()
                                          .isNotEmpty) {
                                    Utils.showBottomSheet(
                                      child: FilterSelectionBottomsheet<
                                          ClassSection>(
                                        onSelection: (value) {
                                          changeSelectedClassSection(value!);
                                          Get.back();
                                        },
                                        selectedValue: _selectedClassSection!,
                                        titleKey: classKey,
                                        values: context
                                            .read<ClassesCubit>()
                                            .getAllClasses(),
                                      ),
                                      context: context,
                                    );
                                  }
                                },
                                titleKey: _selectedClassSection?.id == null
                                    ? classKey
                                    : (_selectedClassSection?.fullName ?? ""),
                                width: constraints.maxWidth * (0.48),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar({
    required bool showingSearch,
    required void Function(String) onSubmitted,
    required VoidCallback onCleared,
    required TextEditingController searchController,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SearchAnchor(
        builder: (context, controller) => SearchBar(
          controller: searchController,
          onSubmitted: (search) {
            if (search.trim().isEmpty) return;

            onSubmitted(search);
          },
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.surface,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(
                width: 1,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.1),
              ),
            ),
          ),
          hintText: Utils.getTranslatedLabel("search"),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16),
          ),
          trailing: [
            IconButton(
              onPressed: () {
                if (searchController.text.trim().isEmpty) {
                  return;
                }

                if (showingSearch) {
                  onSubmitted(searchController.text.trim());
                } else {
                  searchController.clear();
                  onCleared();
                }
              },
              icon: Icon(
                showingSearch ? Icons.search_rounded : Icons.clear_rounded,
              ),
            ),
          ],
        ),
        suggestionsBuilder: (_, __) => [const SizedBox.shrink()],
      ),
    );
  }

  Widget _buildStudentsList() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child:
          BlocBuilder<StudentsByClassSectionCubit, StudentsByClassSectionState>(
        builder: (context, state) {
          if (state is StudentsByClassSectionFetchSuccess) {
            if (state.studentDetailsList.isEmpty) {
              return Center(
                child: Text(
                  Utils.getTranslatedLabel("noStudentsFound"),
                  style: const TextStyle(fontSize: 20.0),
                ),
              );
            }

            return Column(
              children: [
                _buildSearchBar(
                  showingSearch: state.searchStatus ==
                      StudentByClassSectionSearchStatus.initial,
                  onSubmitted: (search) {
                    context.read<StudentsByClassSectionCubit>().searchStudents(
                          status: StudentListStatus.all,
                          classSectionId: _selectedClassSection?.id ?? 0,
                          search: search,
                        );
                  },
                  onCleared: () {
                    context.read<StudentsByClassSectionCubit>().clearSearch();
                  },
                  searchController: _studentsSearchController,
                ),

                ///
                state.searchStatus == StudentByClassSectionSearchStatus.loading
                    ? Center(
                        child: CustomCircularProgressIndicator(
                          indicatorColor: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : Expanded(
                        child: state.searchStatus ==
                                    StudentByClassSectionSearchStatus.success &&
                                state.searchedStudentDetailsList!.isEmpty
                            ? Center(
                                child: Text(
                                  Utils.getTranslatedLabel(
                                      "No search results found"),
                                  style: const TextStyle(fontSize: 20.0),
                                ),
                              )
                            : ListView.builder(
                                itemCount: state.searchStatus ==
                                        StudentByClassSectionSearchStatus
                                            .initial
                                    ? state.studentDetailsList.length
                                    : state.searchedStudentDetailsList!.length,
                                padding: EdgeInsets.zero,
                                itemBuilder: (_, idx) {
                                  final student = state.searchStatus ==
                                          StudentByClassSectionSearchStatus
                                              .initial
                                      ? state.studentDetailsList[idx]
                                      : state.searchedStudentDetailsList![idx];

                                  return InkWell(
                                    onTap: () {
                                      Get.toNamed(
                                        Routes.chatScreen,
                                        arguments: ChatScreen.buildArguments(
                                          receiverId: student.id ?? 0,
                                          receiverName: student.fullName ?? "",
                                          receiverImage: student.image ?? "",
                                          classSection: student.student
                                                  ?.classSection?.fullName ??
                                              "",
                                        ),
                                      );
                                    },
                                    child: _buildCard(
                                      student.fullName ?? "",
                                      student.image ?? "",
                                    ),
                                  );
                                },
                              ),
                      ),
              ],
            );
          }

          if (state is StudentsByClassSectionFetchFailure) {
            return ErrorContainer(
              errorMessage: state.errorMessage,
              onTapRetry: getStudents,
            );
          }

          return Center(
            child: CustomCircularProgressIndicator(
              indicatorColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildParentsList() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: BlocBuilder<ChatUsersCubit, ChatUsersState>(
        builder: (context, state) {
          if (state.status == ChatUsersFetchStatus.failure) {
            return ErrorContainer(
              errorMessage: state.errorMessage!,
              onTapRetry: getParents,
            );
          }

          if (state.status == ChatUsersFetchStatus.success) {
            if (state.chatUsersResponse!.chatUsers.isEmpty) {
              return Center(
                child: Text(
                  Utils.getTranslatedLabel("noParentsFound"),
                  style: const TextStyle(fontSize: 20.0),
                ),
              );
            }

            return Column(
              children: [
                _buildSearchBar(
                  showingSearch:
                      state.searchStatus == ChatUsersSearchStatus.initial,
                  onSubmitted: (search) {
                    context.read<ChatUsersCubit>().searchChatUsers(
                          role: ChatUserRole.guardian,
                          classSectionId:
                              (_selectedClassSection?.id ?? 0).toString(),
                          search: search,
                        );
                  },
                  onCleared: () {
                    context.read<ChatUsersCubit>().clearSearch();
                  },
                  searchController: _parentsSearchController,
                ),
                state.searchStatus == ChatUsersSearchStatus.loading
                    ? Center(
                        child: CustomCircularProgressIndicator(
                          indicatorColor: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : state.searchStatus == ChatUsersSearchStatus.success &&
                            state.searchChatUsersResponse!.chatUsers.isEmpty
                        ? Center(
                            child: Text(
                              Utils.getTranslatedLabel("noSearchResults"),
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView(
                              controller: _parentScrollController,
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              children: [
                                ...(state.searchStatus ==
                                            ChatUsersSearchStatus.success
                                        ? state
                                            .searchChatUsersResponse!.chatUsers
                                        : state.chatUsersResponse!.chatUsers)
                                    .map(
                                  (chatUser) => InkWell(
                                    onTap: () {
                                      Get.toNamed(
                                        Routes.chatScreen,
                                        arguments: ChatScreen.buildArguments(
                                          receiverId: chatUser.id,
                                          receiverName: chatUser.fullName,
                                          receiverImage: chatUser.image,
                                          // classSection:
                                          //     chatUser.subjectTeachers.first.subjectWithName,
                                        ),
                                      );
                                    },
                                    child: _buildCard(
                                        chatUser.fullName, chatUser.image),
                                  ),
                                ),

                                ///
                                if (state.loadMore)
                                  Center(
                                    child: CustomCircularProgressIndicator(
                                      indicatorColor:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
              ],
            );
          }

          return Center(
            child: CustomCircularProgressIndicator(
              indicatorColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStaffsList() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: BlocBuilder<StaffChatUsersCubit, StaffChatUsersState>(
        builder: (context, state) {
          if (state.status == StaffChatUsersFetchStatus.failure) {
            return ErrorContainer(
              errorMessage: state.errorMessage!,
              onTapRetry: getStaffs,
            );
          }

          if (state.status == StaffChatUsersFetchStatus.success) {
            if (state.chatUsersResponse!.chatUsers.isEmpty) {
              return Center(
                child: Text(
                  Utils.getTranslatedLabel("noStaffsFound"),
                  style: const TextStyle(fontSize: 20.0),
                ),
              );
            }

            return Column(
              children: [
                _buildSearchBar(
                  showingSearch:
                      state.searchStatus == StaffChatUsersSearchStatus.initial,
                  onSubmitted: (search) {
                    context.read<StaffChatUsersCubit>().searchChatUsers(
                          role: ChatUserRole.staff,
                          classSectionId:
                              (_selectedClassSection?.id ?? 0).toString(),
                          search: search,
                        );
                  },
                  onCleared: context.read<StaffChatUsersCubit>().clearSearch,
                  searchController: _staffsSearchController,
                ),
                state.searchStatus == StaffChatUsersSearchStatus.loading
                    ? Center(
                        child: CustomCircularProgressIndicator(
                          indicatorColor: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : state.searchStatus ==
                                StaffChatUsersSearchStatus.success &&
                            state.searchChatUsersResponse!.chatUsers.isEmpty
                        ? Center(
                            child: Text(
                              Utils.getTranslatedLabel("noSearchResults"),
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                ...(state.searchStatus ==
                                            StaffChatUsersSearchStatus.success
                                        ? state
                                            .searchChatUsersResponse!.chatUsers
                                        : state.chatUsersResponse!.chatUsers)
                                    .map(
                                  (chatUser) => InkWell(
                                    onTap: () {
                                      Get.toNamed(
                                        Routes.chatScreen,
                                        arguments: ChatScreen.buildArguments(
                                          receiverId: chatUser.id,
                                          receiverName: chatUser.fullName,
                                          receiverImage: chatUser.image,
                                          // classSection: chatUser.classSection?.fullName ?? "",
                                        ),
                                      );
                                    },
                                    child: _buildCard(
                                        chatUser.fullName, chatUser.image),
                                  ),
                                ),

                                ///
                                if (state.loadMore)
                                  Center(
                                    child: CustomCircularProgressIndicator(
                                      indicatorColor:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
              ],
            );
          }

          return Center(
            child: CustomCircularProgressIndicator(
              indicatorColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(String name, String image) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      margin: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 15.0,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: const Border(
          top: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
          bottom: BorderSide(color: Color(0xFFEBEEF3)),
        ),
      ),
      child: Row(
        children: [
          /// User profile image
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.tertiary,
            ),
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                width: 48,
                height: 48,
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
