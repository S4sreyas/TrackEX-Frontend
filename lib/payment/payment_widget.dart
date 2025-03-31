import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'payment_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
export 'payment_model.dart';

class PaymentWidget extends StatefulWidget {
  const PaymentWidget({super.key});

  @override
  State<PaymentWidget> createState() => _PaymentWidgetState();
}

class _PaymentWidgetState extends State<PaymentWidget> {
  late PaymentModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Variables to show error/success messages
  String? _errorMessage;
  String? _successMessage;

  // Local state to control PIN visibility
  bool _isPinObscured = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaymentModel());

    _model.textController1 ??= TextEditingController(); // Recipient Account Number
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController(); // Recipient Name
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController(); // Amount
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController4 ??= TextEditingController(); // IFSC Code
    _model.textFieldFocusNode4 ??= FocusNode();

    // New: PIN controller and focus node
    _model.textController5 ??= TextEditingController(); // PIN
    _model.textFieldFocusNode5 ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Function to perform the payment.
  Future<void> _performPayment() async {
    // Retrieve token from shared preferences.
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      setState(() {
        _errorMessage = 'Authentication token not found. Please log in again.';
      });
      return;
    }

    final accountNumber = _model.textController1.text.trim();
    final recipientName = _model.textController2.text.trim();
    final amountText = _model.textController3.text.trim();
    final recipientIFSC = _model.textController4.text.trim();
    final pin = _model.textController5.text.trim();

    if (accountNumber.isEmpty ||
        recipientName.isEmpty ||
        amountText.isEmpty ||
        recipientIFSC.isEmpty ||
        pin.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      setState(() {
        _errorMessage = 'Please enter a valid 4-digit PIN.';
      });
      return;
    }

    double amount;
    try {
      amount = double.parse(amountText);
      if (amount <= 0) {
        setState(() {
          _errorMessage = 'Amount must be positive.';
        });
        return;
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid amount entered.';
      });
      return;
    }

    final url = 'http://10.0.2.2:8000/api/payment/process/'; // Update with your backend URL
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'account_number': accountNumber,
          'recipient_name': recipientName,
          'ifsc_code': recipientIFSC,
          'amount': amount,
          'pin_no': pin, // New field: PIN number sent to backend.
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _errorMessage = null;
          _successMessage = data['detail'] ?? 'Payment successful.';
        });
      } else {
        setState(() {
          _successMessage = null;
          _errorMessage = data['error'] ?? 'Payment failed. Please try again.';
        });
      }
    } catch (error) {
      setState(() {
        _successMessage = null;
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if error message indicates missing bank details.
    bool showAddDetailsButton = _errorMessage != null &&
        _errorMessage!.contains('Please add bank details before making a payment.');

    return GestureDetector(
      onTap: () {
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
            borderRadius: 30,
            borderWidth: 1,
            buttonSize: 60,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () async {
              context.pushNamed('home');
            },
          ),
          title: Text(
            'Payment',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 0.0,
                ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 7,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Recipient Account Number Field
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 20, 10, 0),
                  child: TextFormField(
                    controller: _model.textController1,
                    focusNode: _model.textFieldFocusNode1,
                    decoration: InputDecoration(
                      labelText: 'Recipient Account Number',
                      hintText: 'Enter Account number',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                    validator: _model.textController1Validator.asValidator(context),
                  ),
                ),
                // Recipient Name Field
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 20, 10, 0),
                  child: TextFormField(
                    controller: _model.textController2,
                    focusNode: _model.textFieldFocusNode2,
                    decoration: InputDecoration(
                      labelText: 'Recipient Name',
                      hintText: 'Enter name',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                    validator: _model.textController2Validator.asValidator(context),
                  ),
                ),
                // IFSC Code Field
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 20, 10, 0),
                  child: TextFormField(
                    controller: _model.textController4,
                    focusNode: _model.textFieldFocusNode4,
                    decoration: InputDecoration(
                      labelText: 'IFSC Code',
                      hintText: 'Enter IFSC Code',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                    validator: _model.textController4Validator.asValidator(context),
                  ),
                ),
                // Amount Field
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 20, 10, 0),
                  child: TextFormField(
                    controller: _model.textController3,
                    focusNode: _model.textFieldFocusNode3,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      hintText: 'Enter amount',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                    validator: _model.textController3Validator.asValidator(context),
                  ),
                ),
                // New: PIN Input Field
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 20, 10, 0),
                  child: TextFormField(
                    controller: _model.textController5,
                    focusNode: _model.textFieldFocusNode5,
                    obscureText: _isPinObscured,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter PIN',
                      hintText: '4-digit PIN',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPinObscured ? Icons.visibility_off : Icons.visibility,
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPinObscured = !_isPinObscured;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter PIN';
                      }
                      if (value.length != 4) {
                        return 'PIN must be 4 digits';
                      }
                      if (!RegExp(r'^\d{4}$').hasMatch(value)) {
                        return 'PIN must be numeric';
                      }
                      return null;
                    },
                  ),
                ),
                // Proceed Button
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 50, 20, 0),
                  child: FFButtonWidget(
                    onPressed: _performPayment,
                    text: 'Proceed',
                    options: FFButtonOptions(
                      height: 40,
                      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                      color: const Color(0xFF014872),
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Inter Tight',
                            color: Colors.white,
                            letterSpacing: 0.0,
                          ),
                      elevation: 0,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                // Conditionally show the "Add Acc Details" button
                if (showAddDetailsButton)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
                    child: FFButtonWidget(
                      onPressed: () {
                        // Navigate to the add account details page.
                        context.pushNamed('addAccountDetails');
                      },
                      text: 'Add Bank Details',
                      options: FFButtonOptions(
                        height: 40,
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                        color: Colors.blue,
                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: 'Inter Tight',
                              color: Colors.white,
                              letterSpacing: 0.0,
                            ),
                        elevation: 0,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                // Display Error or Success Message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (_successMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _successMessage!,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

