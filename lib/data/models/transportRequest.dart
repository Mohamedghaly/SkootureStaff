class TransportRequestResponse {
  final bool error;
  final String message;
  final List<TransportRequest> data;
  final int code;

  TransportRequestResponse({
    required this.error,
    required this.message,
    required this.data,
    required this.code,
  });

  factory TransportRequestResponse.fromJson(Map<String, dynamic> json) {
    return TransportRequestResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((item) => TransportRequest.fromJson(item))
              .toList() ??
          [],
      code: json['code'] ?? 200,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
      'code': code,
    };
  }
}

class TransportRequest {
  final int id;
  final String status;
  final String requestedOn;
  final RequestedBy requestedBy;
  final RequestDetails details;
  final RequestReview? review;
  final String mode;
  final ContactDetails contactDetails;

  TransportRequest({
    required this.id,
    required this.status,
    required this.requestedOn,
    required this.requestedBy,
    required this.details,
    this.review,
    required this.mode,
    required this.contactDetails,
  });

  factory TransportRequest.fromJson(Map<String, dynamic> json) {
    return TransportRequest(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      requestedOn: json['requested_on'] ?? '',
      requestedBy: RequestedBy.fromJson(json['requested_by'] ?? {}),
      details: RequestDetails.fromJson(json['details'] ?? {}),
      review: json['review'] != null
          ? RequestReview.fromJson(json['review'])
          : null,
      mode: json['mode'] ?? '',
      contactDetails: ContactDetails.fromJson(json['contact_details'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'requested_on': requestedOn,
      'requested_by': requestedBy.toJson(),
      'details': details.toJson(),
      if (review != null) 'review': review!.toJson(),
      'mode': mode,
      'contact_details': contactDetails.toJson(),
    };
  }

  // Helper getters
  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'pending':
        return 'Pending';
      default:
        return 'Unknown';
    }
  }

  bool get isAccepted => status.toLowerCase() == 'accepted';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isPending => status.toLowerCase() == 'pending';
}

class RequestedBy {
  final int studentId;
  final String name;

  RequestedBy({
    required this.studentId,
    required this.name,
  });

  factory RequestedBy.fromJson(Map<String, dynamic> json) {
    return RequestedBy(
      studentId: json['student_id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'name': name,
    };
  }
}

class RequestDetails {
  final PickupStop pickupStop;
  final TransportPlan plan;

  RequestDetails({
    required this.pickupStop,
    required this.plan,
  });

  factory RequestDetails.fromJson(Map<String, dynamic> json) {
    return RequestDetails(
      pickupStop: PickupStop.fromJson(json['pickup_stop'] ?? {}),
      plan: TransportPlan.fromJson(json['plan'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickup_stop': pickupStop.toJson(),
      'plan': plan.toJson(),
    };
  }
}

class PickupStop {
  final int id;
  final String name;

  PickupStop({
    required this.id,
    required this.name,
  });

  factory PickupStop.fromJson(Map<String, dynamic> json) {
    return PickupStop(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class TransportPlan {
  final String duration;
  final String validity;

  TransportPlan({
    required this.duration,
    required this.validity,
  });

  factory TransportPlan.fromJson(Map<String, dynamic> json) {
    // Handle duration which can be bool, String, int, or null
    String durationValue = '';
    final rawDuration = json['duration'];
    if (rawDuration == null) {
      durationValue = '';
    } else if (rawDuration is String) {
      durationValue = rawDuration;
    } else if (rawDuration is bool) {
      durationValue = rawDuration ? 'Active' : 'Inactive';
    } else if (rawDuration is int) {
      durationValue = rawDuration.toString();
    } else {
      durationValue = rawDuration.toString();
    }

    // Handle validity which should be String but might come as other types
    String validityValue = '';
    final rawValidity = json['validity'];
    if (rawValidity == null) {
      validityValue = '';
    } else if (rawValidity is String) {
      validityValue = rawValidity;
    } else {
      validityValue = rawValidity.toString();
    }

    return TransportPlan(
      duration: durationValue,
      validity: validityValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'validity': validity,
    };
  }
}

class RequestReview {
  final String respondedOn;

  RequestReview({
    required this.respondedOn,
  });

  factory RequestReview.fromJson(Map<String, dynamic> json) {
    return RequestReview(
      respondedOn: json['responded_on'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'responded_on': respondedOn,
    };
  }
}

class ContactDetails {
  final String schoolEmail;
  final String schoolPhone;

  ContactDetails({
    required this.schoolEmail,
    required this.schoolPhone,
  });

  factory ContactDetails.fromJson(Map<String, dynamic> json) {
    return ContactDetails(
      schoolEmail: json['school_email'] ?? '',
      schoolPhone: json['school_phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'school_email': schoolEmail,
      'school_phone': schoolPhone,
    };
  }
}
