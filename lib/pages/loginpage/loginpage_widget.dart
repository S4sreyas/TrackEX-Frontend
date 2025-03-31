import 'package:shared_preferences/shared_preferences.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'loginpage_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
export 'loginpage_model.dart';

class LoginpageWidget extends StatefulWidget {
  const LoginpageWidget({super.key});

  @override
  State<LoginpageWidget> createState() => _LoginpageWidgetState();
}

class _LoginpageWidgetState extends State<LoginpageWidget> {
  late LoginpageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Variable to store error messages from the backend
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginpageModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Function to perform login by calling the backend API
  

Future<void> _performLogin() async {
  if (_model.formKey.currentState == null ||
      !_model.formKey.currentState!.validate()) {
    return;
  }

  final username = _model.textController1.text.trim();
  final password = _model.textController2.text.trim();

  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/accounts/login/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final String? token = data['token']; // Extract token

      if (token != null) {
        // Store token in shared preferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
      }

      setState(() {
        _errorMessage = null;
      });

      // Navigate to the home page
      context.pushNamed(
        'home',
        extra: <String, dynamic>{
          kTransitionInfoKey: TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.bottomToTop,
          ),
        },
      );
    } else {
      setState(() {
        _errorMessage =
            data['error'] ?? 'Login failed. Please check your credentials.';
      });
    }
  } catch (error) {
    setState(() {
      _errorMessage = 'An error occurred. Please try again.';
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Unfocus fields when tapping outside.
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: AppBar(
            backgroundColor: const Color(0xFF014872),
            automaticallyImplyLeading: false,
            title: Align(
              alignment: AlignmentDirectional.center,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 20.0),
                child: Text(
                  'TrackEX',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Oswald',
                        color: Colors.white,
                        fontSize: 30.0,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            ),
            actions: const [],
            centerTitle: true,
            elevation: 7.0,
          ),
        ),
        body: SafeArea(
          top: true,
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [Color(0xFF014872), Color(0xFFD7EDE1)],
                stops: const [0.0, 1.0],
                begin: AlignmentDirectional.topCenter,
                end: AlignmentDirectional.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(height: 60.0),
                  Text(
                    'Welcome To TrackEX !!',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                          fontFamily: 'Inter Tight',
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          fontSize: 30.0,
                          letterSpacing: 0.0,
                          lineHeight: 2.0,
                        ),
                  ),
                  const SizedBox(height: 30.0),
                  Text(
                    'Login',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                          fontFamily: 'Inter Tight',
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          fontSize: 25.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(27.0, 30.0, 25.0, 0.0),
                    child: Form(
                      key: _model.formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          // Username/Email Field
                          TextFormField(
                            controller: _model.textController1,
                            focusNode: _model.textFieldFocusNode1,
                            decoration: InputDecoration(
                              hintText: 'username or email',
                              filled: true,
                              fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFFBDBABA)),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0x00000000)),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) =>
                                _model.textController1Validator?.call(context, value) ?? null,
                          ),
                          const SizedBox(height: 30.0),
                          // Password Field
                          TextFormField(
                            controller: _model.textController2,
                            focusNode: _model.textFieldFocusNode2,
                            obscureText: !_model.passwordVisibility,
                            decoration: InputDecoration(
                              hintText: 'password',
                              filled: true,
                              fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFFBDBABA)),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0x00000000)),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              suffixIcon: InkWell(
                                onTap: () => setState(() {
                                  _model.passwordVisibility = !_model.passwordVisibility;
                                }),
                                child: Icon(
                                  _model.passwordVisibility
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 22,
                                ),
                              ),
                            ),
                            validator: (value) =>
                                _model.textController2Validator?.call(context, value) ?? null,
                          ),
                          const SizedBox(height: 30.0),
                          // Error message display
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
                            ),
                          const SizedBox(height: 30.0),
                          // Login Button
                          FFButtonWidget(
                            onPressed: () async {
                              await _performLogin();
                            },
                            text: 'Login',
                            options: FFButtonOptions(
                              width: 390.0,
                              height: 50.0,
                              color: const Color(0xFF014872),
                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'Inter Tight',
                                    color: Colors.white,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          // Link to Signup Page
                          Text(
                            'Don\'t have an account? Create one',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Inter',
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                ),
                          ),
                          const SizedBox(height: 20.0),
                          FFButtonWidget(
                            onPressed: () async {
                              context.pushNamed('signup');
                            },
                            text: 'Sign up',
                            options: FFButtonOptions(
                              height: 50.0,
                              color: const Color(0xFF014872),
                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'Inter Tight',
                                    color: Colors.white,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
