import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:eschool_saas_staff/data/models/expense.dart';
import 'package:eschool_saas_staff/cubits/expense/expenseCubit.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/ui/widgets/customAppbar.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/ui/screens/myExpenseScreen/widget/expenseFormWidget.dart';
import 'package:eschool_saas_staff/ui/screens/myExpenseScreen/widget/expenseHistoryWidget.dart';

class MyExpenseScreen extends StatefulWidget {
  const MyExpenseScreen({super.key});

  static Widget getRouteInstance() {
    return BlocProvider(
      create: (context) => ExpenseCubit(),
      child: const MyExpenseScreen(),
    );
  }

  @override
  State<MyExpenseScreen> createState() => _MyExpenseScreenState();
}

class _MyExpenseScreenState extends State<MyExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

  // Selected values
  Vehicle? _selectedVehicle;
  ExpenseCategory? _selectedCategory;
  File? _selectedFile;

  // Data lists
  List<VehicleDetails> _vehicles = [];
  List<ExpenseCategory> _categories = [];
  List<TransportationExpense> _expenses = [];

  @override
  void initState() {
    super.initState();
    context.read<ExpenseCubit>().initializeData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _onFileChanged(File? file) {
    setState(() {
      _selectedFile = file;
    });
  }

  void _onVehicleChanged(Vehicle? vehicle) {
    setState(() {
      _selectedVehicle = vehicle;
    });
  }

  void _onCategoryChanged(ExpenseCategory? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _submitExpense() {
    if (_formKey.currentState!.validate()) {
      if (_selectedVehicle == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomTextContainer(
              textKey: pleaseSelectVehicleKey,
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomTextContainer(
              textKey: pleaseSelectCategoryKey,
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Generate current date in dd-MM-yyyy format
      final currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

      // Generate reference number (you can customize this logic)
      final refNo =
          DateTime.now().millisecondsSinceEpoch.toString().substring(8);

      context.read<ExpenseCubit>().createExpense(
            vehicleId: _selectedVehicle!.id,
            categoryId: _selectedCategory!.id,
            title: _selectedCategory!.name,
            refNo: refNo,
            amount: double.parse(_amountController.text),
            date: currentDate,
            description: _reasonController.text,
            imageFile: _selectedFile,
          );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _amountController.clear();
    _reasonController.clear();
    setState(() {
      _selectedVehicle = null;
      _selectedCategory = null;
      _selectedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppbar(
        titleKey: myExpensesKey,
        showBackButton: true,
      ),
      body: BlocConsumer<ExpenseCubit, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _resetForm();
          } else if (state is ExpenseCreateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is CategoriesFetchSuccess) {
            setState(() {
              _categories = state.categories;
            });
          } else if (state is VehiclesFetchSuccess) {
            setState(() {
              _vehicles = state.vehicles;
            });
          } else if (state is ExpensesFetchSuccess) {
            setState(() {
              _expenses = state.expenses;
            });
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(appContentHorizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Expense Form Widget
                ExpenseFormWidget(
                  formKey: _formKey,
                  amountController: _amountController,
                  reasonController: _reasonController,
                  vehicles: _vehicles,
                  categories: _categories,
                  selectedVehicle: _selectedVehicle,
                  selectedCategory: _selectedCategory,
                  selectedFile: _selectedFile,
                  onVehicleChanged: _onVehicleChanged,
                  onCategoryChanged: _onCategoryChanged,
                  onFileChanged: _onFileChanged,
                ),

                const SizedBox(height: 32),

                // Expense History Widget
                ExpenseHistoryWidget(
                  expenses: _expenses,
                ),

                const SizedBox(height: 100), // Space for submit button
              ],
            ),
          );
        },
      ),
      // Submit Button
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(appContentHorizontalPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BlocBuilder<ExpenseCubit, ExpenseState>(
            builder: (context, state) {
              final isLoading = state is ExpenseCreateInProgress;

              return ElevatedButton(
                onPressed: isLoading ? null : _submitExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const CustomTextContainer(
                        textKey: submitKey,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
