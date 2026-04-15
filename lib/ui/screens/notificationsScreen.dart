import 'package:eschool_saas_staff/cubits/announcement/notificationsCubit.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/errorContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/noDataContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/notificationItemContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/customCircularProgressIndicator.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static Widget getRouteInstance() {
    return BlocProvider(
      create: (context) => NotificationsCubit(),
      child: const NotificationsScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  static const double _scrollThreshold = 200.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<NotificationsCubit>().getNotifications();
    });

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Calculate remaining scroll distance
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final remainingScroll = maxScroll - currentScroll;

    // Trigger pagination when user is near the bottom (within threshold)
    if (remainingScroll <= _scrollThreshold) {
      final cubit = context.read<NotificationsCubit>();
      if (cubit.hasMore() && !_isFetchingMore()) {
        cubit.fetchMore();
      }
    }
  }

  bool _isFetchingMore() {
    final state = context.read<NotificationsCubit>().state;
    return state is NotificationsFetchSuccess && state.fetchMoreInProgress;
  }

  Future<void> _onRefresh() async {
    context.read<NotificationsCubit>().refresh();
    // Wait for the refresh to complete
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) {
                if (state is NotificationsFetchSuccess) {
                  if (state.notifications.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height -
                              Utils.appContentTopScrollPadding(
                                context: context,
                              ),
                          child: Center(
                            child: noDataContainer(
                              titleKey: noNotificationsKey,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        top: Utils.appContentTopScrollPadding(
                              context: context,
                            ) +
                            25,
                        bottom: 20,
                      ),
                      itemCount: state.notifications.length +
                          (state.fetchMoreInProgress || state.fetchMoreError
                              ? 1
                              : 0),
                      itemBuilder: (context, index) {
                        // Show notification items
                        if (index < state.notifications.length) {
                          return NotificationItemContainer(
                            notificationDetails: state.notifications[index],
                          );
                        }

                        // Show loading indicator at bottom
                        if (state.fetchMoreInProgress) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            child: CustomCircularProgressIndicator(
                              indicatorColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          );
                        }

                        // Show error with retry option at bottom
                        if (state.fetchMoreError) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  Utils.getTranslatedLabel(
                                    defaultErrorMessageKey,
                                  ),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    context
                                        .read<NotificationsCubit>()
                                        .retryFetchMore();
                                  },
                                  child: Text(
                                    Utils.getTranslatedLabel(retryKey),
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  );
                }

                if (state is NotificationsFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      errorMessage: state.errorMessage,
                      onTapRetry: () {
                        context.read<NotificationsCubit>().getNotifications();
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
          const Align(
            alignment: Alignment.topCenter,
            child: CustomAppbar(titleKey: notificationsKey),
          ),
        ],
      ),
    );
  }
}
