import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'disptax_model.dart';
export 'disptax_model.dart';

class DisptaxWidget extends StatefulWidget {
  final double oldTax;
  final double newTax;
  final String recommended;
  DisptaxWidget({
    required this.oldTax,
    required this.newTax,
    required this.recommended,
  });

  @override
  State<DisptaxWidget> createState() => _DisptaxWidgetState();
}

class _DisptaxWidgetState extends State<DisptaxWidget> {
  late DisptaxModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DisptaxModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBar(
            backgroundColor: Color(0xFF014872),
            automaticallyImplyLeading: false,
            leading: FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30,
              borderWidth: 1,
              buttonSize: 60,
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () async {
                context.pop();
              },
            ),
            title: Text(
              'Tax Calculator',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Oswald',
                color: Colors.white,
                fontSize: 22,
                letterSpacing: 0.0,
              ),
            ),
            actions: [],
            centerTitle: false,
            elevation: 7,
          ),
        ),
        body: SafeArea(
          top: true,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF014872), Color(0xFFD7EDE1)],
                stops: [0, 1],
                begin: AlignmentDirectional(0, -1),
                end: AlignmentDirectional(0, 1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 200, 0, 30),
                    child: Text(
                      'Old Regime : ₹${widget.oldTax}',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Oswald',
                        color: FlutterFlowTheme.of(context)
                            .secondaryBackground,
                        fontSize: 22,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 30),
                  child: Text(
                    'New Regime :₹${widget.newTax}',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Oswald',
                      color:
                      FlutterFlowTheme.of(context).secondaryBackground,
                      fontSize: 24,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Padding(
                //   padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                //   child: Text(
                //     'The ${widget.recommended} Tax Regime is better !!',
                //     style: FlutterFlowTheme.of(context).bodyMedium.override(
                //       fontFamily: 'Oswald',
                //       color:
                //       FlutterFlowTheme.of(context).secondaryBackground,
                //       fontSize: 30,
                //       letterSpacing: 1.0,
                //       fontWeight: FontWeight.normal,
                //     ),
                //   ),
                // ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                  child: Text(
                    widget.recommended == "Zero Tax"
                        ? "You have Zero Tax!!"
                        : 'The ${widget.recommended} Tax Regime is better !!',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Oswald',
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      fontSize: 30,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.normal,
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
