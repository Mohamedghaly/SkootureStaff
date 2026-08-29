class Vehicle {
  final int id;
  final String name;
  final String registrationNumber;

  Vehicle({
    required this.id,
    required this.name,
    required this.registrationNumber,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      name: json['name'] ?? '',
      registrationNumber: json['registration_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'registration_number': registrationNumber,
    };
  }
}

class VehicleShift {
  final int id;
  final String name;
  final String startTime;
  final String endTime;
  final String pickupStartTime;
  final String pickupEndTime;
  final String dropStartTime;
  final String dropEndTime;

  VehicleShift({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.pickupStartTime,
    required this.pickupEndTime,
    required this.dropStartTime,
    required this.dropEndTime,
  });

  factory VehicleShift.fromJson(Map<String, dynamic> json) {
    return VehicleShift(
      id: json['id'],
      name: json['name'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      pickupStartTime: json['pickup_start_time'] ?? '',
      pickupEndTime: json['pickup_end_time'] ?? '',
      dropStartTime: json['drop_start_time'] ?? '',
      dropEndTime: json['drop_end_time'] ?? '',
    );
  }
}

class VehicleDetails {
  final Vehicle vehicle;
  final VehicleShift shifts;

  VehicleDetails({
    required this.vehicle,
    required this.shifts,
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) {
    return VehicleDetails(
      vehicle: Vehicle.fromJson(json['vehicle']),
      shifts: VehicleShift.fromJson(json['shifts']),
    );
  }
}

class ExpenseCategory {
  final int id;
  final String name;
  final String description;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class TransportationExpense {
  final int id;
  final int vehicleId;
  final int categoryId;
  final String refNo;
  final int? staffId;
  final double basicSalary;
  final int paidLeaves;
  final String? month;
  final String? year;
  final String title;
  final String description;
  final double amount;
  final String? file;
  final int createdBy;
  final String date;
  final int schoolId;
  final int sessionYearId;
  final String createdAt;
  final String updatedAt;
  final String takenLeaves;
  final String currencySymbol;

  TransportationExpense({
    required this.id,
    required this.vehicleId,
    required this.categoryId,
    required this.refNo,
    this.staffId,
    required this.basicSalary,
    required this.paidLeaves,
    this.month,
    this.year,
    required this.title,
    required this.description,
    required this.amount,
    this.file,
    required this.createdBy,
    required this.date,
    required this.schoolId,
    required this.sessionYearId,
    required this.createdAt,
    required this.updatedAt,
    required this.takenLeaves,
    required this.currencySymbol,
  });

  factory TransportationExpense.fromJson(Map<String, dynamic> json) {
    return TransportationExpense(
      id: json['id'] ?? 0,
      vehicleId: json['vehicle_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      refNo: json['ref_no'] ?? '',
      staffId: json['staff_id'],
      basicSalary: (json['basic_salary'] ?? 0).toDouble(),
      paidLeaves: json['paid_leaves'] ?? 0,
      month: json['month'],
      year: json['year'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      file: json['file'],
      createdBy: json['created_by'] ?? 0,
      date: json['date'] ?? '',
      schoolId: json['school_id'] ?? 0,
      sessionYearId: json['session_year_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      takenLeaves: json['taken_leaves'] ?? '',
      currencySymbol: json['currency_symbol'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'category_id': categoryId,
      'ref_no': refNo,
      'staff_id': staffId,
      'basic_salary': basicSalary,
      'paid_leaves': paidLeaves,
      'month': month,
      'year': year,
      'title': title,
      'description': description,
      'amount': amount,
      'file': file,
      'created_by': createdBy,
      'date': date,
      'school_id': schoolId,
      'session_year_id': sessionYearId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'taken_leaves': takenLeaves,
      'currency_symbol': currencySymbol,
    };
  }
}
