import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

// Model for a transaction.
class TransactionModel {
  final String category;
  final double amount;
  // Combined date and time string (e.g. "2025-02-01 16:00:49")
  final String date;
  final String description; // New field for description

  TransactionModel({
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Combine the separate date and time fields from the JSON.
    String combinedDateTime = '';
    if (json.containsKey('date') && json.containsKey('time')) {
      combinedDateTime = '${json['date']} ${json['time']}';
    } else if (json.containsKey('date')) {
      combinedDateTime = json['date'];
    }
    return TransactionModel(
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: combinedDateTime,
      description: json['description'] as String? ?? '',
    );
  }
}

// Function to fetch the last 3 transactions from the backend.
Future<List<TransactionModel>> fetchRecentTransactions() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  if (token == null) {
    throw Exception('No token found');
  }
  // Replace with your actual backend URL.
  final url = 'http://10.0.2.2:8000/api/transactions/latest/';
  final response = await http.get(Uri.parse(url), headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  });

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList
        .map((json) =>
            TransactionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  } else if (response.statusCode == 404) {
    // If no transactions found, return an empty list.
    return [];
  } else {
    throw Exception('Failed to load transactions');
  }
}

class RecentTransactionsWidget extends StatelessWidget {
  const RecentTransactionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TransactionModel>>(
      future: fetchRecentTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Instead of showing an error message, show a friendly message.
          return const Center(
              child: Text('No transactions available right now.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('No transactions available right now.'));
        }
        final transactions = snapshot.data!;
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 24),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: transactions.map((tx) {
              // Parse the combined date string into a DateTime object.
              DateTime dt;
              try {
                // Replace the space with 'T' for proper ISO8601 parsing.
                String isoDateTime = tx.date.replaceFirst(' ', 'T');
                dt = DateTime.parse(isoDateTime);
              } catch (e) {
                dt = DateTime.now();
              }
              // Format the date as "dd-MM-yyyy" (e.g., "12-10-2025").
              String formattedDate = DateFormat('dd-MM-yyyy').format(dt);
              // Format the time in 12-hour format with AM/PM (e.g., "04:00 PM").
              String formattedTime = DateFormat('hh:mm a').format(dt);

              // Combine into one display string.
              String displayTimestamp = '$formattedDate, $formattedTime';

              return Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.92,
                  height: 80, // Increased height to accommodate description.
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context)
                        .secondaryBackground,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 3,
                        //color: Color(0x35000000),
                        color:Colors.grey,

                        offset: Offset(0.0, 1),
                      )
                    ],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context)
                          .primaryBackground,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Display category and description.
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.category,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyLarge
                                      .override(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tx.description,
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                        //color: FlutterFlowTheme.of(context).secondaryText,
                                        color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Display amount and combined date/time.
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹ ${tx.amount.toStringAsFixed(2)}',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                                child: Text(
                                  displayTimestamp,
                                  textAlign: TextAlign.end,
                                  style: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        //color: FlutterFlowTheme.of(context).secondaryText,
                                        fontSize: 14,
                                        letterSpacing: 0.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,

                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
