import 'package:flutter/material.dart';
import 'package:eschool_saas_staff/data/models/tripDetails.dart';
import 'package:eschool_saas_staff/data/models/trip.dart';
import 'package:get/get.dart';
import 'package:eschool_saas_staff/ui/screens/tripDetailsScreen/widgets/tripDetailsAppBar.dart';
import 'package:eschool_saas_staff/ui/screens/tripDetailsScreen/widgets/tripStatusHeader.dart';
import 'package:eschool_saas_staff/ui/screens/tripDetailsScreen/widgets/tripTimeline.dart';
import 'package:eschool_saas_staff/ui/screens/tripDetailsScreen/widgets/tripActionButtons.dart';
import 'package:eschool_saas_staff/ui/screens/tripDetailsScreen/widgets/tripPassengersList.dart';
import 'package:eschool_saas_staff/ui/screens/tripDetailsScreen/widgets/startTripBottomSheet.dart';
import 'package:eschool_saas_staff/ui/screens/tripDetailsScreen/widgets/tripProblemReporting.dart';
import 'package:eschool_saas_staff/ui/screens/tripDetailsScreen/widgets/driverReportIssueBottomSheet.dart';
import 'package:eschool_saas_staff/cubits/transport/tripsCubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';

class TripDetailsScreen extends StatefulWidget {
  final TripDetails? tripDetails;

  const TripDetailsScreen({
    super.key,
    this.tripDetails,
  });

  static Widget getRouteInstance({TripDetails? tripDetails}) {
    return BlocProvider(
      create: (context) => TripsCubit(),
      child: TripDetailsScreen(tripDetails: tripDetails),
    );
  }

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  late TripDetails _tripDetails;
  late Trip? _originalTrip; // Keep reference to original Trip object
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Get trip details from arguments or widget parameter
    final arguments = Get.arguments;
    if (arguments is Trip) {
      _originalTrip = arguments;
      _tripDetails = _convertTripToTripDetails(arguments);
    } else if (arguments is TripDetails) {
      _originalTrip = null;
      _tripDetails = arguments;
    } else {
      _originalTrip = null;
      _tripDetails = widget.tripDetails ?? _createDummyTripDetails();
    }
  }

  TripDetails _convertTripToTripDetails(Trip trip) {
    // Convert Trip model to TripDetails model
    final tripStatus = _parseStatusFromTrip(trip.status);

    // Count total passengers from all stops
    int totalPassengers = 0;
    int presentCount = 0;
    int absentCount = 0;

    for (var stop in trip.stops) {
      totalPassengers += stop.passengers.length;
      // Count attendance status
      for (var passenger in stop.passengers) {
        if (passenger.isPresent) {
          presentCount++;
        } else if (passenger.isAbsent) {
          absentCount++;
        }
      }
    }

    // Determine the last reached stop index for timeline status
    int lastReachedStopIndex = -1;
    if (trip.lastReachedStop != null) {
      for (int i = 0; i < trip.stops.length; i++) {
        if (trip.stops[i].id == trip.lastReachedStop!.id) {
          lastReachedStopIndex = i;
          break;
        }
      }
    }

    // Check if trip is completed
    final bool isTripCompleted =
        trip.status.toLowerCase() == 'completed' && trip.allStopsCompleted;

    // Convert stops with proper status based on attendance marking
    // IMPORTANT: When trip is completed AND all_stops_completed is true, mark ALL stops as completed
    // Otherwise, only mark stops as reached when attendance has been successfully marked (stop.isReached)
    List<TripStop> tripStops = trip.stops.asMap().entries.map((entry) {
      int index = entry.key;
      var stop = entry.value;

      StopStatus stopStatus;

      // If trip is completed, mark all stops as completed
      if (isTripCompleted) {
        stopStatus = StopStatus.completed;
      }
      // Check if this specific stop has attendance marked (stop.isReached checks if estimated_time == "Reached")
      else if (stop.isReached) {
        // This stop has attendance marked, show as completed
        stopStatus = StopStatus.completed;
      } else if (lastReachedStopIndex >= 0 && index <= lastReachedStopIndex) {
        // During in-progress trip, mark stops as completed only up to last reached stop
        stopStatus = StopStatus.completed; // Green line up to this point
      } else {
        // All other stops remain upcoming (not reached)
        stopStatus = StopStatus.upcoming;
      }

      return TripStop(
        id: stop.id?.toString() ?? '',
        name: stop.name,
        time: stop.scheduledTime,
        actualTime: stop.actualTime,
        passengerCount: stop.passengers.length,
        status: stopStatus,
        isSchoolCampus: stop.name.toLowerCase().contains('school'),
      );
    }).toList();

    // Create passenger groups for each stop with proper attendance status
    List<PassengerGroup> passengerGroups =
        trip.stops.where((stop) => stop.passengers.isNotEmpty).map((stop) {
      return PassengerGroup(
        stopId: stop.id?.toString() ?? '',
        stopName: stop.name,
        time: stop.scheduledTime,
        passengers: stop.passengers.map((passenger) {
          // Map attendance status from API response
          PassengerStatus attendanceStatus;
          if (passenger.isPresent) {
            attendanceStatus = PassengerStatus.present;
          } else if (passenger.isAbsent) {
            attendanceStatus = PassengerStatus.absent;
          } else {
            attendanceStatus = PassengerStatus.notMarked; // For pending or null
          }

          return Passenger(
            id: passenger.id?.toString() ?? '',
            name: passenger.name,
            type: passenger.role ?? 'Student',
            profileImage: passenger.imageUrl,
            attendanceStatus: attendanceStatus,
          );
        }).toList(),
      );
    }).toList();

    // Use total_stops from API if available, otherwise calculate by excluding "School" stops
    final int actualStopsCount = trip.totalStops ??
        trip.stops
            .where((stop) => !stop.name.toLowerCase().contains('school'))
            .length;

    return TripDetails(
      id: trip.tripId?.toString() ?? '',
      route: trip.route.name,
      shiftTime: trip.displayShiftTime,
      status: tripStatus,
      totalStops: actualStopsCount,
      totalPassengers: totalPassengers,
      presentCount: presentCount,
      absentCount: absentCount,
      stops: tripStops,
      passengerGroups: passengerGroups,
      allStopsCompleted: trip.allStopsCompleted,
    );
  }

  TripStatus _parseStatusFromTrip(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return TripStatus.upcoming;
      case 'in_progress':
      case 'inprogress':
        return TripStatus.inProgress;
      case 'completed':
        return TripStatus.completed;
      default:
        return TripStatus.upcoming;
    }
  }

  TripDetails _createDummyTripDetails() {
    return TripDetails(
      id: '1',
      route: Utils.getTranslatedLabel(unknownRouteKey),
      shiftTime: Utils.getTranslatedLabel(unknownTimeKey),
      status: TripStatus.upcoming,
      totalStops: 0,
      totalPassengers: 0,
      stops: [],
      passengerGroups: [],
      allStopsCompleted: false,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onStopReached(String stopId) {
    // Handle when a stop is marked as reached
    // In a real implementation, this would update the backend
    // and refresh the trip data from the API
    if (_originalTrip?.tripId != null) {
      context
          .read<TripsCubit>()
          .fetchTripDetails(tripId: _originalTrip!.tripId!);
    }
  }

  Future<void> _onRefresh() async {
    // Refresh trip data from API without setState
    if (_originalTrip?.tripId != null) {
      await context
          .read<TripsCubit>()
          .fetchTripDetails(tripId: _originalTrip!.tripId!);
    }
  }

  void _showStartTripBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StartTripBottomSheet(
        routeName: _tripDetails.route,
        shiftTime: _tripDetails.shiftTime,
        stopCount: _tripDetails.totalStops,
        studentCount: _tripDetails.totalPassengers,
        onStartTrip: _handleStartTrip,
      ),
    );
  }

  void _openDriverReportBottomSheet() {
    // Get the last reached stop ID from the original Trip object
    int? lastReachedStopId;
    if (_originalTrip?.lastReachedStop?.id != null) {
      lastReachedStopId = _originalTrip!.lastReachedStop!.id;
    }

    // Get trip ID
    final tripId = int.tryParse(_tripDetails.id) ?? 0;

    if (tripId > 0) {
      DriverReportIssueBottomSheet.show(
        context,
        tripId,
        lastReachedStopId: lastReachedStopId,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Utils.getTranslatedLabel(defaultErrorMessageKey),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleStartTrip(String tripType) async {
    Navigator.of(context).pop(); // Close bottom sheet

    if (_originalTrip?.shiftTime.id != null) {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Utils.getTranslatedLabel(startingTripKey)),
          duration: const Duration(seconds: 2),
        ),
      );

      await context.read<TripsCubit>().startTrip(
            shiftId: _originalTrip!.shiftTime.id,
            pickupDrop: tripType,
            routeId: _originalTrip!.route.id,
          );
    }
  }

  void _handleCompleteTrip() async {
    if (_originalTrip?.tripId != null) {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Utils.getTranslatedLabel(completingTripKey)),
          duration: const Duration(seconds: 2),
        ),
      );

      await context.read<TripsCubit>().completeTrip(
            tripId: _originalTrip!.tripId!,
          );
    }
  }

  // Local state to track passenger attendance changes
  final Map<String, Map<String, PassengerStatus>> _pendingAttendanceChanges =
      {};

  void _updatePassengerAttendance(
      String stopId, String passengerId, PassengerStatus status) {
    // Only allow changes for non-reached stops
    final originalStop = _originalTrip?.stops.firstWhere(
      (s) => s.id?.toString() == stopId,
      orElse: () => Stop(name: 'Unknown', scheduledTime: ''),
    );

    if (originalStop?.isReached == true) {
      // Stop is already reached, don't allow changes
      return;
    }

    // Initialize stop map if it doesn't exist
    _pendingAttendanceChanges[stopId] ??= {};

    // Update the attendance status for this passenger
    _pendingAttendanceChanges[stopId]![passengerId] = status;

    // Update the UI by modifying the trip details
    setState(() {
      final groupIndex = _tripDetails.passengerGroups
          .indexWhere((group) => group.stopId == stopId);
      if (groupIndex != -1) {
        final group = _tripDetails.passengerGroups[groupIndex];
        final passengerIndex =
            group.passengers.indexWhere((p) => p.id == passengerId);
        if (passengerIndex != -1) {
          // Create a new passenger with updated status
          final updatedPassenger = Passenger(
            id: group.passengers[passengerIndex].id,
            name: group.passengers[passengerIndex].name,
            type: group.passengers[passengerIndex].type,
            profileImage: group.passengers[passengerIndex].profileImage,
            attendanceStatus: status,
            canCall: group.passengers[passengerIndex].canCall,
            phoneNumber: group.passengers[passengerIndex].phoneNumber,
          );

          // Create new passengers list with updated passenger
          final updatedPassengers = List<Passenger>.from(group.passengers);
          updatedPassengers[passengerIndex] = updatedPassenger;

          // Create new group with updated passengers
          final updatedGroup = PassengerGroup(
            stopId: group.stopId,
            stopName: group.stopName,
            time: group.time,
            passengers: updatedPassengers,
            pickupNote: group.pickupNote,
            isOnTime: group.isOnTime,
          );

          // Create new groups list with updated group
          final updatedGroups =
              List<PassengerGroup>.from(_tripDetails.passengerGroups);
          updatedGroups[groupIndex] = updatedGroup;

          // Create new trip details with updated groups
          _tripDetails = TripDetails(
            id: _tripDetails.id,
            route: _tripDetails.route,
            shiftTime: _tripDetails.shiftTime,
            status: _tripDetails.status,
            totalStops: _tripDetails.totalStops,
            totalPassengers: _tripDetails.totalPassengers,
            presentCount: _tripDetails.presentCount,
            absentCount: _tripDetails.absentCount,
            stops: _tripDetails.stops,
            passengerGroups: updatedGroups,
            startTime: _tripDetails.startTime,
            endTime: _tripDetails.endTime,
            busNumber: _tripDetails.busNumber,
            allStopsCompleted: _tripDetails.allStopsCompleted,
          );
        }
      }
    });
  }

  void _handleMarkAttendance(String stopId) async {
    final stop = _originalTrip?.stops.firstWhere(
      (s) => s.id?.toString() == stopId,
      orElse: () => Stop(name: 'Unknown', scheduledTime: ''),
    );

    // Don't allow attendance marking for reached stops
    if (stop?.isReached == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Utils.getTranslatedLabel(attendanceAlreadyMarkedKey)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_originalTrip != null && stop?.id != null) {
      // Check if we have any attendance selections for this stop
      final stopAttendance = _pendingAttendanceChanges[stopId] ?? {};
      if (stopAttendance.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Utils.getTranslatedLabel(pleaseSelectAttendanceKey)),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Utils.getTranslatedLabel(markingAttendanceKey)),
          duration: const Duration(seconds: 2),
        ),
      );

      // Prepare attendance records only for passengers with selected attendance
      final records = <Map<String, dynamic>>[];

      for (final entry in stopAttendance.entries) {
        final passengerId = entry.key;
        final status = entry.value;

        String statusValue;
        switch (status) {
          case PassengerStatus.present:
            statusValue = 'present';
            break;
          case PassengerStatus.absent:
            statusValue = 'absent';
            break;
          case PassengerStatus.notMarked:
            statusValue = 'pending';
            break;
        }

        records.add({
          'user_id': int.tryParse(passengerId) ?? 0,
          'status': statusValue,
        });
      }

      // Get current date in YYYY-MM-DD format
      final now = DateTime.now();
      final date =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Use route_vehicle_id from the API response
      final routeVehicleId = _originalTrip!.route.routeVehicleId ?? 1;

      await context.read<TripsCubit>().createAttendance(
            routeVehicleId: routeVehicleId,
            pickupPointId: stop!.id!,
            shiftId: _originalTrip!.shiftTime.id,
            pickupDrop: _originalTrip!.type.toLowerCase() == 'pickup' ? 0 : 1,
            date: date,
            tripId: _originalTrip!.tripId!,
            records: records,
          );

      // Clear pending changes for this stop after successful submission
      _pendingAttendanceChanges.remove(stopId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripsCubit, TripsState>(
      listener: (context, state) {
        if (state is TripStartSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );

          // Fetch trip details using the trip_id from the start response
          if (state.tripId != null) {
            context.read<TripsCubit>().fetchTripDetails(tripId: state.tripId!);
          }
        } else if (state is TripStartFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is AttendanceCreateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );

          // Auto-refresh trip details after attendance is successfully created
          if (_originalTrip?.tripId != null) {
            context
                .read<TripsCubit>()
                .fetchTripDetails(tripId: _originalTrip!.tripId!);
          }
        } else if (state is AttendanceCreateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is TripDetailsFetchSuccess) {
          // Update trip details with the fetched trip data
          setState(() {
            _originalTrip = state.trip;
            _tripDetails = _convertTripToTripDetails(state.trip);
          });
        } else if (state is TripDetailsFetchFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Failed to load trip details: ${state.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is TripCompleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );

          // Refresh trip details after completion
          if (_originalTrip?.tripId != null) {
            context
                .read<TripsCubit>()
                .fetchTripDetails(tripId: _originalTrip!.tripId!);
          }
        } else if (state is TripCompleteFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is TripsFetchSuccess) {
          // Update trip details with new data if available
          Trip? updatedTrip;

          // First try to find the trip by the original trip ID
          try {
            updatedTrip = state.trips.firstWhere(
              (trip) => trip.tripId == _originalTrip?.tripId,
            );
          } catch (e) {
            // Trip not found by original ID, continue to next search
          }

          // If not found by original ID, try to find by route and shift
          if (updatedTrip == null && _originalTrip != null) {
            try {
              updatedTrip = state.trips.firstWhere(
                (trip) =>
                    trip.route.id == _originalTrip!.route.id &&
                    trip.shiftTime.id == _originalTrip!.shiftTime.id,
              );
            } catch (e) {
              // Trip not found by route and shift, continue to next search
            }
          }

          // If still not found, use the first trip from the route (most recent)
          if (updatedTrip == null && state.trips.isNotEmpty) {
            updatedTrip = state.trips.first;
          }

          if (updatedTrip != null) {
            setState(() {
              _tripDetails = _convertTripToTripDetails(updatedTrip!);
              _originalTrip = updatedTrip;
            });
          }
        }
      },
      builder: (context, state) {
        // Show loading indicator when fetching trip details or completing trip
        if (state is TripDetailsFetchInProgress ||
            state is TripCompleteInProgress) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: const SafeArea(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isTablet = constraints.maxWidth > 600;
            final double horizontalPadding = isTablet
                ? appContentHorizontalPadding * 2
                : appContentHorizontalPadding;

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: SafeArea(
                child: Column(
                  children: [
                    // App Bar
                    const TripDetailsAppBar(),

                    // Scrollable Content
                    Expanded(
                      child: RefreshIndicator(
                        color: Theme.of(context).colorScheme.primary,
                        onRefresh: _onRefresh,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Trip Status Header
                              TripStatusHeader(
                                tripDetails: _tripDetails,
                                onRefresh: _onRefresh,
                              ),

                              const SizedBox(height: 20),

                              // Route Timeline
                              TripTimeline(
                                tripDetails: _tripDetails,
                                onStopReached: _onStopReached,
                              ),

                              const SizedBox(height: 20),

                              // Passengers List
                              TripPassengersList(
                                tripDetails: _tripDetails,
                                originalTrip: _originalTrip,
                                onPassengerAttendanceUpdate:
                                    _updatePassengerAttendance,
                                onMarkAttendance: _handleMarkAttendance,
                                onGroupExpansionChanged: (stopId, isExpanded) {
                                  // Handle group expansion state change
                                  // No setState needed - handled internally by widget
                                },
                              ),

                              const SizedBox(height: 20),

                              // Problem Reporting (if in progress)
                              if (_tripDetails.status == TripStatus.inProgress)
                                TripProblemReporting(
                                  onReportIssue: () {
                                    _openDriverReportBottomSheet();
                                  },
                                ),

                              // Bottom padding for better scrolling
                              const SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar:
                  (_tripDetails.status == TripStatus.upcoming ||
                          _tripDetails.status == TripStatus.inProgress)
                      ? TripActionButtons(
                          tripDetails: _tripDetails,
                          onStartTrip: _showStartTripBottomSheet,
                          onCompleteTrip: _handleCompleteTrip,
                        )
                      : null,
            );
          },
        );
      },
    );
  }
}
