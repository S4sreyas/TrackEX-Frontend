import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'manual_model.dart';
export 'manual_model.dart';
import 'dart:convert';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'manual_model.dart';
export 'manual_model.dart';

class ManualWidget extends StatefulWidget {
  const ManualWidget({super.key});

  @override
  State<ManualWidget> createState() => _ManualWidgetState();
}

class _ManualWidgetState extends State<ManualWidget> {
  late ManualModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Controllers for our text fields
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  // New controller for category description input
  final TextEditingController categoryDescriptionController = TextEditingController();

  // Variable to hold the selected date
  DateTime? _selectedDate;

  // Currently selected category (fetched from backend)
  String? _selectedCategory;

  // Currently selected payment method
  String? _selectedPaymentMethod;

  // Variable to display feedback message
  String _feedbackMessage = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ManualModel());
  }

  @override
  void dispose() {
    amountController.dispose();
    dateController.dispose();
    categoryDescriptionController.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        // Format the date as YYYY-MM-DD for the backend
        dateController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _resetForm() {
    // Clear text fields and reset selected values.
    amountController.clear();
    dateController.clear();
    categoryDescriptionController.clear();
    setState(() {
      _selectedDate = null;
      _selectedCategory = null;
      _selectedPaymentMethod = null;
    });
  }

  // This method sends the transaction data to the backend.
  Future<void> _handleAddTransaction() async {
    // Check if any field is empty.
    if (amountController.text.isEmpty ||
        dateController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedPaymentMethod == null ||
        categoryDescriptionController.text.isEmpty) {
      setState(() {
        _feedbackMessage = 'Please fill all fields';
      });
      return;
    }

    // Retrieve the token from SharedPreferences (saved during login)
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    if (token == null) {
      setState(() {
        _feedbackMessage = 'User is not authenticated. Please log in.';
      });
      return;
    }

    // Prepare the transaction data including payment method and category description
    final Map<String, dynamic> payload = {
      'category_name': _selectedCategory,
      'category_description': categoryDescriptionController.text,
      'amount': amountController.text,
      'date': dateController.text, // Ensure your backend accepts this format
      'payment_method': _selectedPaymentMethod,
    };

    // Define the URL of your backend endpoint (adjust as needed)
    const String url = 'http://10.0.2.2:8000/api/transactions/add/';

    // Set up headers including the token (using Bearer scheme)
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      // Send POST request
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(payload),
      );

      // If the backend returns a 201, the transaction was added successfully
      if (response.statusCode == 201) {
        setState(() {
          _feedbackMessage = 'Transaction has been added successfully';
        });
        _resetForm();
      } else {
        // Decode error message from the response, if any.
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _feedbackMessage =
              data['error'] ?? 'Failed to add transaction. Please try again.';
        });
      }
    } catch (error) {
      setState(() {
        _feedbackMessage = 'An error occurred: $error';
      });
    }
  }

  // Function to fetch categories from the backend.
  Future<List<String>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/categories/'), // adjust URL as needed
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      // Assuming backend returns a list of objects with a 'name' field.
      return jsonList.map((e) => e['name'] as String).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Unfocus text fields when tapping outside.
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
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
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Add Transaction',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 7.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount input field
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (₹)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Date input field with date picker
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16.0),

                // Category dropdown field using categories fetched from the backend.
                FutureBuilder<List<String>>(
                  future: fetchCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No categories found.');
                    }
                    final categories = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCategory,
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16.0),

                // New input field for category description
                TextFormField(
                  controller: categoryDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Category Description',
                    hintText: 'Electricity Bill',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Payment Method dropdown field
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedPaymentMethod,
                  items: <String>[
                    'Cash',
                    'Credit Card',
                    'Debit Card',
                    'UPI',
                    'Net Banking'
                  ].map((String method) {
                    return DropdownMenuItem<String>(
                      value: method,
                      child: Text(method),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPaymentMethod = newValue;
                    });
                  },
                ),
                const SizedBox(height: 24.0),

                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: const Color(0xFF014872),
                //     elevation: 3.0,
                //     fixedSize: const Size(double.infinity, 50.0),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8.0),
                //       side: const BorderSide(color: Colors.transparent, width: 1.0),
                //     ),
                //   ),
                //   onPressed: _handleAddTransaction,
                //     child: Text(
                //       'Add transaction',
                //       style: FlutterFlowTheme.of(context).titleSmall.override(
                //         fontFamily: 'Inter',
                //         color: Colors.white,
                //       ),
                //     ),
                //   ),
                Center( // Wrap the button inside Center
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF014872),
                      elevation: 3.0,
                      fixedSize: const Size(200, 50), // Adjust width as needed
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.transparent, width: 1.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    onPressed: _handleAddTransaction,
                        child: Text(
                          'Add transaction',
                          style: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Inter',
                            color: Colors.white,
                          ),
                        ),
                      ),
                ),
                    // child: Text(
                    //   'Add transaction',
                    //   style: FlutterFlowTheme.of(context).titleSmall.override(
                    //     fontFamily: 'Inter',
                    //     color: Colors.white,
                    //   ),
                    // ),
                  //),
                //),

                // Feedback message below the button
                if (_feedbackMessage.isNotEmpty) ...[
                  const SizedBox(height: 12.0),
                  Text(
                    _feedbackMessage,
                    style: TextStyle(
                      color: _feedbackMessage == 'Transaction has been added successfully'
                          ? Colors.green
                          : Colors.red,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
