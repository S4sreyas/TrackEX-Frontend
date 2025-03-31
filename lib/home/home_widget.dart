import 'package:loginmain/home/user_acc_details.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_model.dart';
export 'home_model.dart';

// Import your recent transactions widget file (adjust the path as needed)
import 'recent_transactions.dart';

// Import necessary packages for HTTP requests and shared preferences
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late HomeModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Variable to hold the fetched username
  String? _username;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());
    _fetchAccountHolderName();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Fetches the account holder name from the backend.
  Future<void> _fetchAccountHolderName() async {
    // Retrieve the token from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    if (token == null) {
      debugPrint("Token not found.");
      return;
    }

    // Construct the GET URL. Adjust domain/port if necessary.
    final url = Uri.parse(
        'http://10.0.2.2:8000/api/profilee/account-holder/?token=$token');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _username = data['account_holder_name'];
        });
      } else {
        debugPrint('Error fetching account holder name: ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception in _fetchAccountHolderName: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      drawer: Container(
        width: 200,
        child: Drawer(
          elevation: 16,
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
                Align(
                  alignment: AlignmentDirectional(-1, 0),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(5, 55, 0, 0),
                    child: Text(
                      'Hello',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            color: FlutterFlowTheme.of(context)
                                .primaryBackground,
                            fontSize: 28,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(-1, 0),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(5, 10, 0, 0),
                    child: Text(
                      // Show the fetched username; if null, show a loading indicator or placeholder.
                      _username ?? 'Loading...',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            color: FlutterFlowTheme.of(context)
                                .primaryBackground,
                            fontSize: 20,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 35, 0, 0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      context.pushNamed('profile');
                    },
                    text: 'Profile',
                    icon: const Icon(
                      Icons.person_rounded,
                      size: 16,
                    ),
                    options: FFButtonOptions(
                      width: 200,
                      height: 40,
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                      iconPadding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: const Color(0xFFD3D8D8),
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Inter Tight',
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                          ),
                      elevation: 0,
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      context.pushNamed('logout');
                    },
                    text: 'Logout',
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 16,
                    ),
                    options: FFButtonOptions(
                      width: 200,
                      height: 40,
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                      iconPadding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: const Color(0xFFD3D8D8),
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Inter Tight',
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                          ),
                      elevation: 0,
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF014872),
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30,
          buttonSize: 46,
          icon: const Icon(
            Icons.menu_rounded,
            color: Colors.white,
            size: 25,
          ),
          onPressed: () async {
            scaffoldKey.currentState!.openDrawer();
          },
        ),
        title: Text(
          'TrackEX',
          style: FlutterFlowTheme.of(context).titleSmall.override(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: 22,
                letterSpacing: 0.0,
              ),
        ),
        actions: [],
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Account Display Section using AccountDisplayWidget
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AccountDisplayWidget(),
              ),
              // Navigation Row for Payments, History, etc.
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: const BoxDecoration(),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed('payment');
                            },
                            child: Icon(
                              Icons.currency_rupee_rounded,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 40,
                            ),
                          ),
                          Text(
                            'Pay',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  letterSpacing: 0.0,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                                ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed('history');
                          },
                          child: Icon(
                            Icons.manage_history,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 40,
                          ),
                        ),
                        Text(
                          'Payment History',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: 'Inter',
                                letterSpacing: 0.0,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed('categorize');
                          },
                          child: Icon(
                            Icons.category_rounded,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 40,
                          ),
                        ),
                        Text(
                          'Categories',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: 'Inter',
                                letterSpacing: 0.0,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                              ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed('manual');
                          },
                          child: Icon(
                            Icons.manage_accounts,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 40,
                          ),
                        ),
                        Text(
                          'Manual Entry',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: 'Inter',
                                letterSpacing: 0.0,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Transactions Section - Insert the RecentTransactionsWidget here
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 50, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                      child: Text(
                        'Transactions',
                        style: FlutterFlowTheme.of(context)
                            .labelMedium
                            .override(
                              fontFamily: 'Inter',
                              letterSpacing: 0.0,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          color: Colors.black
                            ),
                      ),
                    ),
                    const RecentTransactionsWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
