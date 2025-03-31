import 'dart:convert';
import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:http/http.dart' as http;
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntertainmentWidget extends StatefulWidget {
  const EntertainmentWidget({Key? key}) : super(key: key);

  @override
  _EntertainmentWidgetState createState() => _EntertainmentWidgetState();
}

class _EntertainmentWidgetState extends State<EntertainmentWidget> {
  TextEditingController? budgetController;
  bool isEditable = true; // Controls whether the user can edit the budget.
  String displayBudget = '0'; // Displayed budget value.
  final String categoryName = 'ENTERTAINMENT';
  String? token; // Retrieved token from SharedPreferences.
  // Backend base URL for local development.
  final String backendBaseUrl = 'http://10.0.2.2:8000/api/categorize';

  // Variable to store the total expense for the category.
  String _expense = "0";

  // Flag to track if a budget record already exists.
  bool _budgetExists = false;

  @override
  void initState() {
    super.initState();
    budgetController = TextEditingController(text: '0');
    _loadTokenAndFetchData();
  }

  Future<void> _loadTokenAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('auth_token');
    });
    if (token != null) {
      fetchBudget();
      fetchExpense();
    } else {
      debugPrint("Token not found, user might not be authenticated.");
    }
  }

  @override
  void dispose() {
    budgetController?.dispose();
    super.dispose();
  }

  Future<void> fetchBudget() async {
    if (token == null) {
      debugPrint("Token is null, cannot fetch budget.");
      return;
    }
    final url = Uri.parse('$backendBaseUrl/budget/?token=$token&category_name=$categoryName');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['budget'] == null) {
          debugPrint("Budget is null");
          setState(() {
            _budgetExists = false;
            isEditable = true;
          });
        } else {
          setState(() {
            displayBudget = data['budget'].toString();
            budgetController!.text = displayBudget;
            isEditable = false;
            _budgetExists = true;
          });
        }
      } else if (response.statusCode == 404) {
        // No budget exists – allow the user to enter a value.
        setState(() {
          isEditable = true;
          _budgetExists = false;
        });
      } else {
        debugPrint('Error fetching budget: ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception in fetchBudget: $e');
    }
  }

  Future<void> fetchExpense() async {
    if (token == null) {
      debugPrint("Token is null, cannot fetch expense.");
      return;
    }
    final url = Uri.parse('$backendBaseUrl/expense/?token=$token&category_name=$categoryName');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Expect a list of expense records under the key "expenses".
        List expenses = data["expenses"] ?? [];
        double total = 0.0;
        for (var expense in expenses) {
          total += double.tryParse(expense["amount"].toString()) ?? 0.0;
        }
        setState(() {
          _expense = total.toStringAsFixed(2);
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _expense = "0";
        });
      } else {
        debugPrint('Error fetching expense: ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception in fetchExpense: $e');
    }
  }

  Future<void> submitBudget(String budget) async {
    if (token == null) {
      debugPrint("Token is null, cannot submit budget.");
      return;
    }
    // Choose endpoint based on whether a budget record exists.
    final String endpoint = _budgetExists
        ? '$backendBaseUrl/budget/update/'
        : '$backendBaseUrl/budget/insert/';
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'category_name': categoryName,
          'budget': budget,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          displayBudget = budget;
          isEditable = false;
          _budgetExists = true;
        });
        debugPrint('Budget submitted successfully.');
      } else {
        debugPrint('Error submitting budget: ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception in submitBudget: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse current budget and expense as doubles.
    double currentBudget = double.tryParse(displayBudget) ?? 0.0;
    double spent = double.tryParse(_expense) ?? 0.0;
    double overSpent = spent - currentBudget;

    return Container(
      width: 150.0,
      height: 240.0, // Increased height to accommodate additional message.
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Title row with gradient text.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                child: GradientText(
                  'ENTERTAINMENT',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                  colors: const [Color(0xFF014872), Color(0xFF53ACA2)],
                  gradientDirection: GradientDirection.ttb,
                  gradientType: GradientType.linear,
                ),
              ),
            ],
          ),
          // Budget input row with an edit icon.
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(5.0, 20.0, 5.0, 0.0),
            child: Row(
              children: [
                SizedBox(
                  width: 90.0, // Reduced width for the input box.
                  child: TextFormField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    enabled: isEditable,
                    decoration: InputDecoration(
                      labelText: 'Budget',
                      hintText: 'Enter Budget',labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter',
                          fontSize: 18.0,
                          letterSpacing: 0.0,
                        ),
                    onFieldSubmitted: (value) {
                      submitBudget(value);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    setState(() {
                      isEditable = true;
                    });
                  },
                ),
              ],
            ),
          ),
          // Expense row (static display).
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(5.0, 20.0, 5.0, 0.0),
            child: Text(
              'Spent : $_expense',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Inter',
                    fontSize: 18.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          // Conditional message if expense exceeds budget.
          if (spent > currentBudget)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(5, 10, 5, 0),
              child: Text(
                'Rs${overSpent.toStringAsFixed(2)}  over spent',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter',
                      fontSize: 16.0,
                      color: Colors.red,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
