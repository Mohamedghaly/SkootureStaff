/// Model for transportation enrollment submission request
class TransportEnrollmentSubmissionRequest {
  final String? paymentMethod;
  final int userId;
  final int pickupPointId;
  final int transportationFeeId;
  final int shiftId;
  final bool isChangeRoute;

  TransportEnrollmentSubmissionRequest({
    this.paymentMethod,
    required this.userId,
    required this.pickupPointId,
    required this.transportationFeeId,
    required this.shiftId,
    this.isChangeRoute = false,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'user_id': userId.toString(),
      'pickup_point_id': pickupPointId.toString(),
      'transportation_fee_id': transportationFeeId.toString(),
      'shift_id': shiftId.toString(),
    };

    // Only include payment_method if it's provided
    if (paymentMethod != null && paymentMethod!.isNotEmpty) {
      json['payment_method'] = paymentMethod!;
    }

    // Include change_route parameter if this is a route change request
    if (isChangeRoute) {
      json['change_route'] = 'yes';
    }

    return json;
  }
}

/// Model for transportation enrollment submission response
class TransportEnrollmentSubmissionResponse {
  final bool error;
  final String message;
  final TransportEnrollmentData? data;
  final int code;

  TransportEnrollmentSubmissionResponse({
    required this.error,
    required this.message,
    this.data,
    required this.code,
  });

  factory TransportEnrollmentSubmissionResponse.fromJson(
      Map<String, dynamic> json) {
    return TransportEnrollmentSubmissionResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? TransportEnrollmentData.fromJson(json['data'])
          : null,
      code: json['code'] ?? 200,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'data': data?.toJson(),
      'code': code,
    };
  }

  bool get isSuccess => !error && code == 200;
}

/// Model for enrollment data (contains amount)
class TransportEnrollmentData {
  final String amount;

  TransportEnrollmentData({
    required this.amount,
  });

  factory TransportEnrollmentData.fromJson(Map<String, dynamic> json) {
    return TransportEnrollmentData(
      amount: json['amount']?.toString() ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
    };
  }

  // Helper to get amount as double
  double get amountValue => double.tryParse(amount) ?? 0.0;
}
