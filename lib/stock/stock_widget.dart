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

import 'stock_model.dart';
export 'stock_model.dart';

class StockWidget extends StatefulWidget {
  const StockWidget({Key? key}) : super(key: key);

  @override
  State<StockWidget> createState() => _StockWidgetState();
}

class _StockWidgetState extends State<StockWidget> {
  final TextEditingController _investmentController = TextEditingController();

  // Controllers for dynamic stock ticker inputs.
  List<TextEditingController> _stockControllers = [TextEditingController()];

  bool _isLoading = false;
  // Lists for categorized predictions.
  List<dynamic> _recommendedPredictions = [];
  List<dynamic> _otherPredictions = [];

  // Update this with your backend API endpoint.
  final String apiUrl = "http://10.0.2.2:8000/api/stock_prediction/";

  @override
  void dispose() {
    _investmentController.dispose();
    for (var controller in _stockControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addStockField() {
    setState(() {
      _stockControllers.add(TextEditingController());
    });
  }

  Future<void> _fetchPredictions() async {
    // Get the investment amount.
    final investmentText = _investmentController.text.trim();
    final investmentAmount = double.tryParse(investmentText);
    if (investmentAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid investment amount.")),
      );
      return;
    }

    // Gather stock tickers.
    List<String> tickers = [];
    for (var controller in _stockControllers) {
      String ticker = controller.text.trim();
      if (ticker.isNotEmpty) {
        tickers.add(ticker.toUpperCase());
      }
    }
    if (tickers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter at least one stock ticker.")),
      );
      return;
    }

    // Build the payload.
    Map<String, dynamic> payload = {
      "tickers": tickers,
      "investment_amount": investmentAmount
    };

    setState(() {
      _isLoading = true;
      _recommendedPredictions = [];
      _otherPredictions = [];
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _recommendedPredictions = data['recommended_stocks'] ?? [];
          _otherPredictions = data['other_stocks'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching predictions: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
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
              // Navigate back or adjust as necessary.
              context.pushNamed('home');
            },
          ),
          title: Text(
            'Stock Recommendation',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 0.0,
                ),
          ),
          centerTitle: false,
          elevation: 7,
        ),
        body: SafeArea(
          // SafeArea ensures content doesn't render behind system UI.
          child: SingleChildScrollView(
            // Extra bottom padding prevents content from being hidden by a bottom nav bar.
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0),
            child: Column(
              children: [
                // Investment Amount Input.
                TextFormField(
                  controller: _investmentController,
                  decoration: InputDecoration(
                    labelText: "Enter Investment Amount",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Stock Ticker Input Fields.
                Row(
                  children: [
                    const Text(
                      "Enter Stock Ticker(s):",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addStockField,
                    ),
                  ],
                ),
                Column(
                  children: _stockControllers.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        controller: entry.value,
                        decoration: InputDecoration(
                          labelText: "Ticker ${entry.key + 1}",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Proceed Button.
                FFButtonWidget(
                  onPressed: _fetchPredictions,
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
                const SizedBox(height: 32),

                // Loading Indicator.
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),

                // Recommended Stocks Section.
                if (!_isLoading && _recommendedPredictions.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Recommended Stocks",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: _recommendedPredictions.map((prediction) {
                      if (prediction.containsKey("error")) {
                        return ListTile(title: Text(prediction["error"]));
                      }
                      return Card(
                        child: ListTile(
                          title: Text(prediction["ticker"] ?? "N/A"),
                          subtitle: Text(
                            "Predicted Price on ${prediction["next_business_day"]}: ₹${prediction["predicted_price"]}\n"
                            "Current Price: ₹${prediction["current_price"]}",
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Other Stocks Section.
                if (!_isLoading && _otherPredictions.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Predicted Stocks",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: _otherPredictions.map((prediction) {
                      if (prediction.containsKey("error")) {
                        return ListTile(title: Text(prediction["error"]));
                      }
                      return Card(
                        child: ListTile(
                          title: Text(prediction["ticker"] ?? "N/A"),
                          subtitle: Text(
                            "Predicted Price on ${prediction["next_business_day"]}: ₹${prediction["predicted_price"]}\n"
                            "Current Price: ₹${prediction["current_price"]}",
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // If no predictions are available.
                if (!_isLoading &&
                    _recommendedPredictions.isEmpty &&
                    _otherPredictions.isEmpty)
                  const Center(child: Text("No predictions available.")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
