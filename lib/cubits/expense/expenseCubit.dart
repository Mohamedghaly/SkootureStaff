import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool_saas_staff/data/models/expense.dart';
import 'package:eschool_saas_staff/data/repositories/expenseRepository.dart';

// States
abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

// Categories states
class CategoriesFetchInProgress extends ExpenseState {}

class CategoriesFetchSuccess extends ExpenseState {
  final List<ExpenseCategory> categories;

  CategoriesFetchSuccess({required this.categories});
}

class CategoriesFetchFailure extends ExpenseState {
  final String errorMessage;

  CategoriesFetchFailure(this.errorMessage);
}

// Vehicles states
class VehiclesFetchInProgress extends ExpenseState {}

class VehiclesFetchSuccess extends ExpenseState {
  final List<VehicleDetails> vehicles;

  VehiclesFetchSuccess({required this.vehicles});
}

class VehiclesFetchFailure extends ExpenseState {
  final String errorMessage;

  VehiclesFetchFailure(this.errorMessage);
}

// Create expense states
class ExpenseCreateInProgress extends ExpenseState {}

class ExpenseCreateSuccess extends ExpenseState {
  final String message;

  ExpenseCreateSuccess({required this.message});
}

class ExpenseCreateFailure extends ExpenseState {
  final String errorMessage;

  ExpenseCreateFailure(this.errorMessage);
}

// Get expenses states
class ExpensesFetchInProgress extends ExpenseState {}

class ExpensesFetchSuccess extends ExpenseState {
  final List<TransportationExpense> expenses;

  ExpensesFetchSuccess({required this.expenses});
}

class ExpensesFetchFailure extends ExpenseState {
  final String errorMessage;

  ExpensesFetchFailure(this.errorMessage);
}

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepository _expenseRepository = ExpenseRepository();

  ExpenseCubit() : super(ExpenseInitial());

  // Fetch expense categories
  Future<void> fetchCategories() async {
    emit(CategoriesFetchInProgress());
    try {
      final categories = await _expenseRepository.getExpenseCategories();
      emit(CategoriesFetchSuccess(categories: categories));
    } catch (e) {
      emit(CategoriesFetchFailure(e.toString()));
    }
  }

  // Fetch vehicle details
  Future<void> fetchVehicles() async {
    emit(VehiclesFetchInProgress());
    try {
      final vehicles = await _expenseRepository.getVehicleDetails();
      emit(VehiclesFetchSuccess(vehicles: vehicles));
    } catch (e) {
      emit(VehiclesFetchFailure(e.toString()));
    }
  }

  // Create transportation expense
  Future<void> createExpense({
    required int vehicleId,
    required int categoryId,
    required String title,
    required String refNo,
    required double amount,
    required String date,
    required String description,
    File? imageFile,
  }) async {
    emit(ExpenseCreateInProgress());
    try {
      final result = await _expenseRepository.createTransportationExpense(
        vehicleId: vehicleId,
        categoryId: categoryId,
        title: title,
        refNo: refNo,
        amount: amount,
        date: date,
        description: description,
        imageFile: imageFile,
      );

      final message = result['message'] ?? 'Expense created successfully';
      emit(ExpenseCreateSuccess(message: message));

      // Automatically refresh expenses after creating
      await fetchExpenses();
    } catch (e) {
      emit(ExpenseCreateFailure(e.toString()));
    }
  }

  // Fetch transportation expenses
  Future<void> fetchExpenses() async {
    emit(ExpensesFetchInProgress());
    try {
      final expenses = await _expenseRepository.getTransportationExpenses();
      emit(ExpensesFetchSuccess(expenses: expenses));
    } catch (e) {
      emit(ExpensesFetchFailure(e.toString()));
    }
  }

  // Initialize data (fetch both categories and vehicles)
  Future<void> initializeData() async {
    emit(ExpenseLoading());
    try {
      await Future.wait([
        fetchCategories(),
        fetchVehicles(),
        fetchExpenses(),
      ]);
    } catch (e) {
      // Individual fetch methods will emit their own error states
    }
  }
}
