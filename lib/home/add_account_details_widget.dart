// add_account_details.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';

class AddAccountDetailsWidget extends StatefulWidget {
  const AddAccountDetailsWidget({Key? key}) : super(key: key);

  @override
  _AddAccountDetailsWidgetState createState() =>
      _AddAccountDetailsWidgetState();
}

class _AddAccountDetailsWidgetState extends State<AddAccountDetailsWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _accountHolderNameController =
      TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _branchNameController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  Future<void> _submitDetails() async {
    if (_formKey.currentState?.validate() != true) return;

    // Check if the PIN and confirmation match
    if (_pinController.text != _confirmPinController.text) {
      setState(() {
        _error = "PIN numbers do not match";
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      setState(() {
        _error = "Authentication token missing";
      });
      return;
    }

    final url = "http://10.0.2.2:8000/api/add_account_details/";
    final data = {
      'account_number': _accountNumberController.text,
      'account_holder_name': _accountHolderNameController.text,
      'bank_name': _bankNameController.text,
      'branch_name': _branchNameController.text,
      'ifsc_code': _ifscCodeController.text,
      'pin_no': _pinController.text, // new field for PIN
    };

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        // After successful submission, navigate to the Home page.
        context.pushNamed('home');
      } else {
        setState(() {
          _error = "Error: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _error = "An error occurred: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountHolderNameController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    _ifscCodeController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Account Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _accountNumberController,
                decoration:
                    const InputDecoration(labelText: "Account Number"),
                validator: (value) =>
                    value?.isEmpty == true ? "Enter account number" : null,
              ),
              TextFormField(
                controller: _accountHolderNameController,
                decoration: const InputDecoration(
                    labelText: "Account Holder Name"),
                validator: (value) =>
                    value?.isEmpty == true ? "Enter account holder name" : null,
              ),
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(labelText: "Bank Name"),
                validator: (value) =>
                    value?.isEmpty == true ? "Enter bank name" : null,
              ),
              TextFormField(
                controller: _branchNameController,
                decoration: const InputDecoration(labelText: "Branch Name"),
                validator: (value) =>
                    value?.isEmpty == true ? "Enter branch name" : null,
              ),
              TextFormField(
                controller: _ifscCodeController,
                decoration: const InputDecoration(labelText: "IFSC Code"),
                validator: (value) =>
                    value?.isEmpty == true ? "Enter IFSC code" : null,
              ),
              TextFormField(
                controller: _pinController,
                decoration:
                    const InputDecoration(labelText: "PIN (4 digits)"),
                obscureText: true,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter PIN';
                  }
                  if (value.length != 4) {
                    return 'PIN must be 4 digits';
                  }
                  if (!RegExp(r'^[0-9]{4}$').hasMatch(value)) {
                    return 'PIN must be numeric';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPinController,
                decoration:
                    const InputDecoration(labelText: "Re-enter PIN"),
                obscureText: true,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Re-enter PIN';
                  }
                  if (value.length != 4) {
                    return 'PIN must be 4 digits';
                  }
                  if (!RegExp(r'^[0-9]{4}$').hasMatch(value)) {
                    return 'PIN must be numeric';
                  }
                  if (value != _pinController.text) {
                    return 'PINs do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitDetails,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
