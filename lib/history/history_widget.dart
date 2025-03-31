import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'history_model.dart';
export 'history_model.dart';

class HistoryWidget extends StatefulWidget {
  const HistoryWidget({super.key});

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  late HistoryModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // List of expenses fetched from the backend.
  List<Map<String, dynamic>> _allExpenses = [];
  // List to be displayed (result from the backend filtered query).
  List<Map<String, dynamic>> _filteredExpenses = [];
  // List of categories fetched from the backend.
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HistoryModel());
    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();
    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    // On initial load, fetch expenses and categories.
    _fetchExpenses();
    _fetchCategories();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Fetch categories from the backend.
  Future<void> _fetchCategories() async {
    final url = 'http://10.0.2.2:8000/api/categories/';
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('No token found');
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<String> fetchedCategories =
            data.map((e) => e['name'] as String).toList();
        setState(() {
          _categories = ['All'] + fetchedCategories;
        });
      } else {
        print('Error fetching categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  /// Fetch expenses from the backend.
  Future<void> _fetchExpenses() async {
    final baseUrl = 'http://10.0.2.2:8000/api/expenses/';
    String? startDate =
        _model.textController1.text.isNotEmpty ? _model.textController1.text : null;
    String? endDate =
        _model.textController2.text.isNotEmpty ? _model.textController2.text : null;
    String? category = _model.dropDownValue;
    Map<String, String> queryParams = {};
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (category != null && category.toLowerCase() != 'all') {
      queryParams['category'] = category;
    }
    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('No token found');
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _allExpenses = data.cast<Map<String, dynamic>>();
          _filteredExpenses = List.from(_allExpenses);
        });
      } else {
        print('Error fetching expenses: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching expenses: $e');
    }
  }

  /// Opens a date picker.
  Future<void> _selectDate(TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      _fetchExpenses();
    }
  }

  /// Sends a DELETE request for the expense.
  Future<void> _deleteExpense(Map<String, dynamic> expense) async {
    final expenseId = expense['expense_id'];
    if (expenseId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Expense id not found.')));
      return;
    }
    final url = 'http://10.0.2.2:8000/api/expenses/$expenseId/';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('No token found');
      final response = await http.delete(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 204 || response.statusCode == 200) {
        setState(() {
          _allExpenses.removeWhere((e) => e['expense_id'] == expenseId);
          _filteredExpenses.removeWhere((e) => e['expense_id'] == expenseId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense deleted successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete expense')));
      }
    } catch (e) {
      print('Error deleting expense: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting expense')));
    }
  }

  // Shows a confirmation dialog before deletion.
  void _showDeleteDialog(Map<String, dynamic> expense) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: const Text('Do you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel deletion.
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss dialog.
                await _deleteExpense(expense);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: const Color(0xFF014872),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30.0),
            onPressed: () async {
              context.pushNamed('home');
            },
          ),
          title: Text(
            'Payment History',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  color: Colors.white,
                  fontSize: 22.0,
                ),
          ),
          centerTitle: false,
          elevation: 7.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              // Filter row: Start Date, End Date, and Category.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                color: FlutterFlowTheme.of(context).secondaryBackground,
                child: Row(
                  children: [
                    // Start Date Field.
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: TextFormField(
                          controller: _model.textController1,
                          focusNode: _model.textFieldFocusNode1,
                          readOnly: true,
                          onTap: () async {
                            await _selectDate(_model.textController1!);
                          },
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            hintText: 'yyyy-MM-dd',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 1.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.transparent, width: 1.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor:
                                FlutterFlowTheme.of(context).secondaryBackground,
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      ),
                    ),
                    // End Date Field.
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: TextFormField(
                          controller: _model.textController2,
                          focusNode: _model.textFieldFocusNode2,
                          readOnly: true,
                          onTap: () async {
                            await _selectDate(_model.textController2!);
                          },
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            hintText: 'yyyy-MM-dd',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 1.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.transparent, width: 1.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor:
                                FlutterFlowTheme.of(context).secondaryBackground,
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      ),
                    ),
                    // Category Dropdown.
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: FlutterFlowDropDown<String>(
                          controller: _model.dropDownValueController ??=
                              FormFieldController<String>(null),
                          options: _categories.isNotEmpty ? _categories : ['All'],
                          onChanged: (val) {
                            setState(() {
                              _model.dropDownValue = val;
                            });
                            _fetchExpenses();
                          },
                          width: double.infinity,
                          height: 50.0,
                          textStyle: FlutterFlowTheme.of(context).bodyMedium,
                          hintText: 'Category',
                          icon: Icon(Icons.keyboard_arrow_down_rounded,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 24.0),
                          fillColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          elevation: 2.0,
                          borderColor: FlutterFlowTheme.of(context).alternate,
                          borderWidth: 1.0,
                          borderRadius: 8.0,
                          margin: const EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          hidesUnderline: true,
                          isOverButton: false,
                          isSearchable: false,
                          isMultiSelect: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Expense List.
              Expanded(
                child: _filteredExpenses.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = _filteredExpenses[index];
                          DateTime dt;
                          try {
                            String combined = expense['date'] +
                                'T' +
                                expense['time'];
                            dt = DateTime.parse(combined);
                          } catch (e) {
                            dt = DateTime.now();
                          }
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(dt);
                          String formattedTime =
                              DateFormat('hh:mm a').format(dt);

                          // Build title text.
                          String categoryDisplay = expense['category'];
                          String description = expense['description'] ?? '';
                          String paymentMethod = expense['payment_method'] ?? '';
                          String titleText = paymentMethod.toLowerCase() ==
                                  'account transfer'
                              ? '$categoryDisplay ($description)'
                              : '$categoryDisplay ($description) • $paymentMethod';

                          return Card(
                            margin:
                                const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(titleText,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium),
                              subtitle: Text(
                                  '$formattedDate, $formattedTime'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('₹${expense['amount']}',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium),
                                  // Only "Delete" option is provided now.
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _showDeleteDialog(expense);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) =>
                                        [
                                      const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          'No expenses found for the selected criteria.',
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
