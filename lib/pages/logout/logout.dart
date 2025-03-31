// logout.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '/flutter_flow/flutter_flow_util.dart'; // For context.pushNamed

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({Key? key}) : super(key: key);

  @override
  _LogoutScreenState createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  @override
  void initState() {
    super.initState();
    _performLogout();
  }

  Future<void> _performLogout() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');
  
  // Print the token for debugging purposes.
  print('Retrieved token from SharedPreferences: $token');
  
  if (token != null) {
    final String url = 'http://10.0.2.2:8000/api/accounts/logout/';
    try {
      // Use POST instead of DELETE as the backend expects POST.
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('Logout response status: ${response.statusCode}');
      print('Logout response body: ${response.body}');

      if (response.statusCode == 200) {
        await prefs.remove('auth_token');
        print('Token removed from SharedPreferences after successful logout.');
      } else {
        // Even if it's not a 200, clear the token to force a logout.
        await prefs.remove('auth_token');
        print('Token removed from SharedPreferences despite non-200 status.');
      }
    } catch (error) {
      print('Error during logout: $error');
      await prefs.remove('auth_token');
      print('Token removed from SharedPreferences after error.');
    }
  } else {
    print('No token found in SharedPreferences.');
  }

  // Navigate to the login page after logout.
  context.pushNamed('loginpage');
}


  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while logout is in progress.
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
