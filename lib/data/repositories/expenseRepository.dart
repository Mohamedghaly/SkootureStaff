import 'dart:io';
import 'package:dio/dio.dart';
import 'package:eschool_saas_staff/data/models/expense.dart';
import 'package:eschool_saas_staff/utils/api.dart';
import 'package:flutter/material.dart';

class ExpenseRepository {
  // Get expense categories
  Future<List<ExpenseCategory>> getExpenseCategories() async {
    try {
      final result = await Api.get(
        url: Api.getExpenseCategories,
        useAuthToken: true,
      );

      final List<dynamic> categoriesData = result['data'] ?? [];
      return categoriesData
          .map((category) => ExpenseCategory.fromJson(category))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Get vehicle details
  Future<List<VehicleDetails>> getVehicleDetails() async {
    try {
      final result = await Api.get(
        url: Api.getVehicleDetails,
        useAuthToken: true,
      );

      final List<dynamic> vehiclesData = result['data'] ?? [];
      return vehiclesData
          .map((vehicle) => VehicleDetails.fromJson(vehicle))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Create transportation expense
  Future<Map<String, dynamic>> createTransportationExpense({
    required int vehicleId,
    required int categoryId,
    required String title,
    required String refNo,
    required double amount,
    required String date,
    required String description,
    File? imageFile,
  }) async {
    try {
      Map<String, dynamic> formData = {
        'vehicle_id': vehicleId.toString(),
        'category_id': categoryId.toString(),
        'title': title,
        'ref_no': refNo,
        'amount': amount.toString(),
        'date': date,
        'description': description,
      };

      // Add image file if provided
      if (imageFile != null) {
        formData['image_pdf'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        );
      }

      final result = await Api.post(
        url: Api.createTransportationExpense,
        useAuthToken: true,
        body: formData,
      );

      return result;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Get transportation expenses
  Future<List<TransportationExpense>> getTransportationExpenses() async {
    try {
      final result = await Api.get(
        url: Api.getTransportationExpenses,
        useAuthToken: true,
      );

      debugPrint("Expense API Response: $result");

      final List<dynamic> expensesData = result['data'] ?? [];
      debugPrint("Expenses Data Length: ${expensesData.length}");

      final expenses = expensesData.map((item) {
        // The API response has nested structure: item['expense'] contains the actual expense data
        final expenseData = item['expense'] ?? {};
        debugPrint("Processing expense data: $expenseData");
        return TransportationExpense.fromJson(expenseData);
      }).toList();

      debugPrint("Parsed expenses count: ${expenses.length}");
      return expenses;
    } catch (e) {
      debugPrint("Error fetching expenses: $e");
      throw ApiException(e.toString());
    }
  }
}
