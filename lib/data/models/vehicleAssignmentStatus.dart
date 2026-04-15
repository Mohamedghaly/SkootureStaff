class VehicleAssignmentStatus {
  final bool error;
  final String message;
  final String? data;
  final int code;
  final String? details;

  VehicleAssignmentStatus({
    required this.error,
    required this.message,
    this.data,
    required this.code,
    this.details,
  });

  factory VehicleAssignmentStatus.fromJson(Map<String, dynamic> json) {
    return VehicleAssignmentStatus(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] as String?,
      code: json['code'] ?? 200,
      details: json['details'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'data': data,
      'code': code,
      'details': details,
    };
  }

  // Helper method to check if user is assigned to a vehicle
  bool get isAssigned => !error && data?.toLowerCase() == 'assigned';

  // Helper method to check if the assignment/plan is expired
  bool get isExpired => !error && data?.toLowerCase() == 'expired';

  // Helper method to check if the request is pending approval
  bool get isPending => !error && data?.toLowerCase() == 'pending';

  // Helper method to check if user has no assignment (false or any other value)
  bool get isNotAssigned => !error && (data?.toLowerCase() == 'false' || data == null);

  // Helper method to check if transportation should be shown (always show if module is enabled)
  bool get shouldShowTransportation => !error;

  // Helper method to check if user exists and API call was successful
  bool get isValidUser => !error;

  // Helper method to get the assignment status
  String get assignmentStatus => data ?? 'unknown';

  // Helper method to get user-friendly status message
  String get statusMessage {
    if (isAssigned) return 'You are assigned to a vehicle';
    if (isExpired) return 'Your transport plan has expired';
    if (isPending) return 'Your transport request is pending';
    if (isNotAssigned) return 'You are not enrolled in transportation';
    return 'Unknown status';
  }
}
