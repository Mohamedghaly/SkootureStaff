import 'package:eschool_saas_staff/app/routes.dart';
import 'package:eschool_saas_staff/cubits/authentication/authCubit.dart';
import 'package:eschool_saas_staff/cubits/chat/chatParentsUserChatHistoryCubit.dart';
import 'package:eschool_saas_staff/cubits/chat/chatStaffsUserChatHistoryCubit.dart';
import 'package:eschool_saas_staff/cubits/chat/chatStudentsUserChatHistoryCubit.dart';
import 'package:eschool_saas_staff/cubits/chat/socketSettingsCubit.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/chatContainer/chatScreen.dart';
import 'package:eschool_saas_staff/ui/screens/home/widgets/chatContainer/widgets/widgets.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customTabContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/tabBackgroundContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ChatContainer extends StatefulWidget {
  const ChatContainer({super.key});

  @override
  State<ChatContainer> createState() => _ChatContainerState();

  static Widget getRouteInstance() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ParentsUserChatHistoryCubit(),
        ),
        BlocProvider(
          create: (_) => StudentsUserChatHistoryCubit(),
        ),
        BlocProvider(
          create: (_) => StaffsUserChatHistoryCubit(),
        ),
      ],
      child: const ChatContainer(),
    );
  }
}

class _ChatContainerState extends State<ChatContainer> {
  var tabTitles = [studentsKey, parentsKey, staffsKey];
  late var selectedTabTitleKey = tabTitles.first;

  final _studentScrollController = ScrollController();
  final _parentScrollController = ScrollController();
  final _staffScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (!context.read<AuthCubit>().isTeacher()) {
      tabTitles.remove(studentsKey);
    }

    _studentScrollController.addListener(_onStudentScrollListener);
    _parentScrollController.addListener(_onParentScrollListener);
    _staffScrollController.addListener(_onStaffScrollListener);
    _fetchStudentsUserChatHistory();
    _fetchParentsUserChatHistory();
    _fetchStaffsUserChatHistory();
  }

  @override
  void dispose() {
    _studentScrollController.removeListener(_onStudentScrollListener);
    _parentScrollController.removeListener(_onParentScrollListener);
    _staffScrollController.removeListener(_onStaffScrollListener);
    super.dispose();
  }

  void _onStudentScrollListener() {
    if (_studentScrollController.position.maxScrollExtent ==
        _studentScrollController.offset) {
      if (context.read<StudentsUserChatHistoryCubit>().hasMore) {
        context.read<StudentsUserChatHistoryCubit>().fetchMoreUserChatHistory();
      }
    }
  }

  void _onParentScrollListener() {
    if (_parentScrollController.position.maxScrollExtent ==
        _parentScrollController.offset) {
      if (context.read<ParentsUserChatHistoryCubit>().hasMore) {
        context.read<ParentsUserChatHistoryCubit>().fetchMoreUserChatHistory();
      }
    }
  }

  void _onStaffScrollListener() {
    if (_staffScrollController.position.maxScrollExtent ==
        _staffScrollController.offset) {
      if (context.read<StaffsUserChatHistoryCubit>().hasMore) {
        context.read<StaffsUserChatHistoryCubit>().fetchMoreUserChatHistory();
      }
    }
  }

  void _fetchStudentsUserChatHistory() {
    context.read<StudentsUserChatHistoryCubit>().fetchUserChatHistory();
  }

  void _fetchParentsUserChatHistory() {
    context.read<ParentsUserChatHistoryCubit>().fetchUserChatHistory();
  }

  void _fetchStaffsUserChatHistory() {
    context.read<StaffsUserChatHistoryCubit>().fetchUserChatHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            switch (selectedTabTitleKey) {
              studentsKey => _buildStudentsTabContainer(),
              parentsKey => _buildParentsTabContainer(),
              staffsKey => _buildStaffsTabContainer(),
              _ => throw Exception("Invalid tab title key"),
            },

            ///
            _buildAppbar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsTabContainer() {
    return BlocBuilder<StudentsUserChatHistoryCubit,
        StudentsUserChatHistoryState>(
      builder: (context, state) {
        if (state is StudentsUserChatHistoryFetchFailure) {
          return Center(
            child: ErrorContainer(
              onTapRetry: _fetchStudentsUserChatHistory,
              errorMessage: state.errorMessage,
            ),
          );
        }

        if (state is StudentsUserChatHistoryFetchSuccess) {
          /// if there are no chat contacts, show a message to start a new chat
          if (state.userChatHistory.chatContacts.isEmpty) {
            return StartNewChat(
              title: Utils.getTranslatedLabel("connectWithStudents"),
              description: Utils.getTranslatedLabel("connectWithStudentsDesc"),
              onTapLetsStartChat: () {
                Get.toNamed(Routes.newChatContactsScreen)?.then(
                  (_) => _fetchStudentsUserChatHistory(),
                );
              },
            );
          }

          return Stack(
            alignment: Alignment.topCenter,
            children: [
              BlocListener<SocketSettingCubit, SocketSettingState>(
                listener: (context, state) {
                  if (state is SocketMessageReceived) {
                    context
                        .read<StudentsUserChatHistoryCubit>()
                        .messageReceived(
                          from: state.from,
                          message: state.message.message ?? "",
                          updatedAt: state.message.updatedAt,
                          incrementUnreadCount: true,
                        );
                  }
                },
                child: RefreshIndicator(
                  onRefresh: () async {
                    _fetchStudentsUserChatHistory();
                  },
                  child: ListView(
                    padding: EdgeInsets.only(
                      right: appContentHorizontalPadding,
                      left: appContentHorizontalPadding,
                      bottom: appContentHorizontalPadding * 2.5,
                      top: Utils.appContentTopScrollPadding(context: context) +
                          90,
                    ),
                    controller: _studentScrollController,
                    children: [
                      ...state.userChatHistory.chatContacts.map(
                        (contact) => ChatContactCard(
                          contact: contact,
                          onTap: () {
                            Get.toNamed(
                              Routes.chatScreen,
                              arguments: ChatScreen.buildArguments(
                                receiverId: contact.user.id,
                                receiverName: contact.user.fullName,
                                receiverImage: contact.user.image,
                              ),
                            )?.then(
                              (result) {
                                if (result.unreadCount > 0) {
                                  if (context.mounted) {
                                    context
                                        .read<StudentsUserChatHistoryCubit>()
                                        .updateUnreadCount(
                                          contact.user.id,
                                          result.unreadCount,
                                        );
                                  }
                                }

                                if (!context.mounted) return;

                                if (result.lastMessage != null) {
                                  context
                                      .read<StudentsUserChatHistoryCubit>()
                                      .updateLastMessage(
                                        contact.user.id,
                                        result.lastMessage,
                                        result.lastMessageTime,
                                      );
                                }
                              },
                            );
                          },
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
              ),

              ///
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: 20,
                    bottom: 110,
                  ),
                  child: FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    onPressed: () {
                      Get.toNamed(Routes.newChatContactsScreen)?.then(
                        (_) => _fetchStudentsUserChatHistory(),
                      );
                    },
                    child: SvgPicture.asset(
                      Utils.getImagePath("add_chat.svg"),
                    ),
                  ),
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
    );
  }

  Widget _buildParentsTabContainer() {
    return BlocBuilder<ParentsUserChatHistoryCubit,
        ParentsUserChatHistoryState>(
      builder: (context, state) {
        if (state is ParentsUserChatHistoryFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: state.errorMessage,
              onTapRetry: _fetchParentsUserChatHistory,
            ),
          );
        }

        if (state is ParentsUserChatHistoryFetchSuccess) {
          /// if there are no chat contacts, show a message to start a new chat
          if (state.userChatHistory.chatContacts.isEmpty) {
            return StartNewChat(
              title: Utils.getTranslatedLabel("connectWithParents"),
              description: Utils.getTranslatedLabel("connectWithParentsDesc"),
              onTapLetsStartChat: () {
                Get.toNamed(Routes.newChatContactsScreen)?.then(
                  (_) => _fetchParentsUserChatHistory(),
                );
              },
            );
          }

          return Stack(
            alignment: Alignment.topCenter,
            children: [
              BlocListener<SocketSettingCubit, SocketSettingState>(
                listener: (context, state) {
                  if (state is SocketMessageReceived) {
                    context.read<ParentsUserChatHistoryCubit>().messageReceived(
                          from: state.from,
                          message: state.message.message ?? "",
                          updatedAt: state.message.updatedAt,
                          incrementUnreadCount: false,
                        );
                  }
                },
                child: ListView(
                  padding: EdgeInsets.only(
                    right: appContentHorizontalPadding,
                    left: appContentHorizontalPadding,
                    bottom: appContentHorizontalPadding * 2.5,
                    top:
                        Utils.appContentTopScrollPadding(context: context) + 90,
                  ),
                  controller: _parentScrollController,
                  children: [
                    ...state.userChatHistory.chatContacts.map(
                      (contact) => ChatContactCard(
                        contact: contact,
                        onTap: () {
                          Get.toNamed(
                            Routes.chatScreen,
                            arguments: ChatScreen.buildArguments(
                              receiverId: contact.user.id,
                              receiverName: contact.user.fullName,
                              receiverImage: contact.user.image,
                            ),
                          )?.then(
                            (result) {
                              if (result.unreadCount > 0) {
                                if (context.mounted) {
                                  context
                                      .read<ParentsUserChatHistoryCubit>()
                                      .updateUnreadCount(
                                        contact.user.id,
                                        result.unreadCount,
                                      );
                                }
                              }

                              if (!context.mounted) return;

                              if (result.lastMessage != null) {
                                context
                                    .read<ParentsUserChatHistoryCubit>()
                                    .updateLastMessage(
                                      contact.user.id,
                                      result.lastMessage,
                                      result.lastMessageTime,
                                    );
                              }
                            },
                          );
                        },
                      ),
                    ),

                    ///
                    if (state.loadMore)
                      Center(
                        child: CustomCircularProgressIndicator(
                          indicatorColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),

              ///
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: 20,
                    bottom: 110,
                  ),
                  child: FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    onPressed: () {
                      Get.toNamed(Routes.newChatContactsScreen)?.then(
                        (_) => _fetchParentsUserChatHistory(),
                      );
                    },
                    child: SvgPicture.asset(
                      Utils.getImagePath("add_chat.svg"),
                    ),
                  ),
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
    );
  }

  Widget _buildStaffsTabContainer() {
    return BlocBuilder<StaffsUserChatHistoryCubit, StaffsUserChatHistoryState>(
      builder: (context, state) {
        if (state is StaffsUserChatHistoryFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: state.errorMessage,
              onTapRetry: _fetchStaffsUserChatHistory,
            ),
          );
        }

        if (state is StaffsUserChatHistoryFetchSuccess) {
          /// if there are no chat contacts, show a message to start a new chat
          if (state.userChatHistory.chatContacts.isEmpty) {
            return StartNewChat(
              title: Utils.getTranslatedLabel("connectWithStaffs"),
              description: Utils.getTranslatedLabel("connectWithStaffsDesc"),
              onTapLetsStartChat: () {
                Get.toNamed(Routes.newChatContactsScreen)?.then(
                  (_) => _fetchStaffsUserChatHistory(),
                );
              },
            );
          }

          return Stack(
            alignment: Alignment.topCenter,
            children: [
              BlocListener<SocketSettingCubit, SocketSettingState>(
                listener: (context, state) {
                  if (state is SocketMessageReceived) {
                    context.read<StaffsUserChatHistoryCubit>().messageReceived(
                          from: state.from,
                          message: state.message.message ?? "",
                          updatedAt: state.message.updatedAt,
                          incrementUnreadCount: false,
                        );
                  }
                },
                child: ListView(
                  padding: EdgeInsets.only(
                    right: appContentHorizontalPadding,
                    left: appContentHorizontalPadding,
                    bottom: appContentHorizontalPadding * 2.5,
                    top:
                        Utils.appContentTopScrollPadding(context: context) + 90,
                  ),
                  controller: _staffScrollController,
                  children: [
                    ...state.userChatHistory.chatContacts.map(
                      (contact) => ChatContactCard(
                        contact: contact,
                        onTap: () {
                          Get.toNamed(
                            Routes.chatScreen,
                            arguments: ChatScreen.buildArguments(
                              receiverId: contact.user.id,
                              receiverName: contact.user.fullName,
                              receiverImage: contact.user.image,
                            ),
                          )?.then(
                            (result) {
                              if (result.unreadCount > 0) {
                                if (context.mounted) {
                                  context
                                      .read<StaffsUserChatHistoryCubit>()
                                      .updateUnreadCount(
                                        contact.user.id,
                                        result.unreadCount,
                                      );
                                }
                              }

                              if (!context.mounted) return;

                              if (result.lastMessage != null) {
                                context
                                    .read<StaffsUserChatHistoryCubit>()
                                    .updateLastMessage(
                                      contact.user.id,
                                      result.lastMessage,
                                      result.lastMessageTime,
                                    );
                              }
                            },
                          );
                        },
                      ),
                    ),

                    ///
                    if (state.loadMore)
                      Center(
                        child: CustomCircularProgressIndicator(
                          indicatorColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),

              ///
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: 20,
                    bottom: 110,
                  ),
                  child: FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    onPressed: () {
                      Get.toNamed(Routes.newChatContactsScreen)?.then(
                        (_) => _fetchStaffsUserChatHistory(),
                      );
                    },
                    child: SvgPicture.asset(
                      Utils.getImagePath("add_chat.svg"),
                    ),
                  ),
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
    );
  }

  Widget _buildAppbar() {
    void changeTab(String value) {
      setState(() {
        selectedTabTitleKey = value;
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CustomAppbar(
          showBackButton: false,
          titleKey: chatKey,
        ),

        ///
        TabBackgroundContainer(
          child: LayoutBuilder(
            builder: (context, constraints) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: tabTitles
                  .map(
                    (tab) => CustomTabContainer(
                      titleKey: tab,
                      isSelected: tab == selectedTabTitleKey,
                      width:
                          constraints.maxWidth * ((1 / tabTitles.length) - .01),
                      onTap: changeTab,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
