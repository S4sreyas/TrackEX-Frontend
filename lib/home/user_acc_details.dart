import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'dart:async';

class AccountDisplayWidget extends StatefulWidget {
  const AccountDisplayWidget({Key? key}) : super(key: key);

  @override
  _AccountDisplayWidgetState createState() => _AccountDisplayWidgetState();
}

class _AccountDisplayWidgetState extends State<AccountDisplayWidget> {
  bool _loading = true;
  bool _error = false;
  String? _accountNumber;
  double? _balance;
  int _daysLeft = 0;
  double _totalSpent = 0.0;
  bool _showBalance = false; // controls whether the balance is visible

  @override
  void initState() {
    super.initState();
    _calculateDaysLeft();
    _fetchAccountDetails();
  }

  void _calculateDaysLeft() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    _daysLeft = lastDayOfMonth.day - now.day;
  }

  Future<void> _fetchAccountDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print("No token found in SharedPreferences");
      setState(() {
        _error = true;
        _loading = false;
      });
      return;
    }

    const String accountApiUrl = "http://10.0.2.2:8000/api/account_details/";
    const String expenseApiUrl = "http://10.0.2.2:8000/api/monthly_expense/";

    try {
      print("Fetching account details with token: $token");

      final accountResponse = await http.get(
        Uri.parse(accountApiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      final expenseResponse = await http.get(
        Uri.parse(expenseApiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      // Process expense data.
      if (expenseResponse.statusCode != 200) {
        print("Failed to fetch expense data. Status: ${expenseResponse.statusCode}");
        setState(() {
          _error = true;
          _loading = false;
        });
        return;
      }
      final expenseData = json.decode(expenseResponse.body);
      double expenseValue = double.tryParse(expenseData['total_spent'].toString()) ?? 0.0;

      // Process account details.
      if (accountResponse.statusCode == 200) {
        final accountData = json.decode(accountResponse.body);
        setState(() {
          _accountNumber = accountData['account_number'];
          // For security, the balance is not displayed until the PIN is verified.
          _balance = double.tryParse(accountData['balance']) ?? 0.0;
          _totalSpent = expenseValue;
          _loading = false;
        });
      } else if (accountResponse.statusCode == 404) {
        setState(() {
          _accountNumber = null;
          _balance = null;
          _totalSpent = expenseValue;
          _loading = false;
        });
      } else {
        print("Unexpected account response status: ${accountResponse.statusCode}");
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    } catch (e) {
      print("Exception caught while fetching account details: $e");
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  void _onAddAccountDetails() {
    context.pushNamed('addAccountDetails');
  }

  /// Prompts the user to enter a 4-digit PIN.
  void _promptForPin() {
    showDialog(
      context: context,
      builder: (context) {
        String pin = "";
        return AlertDialog(
          title: const Text("Enter 4-digit PIN"),
          content: TextField(
            obscureText: true,
            maxLength: 4,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "PIN",
            ),
            onChanged: (value) {
              pin = value;
            },
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Submit"),
              onPressed: () async {
                if (pin.length == 4) {
                  bool verified = await _verifyPin(pin);
                  if (verified) {
                    Navigator.of(context).pop();
                    _showBalanceFor5Seconds();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Incorrect PIN")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter a valid 4-digit PIN")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Verifies the entered PIN by calling the backend DRF verify_pin endpoint.
  Future<bool> _verifyPin(String enteredPin) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      return false;
    }

    const String verifyPinUrl = "http://10.0.2.2:8000/api/verify_pin/";
    try {
      final response = await http.post(
        Uri.parse(verifyPinUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'pin': enteredPin}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Update the balance with the verified balance from the backend.
        setState(() {
          _balance = double.tryParse(data['balance'].toString()) ?? _balance;
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error verifying PIN: $e");
      return false;
    }
  }

  /// Displays the balance for 5 seconds and then reverts back to the info icon.
  void _showBalanceFor5Seconds() {
    setState(() {
      _showBalance = true;
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showBalance = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : _error
            ? const Center(child: Text("An error occurred."))
            : (_accountNumber == null || _balance == null)
                ? _buildNoAccountDetailsBox(context)
                : _buildAccountDetailsBox(context);
  }

  Widget _buildAccountDetailsBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 84, 209, 225),
            //Color(0xFFB2EBF2),
            Color(0xFF014872),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account No: $_accountNumber',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Balance display area.
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Balance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // If verified, display balance; otherwise, show an info icon.
                  _showBalance
                      ? Text(
                          '₹${_balance?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      // : IconButton(
                      //     icon: const Icon(Icons.remove_red_eye_outlined, size:32, color: Colors.white,),
                      //     onPressed: _promptForPin,
                      //   ),
                  :Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0), // Adjust as needed
                    child: Tooltip(
                      message: "View Balance",
                      waitDuration: Duration(milliseconds: 500),
                      child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          icon: const Icon(Icons.remove_red_eye_outlined, size: 32, color: Colors.white),
                          onPressed: _promptForPin,
                        ),
                      ),
                    ),
                  )

                ],
              ),
              Padding(
                padding: EdgeInsets.all(10.0), // Padding for the entire Column
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0), // Padding specifically for the Text
                      child: Text(
                        '$_daysLeft Days Left ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )



            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Spent',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900
                ),
              ),
              Text(
                '₹${_totalSpent.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoAccountDetailsBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE0F7FA),
            Color(0xFFB2EBF2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "No Account Details Found",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onAddAccountDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF014872),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Add Account Details"),
            ),
          ],
        ),
      ),
    );
  }
}
