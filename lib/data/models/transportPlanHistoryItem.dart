import 'package:eschool_saas_staff/data/models/currentPlan.dart';

/// One entry from the `transport/plans/current` list response.
class TransportPlanHistoryItem {
  final int? id;
  final int? paymentId;
  final String? duration;
  final String? validFrom;
  final String? validTo;
  final int? expiresInDays;
  final String? totalFee;
  final String? paymentMode;
  final String? planStatus;
  final String? status;
  final PlanRoute? route;
  final PlanShift? shift;
  final PlanPickupStop? pickupStop;
  final String? estimatedPickupTime;

  const TransportPlanHistoryItem({
    this.id,
    this.paymentId,
    this.duration,
    this.validFrom,
    this.validTo,
    this.expiresInDays,
    this.totalFee,
    this.paymentMode,
    this.planStatus,
    this.status,
    this.route,
    this.shift,
    this.pickupStop,
    this.estimatedPickupTime,
  });

  factory TransportPlanHistoryItem.fromJson(Map<String, dynamic> json) {
    return TransportPlanHistoryItem(
      id: json['id'] as int?,
      paymentId: json['payment_id'] as int?,
      duration: json['duration'] as String?,
      validFrom: json['valid_from'] as String?,
      validTo: json['valid_to'] as String?,
      expiresInDays: json['expires_in_days'] as int?,
      totalFee: json['total_fee'] as String?,
      paymentMode: json['payment_mode'] as String?,
      planStatus: json['plan_status'] as String?,
      status: json['status'] as String?,
      route: json['route'] != null
          ? PlanRoute.fromJson(Map<String, dynamic>.from(json['route']))
          : null,
      shift: json['shift'] != null
          ? PlanShift.fromJson(Map<String, dynamic>.from(json['shift']))
          : null,
      pickupStop: json['pickup_stop'] != null
          ? PlanPickupStop.fromJson(
              Map<String, dynamic>.from(json['pickup_stop']))
          : null,
      estimatedPickupTime: json['estimated_pickup_time'] as String?,
    );
  }

  String get validityPeriod {
    if (validFrom != null && validTo != null) return '$validFrom – $validTo';
    return validFrom ?? validTo ?? '';
  }
}
