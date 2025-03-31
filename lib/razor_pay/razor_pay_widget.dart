import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'razor_pay_model.dart';
export 'razor_pay_model.dart';


import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// PaymentService - Handles API communication with Django backend
class PaymentService {
  // Base URL for API - Update this to your server address
  static final String baseUrl = 'http://10.0.2.2:8002/api';

  // Create a new order
  static Future<Map<String, dynamic>> createOrder({
    required double amount,
    required String category,
    String? upiId,
    String? mobileNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create_order/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount * 100, // Converting to paise
          'category': category,
          'upi_id': upiId ?? '',
          'mobile_number': mobileNumber ?? '',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  // Verify payment after success
  static Future<Map<String, dynamic>> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
    required String paymentMethod,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify_payment/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'payment_id': paymentId,
          'order_id': orderId,
          'signature': signature,
          'payment_method': paymentMethod,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify payment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  // Get payment history
  static Future<List<dynamic>> getPaymentHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/payment_history/'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load payment history');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }
}

// Payment feature screen to be integrated into your app
class PaymentFeatureScreen extends StatefulWidget {
  // You can customize these parameters as needed for your integration
  final String initialCategory;
  final Function(Map<String, dynamic>)? onPaymentSuccess;

  const PaymentFeatureScreen({
    Key? key,
    this.initialCategory = 'Other',
    this.onPaymentSuccess,
  }) : super(key: key);

  @override
  _PaymentFeatureScreenState createState() => _PaymentFeatureScreenState();
}

class _PaymentFeatureScreenState extends State<PaymentFeatureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _upiIdController = TextEditingController();
  final _mobileNumberController = TextEditingController();

  Razorpay? _razorpay;
  String _selectedCategory = 'Other';
  String _selectedPaymentMethod = 'upi';
  final List<String> _categories = ['Food','Entertainment', 'Transportation', 'Groceries', 'Utilities','Education','Healthcare','Other'];
  final List<String> _paymentMethods = ['upi', 'card', 'netbanking', 'wallet'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay!.clear();
    _amountController.dispose();
    _upiIdController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse paymentResponse) async {
    setState(() => _isLoading = true);

    try {
      // Verify payment with backend
      final paymentData = await PaymentService.verifyPayment(
        paymentId: paymentResponse.paymentId!,
        orderId: paymentResponse.orderId!,
        signature: paymentResponse.signature!,
        paymentMethod: _selectedPaymentMethod,
      );

      setState(() => _isLoading = false);

      // Show success dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Payment Successful'),
          content: Text('Payment ID: ${paymentResponse.paymentId}\nPayment verified and saved.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _resetForm();

                // Call the success callback if provided
                if (widget.onPaymentSuccess != null) {
                  widget.onPaymentSuccess!(paymentData);
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error: $e');
    }
  }

  void _resetForm() {
    _amountController.clear();
    _upiIdController.clear();
    _mobileNumberController.clear();
    setState(() {
      _selectedCategory = widget.initialCategory;
      _selectedPaymentMethod = 'upi';
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showErrorDialog('Payment failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet selected: ${response.walletName}')),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _initiatePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get order ID from backend
      final orderData = await PaymentService.createOrder(
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        upiId: _upiIdController.text,
        mobileNumber: _mobileNumberController.text,
      );

      final orderId = orderData['order_id'];
      final keyId = orderData['key_id'];

      // Prepare options with UPI support
      var options = {
        'key': keyId,
        'amount': double.parse(_amountController.text) * 100, // in paise
        'name': 'Payment App',
        'description': 'Payment for $_selectedCategory',
        'order_id': orderId,
        'prefill': {
          'contact': _mobileNumberController.text.isNotEmpty
              ? _mobileNumberController.text
              : '9876543210',
          'email': 'test@example.com',
        },
        'theme': {
          'color': '#0088FF',
        }
      };

      // Add UPI specific options
      if (_selectedPaymentMethod == 'upi' && _upiIdController.text.isNotEmpty) {
        options['method'] = 'upi';
        options['upi'] = {
          'vpa': _upiIdController.text,
          'flow': 'collect'
        };
      }

      setState(() => _isLoading = false);
      _razorpay!.open(options);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error: $e');
    }
  }

  Widget _buildPaymentMethodFields() {
    if (_selectedPaymentMethod == 'upi') {
      return Column(
        children: [
          const SizedBox(height: 16),
          TextFormField(
            controller: _upiIdController,
            decoration: const InputDecoration(
              labelText: 'UPI ID (e.g. name@upi)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_balance_wallet),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty && !value.contains('@')) {
                return 'Please enter a valid UPI ID';
              }
              return null;
            },
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF014872),
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 70.0,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 30.0,
          ),
          onPressed: () async {
            context.pushNamed('home');
          },
        ),
        title: const Text('Make Payment'),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentHistoryScreen(),
                ),
              );
            },
            tooltip: 'Payment History',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCategory,
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (₹)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedPaymentMethod,
                  items: _paymentMethods.map((String method) {
                    return DropdownMenuItem<String>(
                      value: method,
                      child: Text(method.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPaymentMethod = newValue!;
                    });
                  },
                ),
                _buildPaymentMethodFields(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mobileNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 10) {
                      return 'Please enter a valid mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _initiatePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF014872),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Pay Now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Payment History screen
class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({Key? key}) : super(key: key);

  @override
  _PaymentHistoryScreenState createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List<dynamic> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPaymentHistory();
  }

  Future<void> _fetchPaymentHistory() async {
    try {
      final payments = await PaymentService.getPaymentHistory();
      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: Color(0xFF014872),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _payments.isEmpty
          ? const Center(child: Text('No payment history available'))
          : ListView.builder(
        itemCount: _payments.length,
        itemBuilder: (context, index) {
          final payment = _payments[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text('₹${payment['amount']} - ${payment['category']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${payment['status']}'),
                  if (payment['payment_method'] != null)
                    Text('Method: ${payment['payment_method']}'),
                  Text('Date: ${payment['created_at'].substring(0, 10)}'),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: payment['status'] == 'successful'
                      ? Colors.green
                      : payment['status'] == 'failed'
                      ? Colors.red
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  payment['status'].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}