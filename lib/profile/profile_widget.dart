import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'profile_model.dart';
export 'profile_model.dart';

// Imports for HTTP calls, token retrieval, input formatting, and JSON handling.
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  static String routeName = 'profile';
  static String routePath = '/profile';

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late ProfileModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Variables to store the fetched account holder name and account number.
  String? _accountHolderName;
  String? _accountNumber;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileModel());
    _fetchAccountHolderName();
    _fetchAccountNumber();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Fetches the account holder name from the backend.
  Future<void> _fetchAccountHolderName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    if (token == null) {
      debugPrint("Token not found.");
      return;
    }
    final url = Uri.parse(
        'http://10.0.2.2:8000/api/profilee/account-holder/?token=$token');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _accountHolderName = data['account_holder_name'];
        });
      } else {
        debugPrint("Error fetching account holder name: ${response.body}");
      }
    } catch (e) {
      debugPrint("Exception in fetching account holder name: $e");
    }
  }

  // Fetches the account number from the backend.
  Future<void> _fetchAccountNumber() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    if (token == null) {
      debugPrint("Token not found.");
      return;
    }
    final url = Uri.parse(
        'http://10.0.2.2:8000/api/profilee/account-number/?token=$token');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _accountNumber = data['account_number'];
        });
      } else {
        debugPrint("Error fetching account number: ${response.body}");
      }
    } catch (e) {
      debugPrint("Exception in fetching account number: $e");
    }
  }

  // Shows a dialog for changing the password and calls the DRF endpoint.
  Future<void> _showChangePasswordDialog() async {
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Old Password",
              ),
            ),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
              ),
            ),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirm New Password",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cancel
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("New passwords do not match.")),
                );
                return;
              }
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              final String? token = prefs.getString('auth_token');
              if (token == null) {
                debugPrint("Token not found.");
                Navigator.pop(context);
                return;
              }
              final url = Uri.parse('http://10.0.2.2:8000/api/profilee/change-password/');
              try {
                final response = await http.post(
                  url,
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: json.encode({
                    'old_password': oldPasswordController.text,
                    'new_password': newPasswordController.text,
                    'confirm_password': confirmPasswordController.text,
                  }),
                );
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password changed successfully.")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${response.body}")),
                  );
                }
              } catch (e) {
                debugPrint("Exception in changing password: $e");
              }
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Shows a dialog for changing the PIN and calls the DRF endpoint.
  Future<void> _showChangePinDialog() async {
    TextEditingController oldPinController = TextEditingController();
    TextEditingController newPinController = TextEditingController();
    TextEditingController confirmPinController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change PIN"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: "Old PIN",
                counterText: "",
              ),
            ),
            TextField(
              controller: newPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: "New PIN",
                counterText: "",
              ),
            ),
            TextField(
              controller: confirmPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: "Confirm New PIN",
                counterText: "",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cancel
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (newPinController.text != confirmPinController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("New PINs do not match.")),
                );
                return;
              }
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              final String? token = prefs.getString('auth_token');
              if (token == null) {
                debugPrint("Token not found.");
                Navigator.pop(context);
                return;
              }
              final url = Uri.parse('http://10.0.2.2:8000/api/profilee/change-pin/');
              try {
                final response = await http.post(
                  url,
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: json.encode({
                    'old_pin': oldPinController.text,
                    'new_pin': newPinController.text,
                    'confirm_pin': confirmPinController.text,
                  }),
                );
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("PIN changed successfully.")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${response.body}")),
                  );
                }
              } catch (e) {
                debugPrint("Exception in changing PIN: $e");
              }
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            'Profile',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 0.0,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF014872), const Color(0xFF53ACA2)],
                stops: const [0, 1],
                begin: AlignmentDirectional(0, -1),
                end: AlignmentDirectional(0, 1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Display the fetched account holder name.
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(10, 15, 0, 0),
                      child: Text(
                        _accountHolderName ?? 'Loading...',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              fontSize: 20,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
                // Display the fetched account number.
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 0, 0),
                      child: Text(
                        _accountNumber ?? 'Loading account number...',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              fontSize: 18,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
                // Change Password Button
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(40, 30, 10, 0),
                      child: FFButtonWidget(
                        onPressed: () {
                          _showChangePasswordDialog();
                        },
                        text: 'Change Password',
                        options: FFButtonOptions(
                          width: 370,
                          height: 40,
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                          iconPadding:
                              const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: FlutterFlowTheme.of(context).alternate,
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Inter Tight',
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                              ),
                          elevation: 0,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                // Change PIN Button
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(40, 10, 10, 0),
                      child: FFButtonWidget(
                        onPressed: () {
                          _showChangePinDialog();
                        },
                        text: 'Change PIN',
                        options: FFButtonOptions(
                          width: 370,
                          height: 40,
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                          iconPadding:
                              const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: FlutterFlowTheme.of(context).alternate,
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Inter Tight',
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                              ),
                          elevation: 0,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
