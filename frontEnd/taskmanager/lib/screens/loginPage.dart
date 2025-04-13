import 'package:flutter/material.dart';
import '../service/api_service.dart';
// Import the network debug utility if you created it
// import '../utils/network_debug.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        print('Attempting to login with:');
        print('Email: ${_emailController.text}');
        print('Password length: ${_passwordController.text.length} characters');

        final result = await _apiService.loginUser(
            email: _emailController.text, password: _passwordController.text);

        print('Login response: $result');

        if (result.containsKey('error') ||
            result.containsKey('message') &&
                result['message'] != 'Login successful') {
          setState(() {
            _errorMessage =
                result['error'] ?? result['message'] ?? 'Login failed';
          });
          print('Login error: $_errorMessage');
        } else {
          print('Login successful, navigating to tasks screen');
          // Navigate to tasks screen
          Navigator.pushReplacementNamed(context, '/tasks');
        }
      } catch (e) {
        print('Login exception: $e');
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('Form validation failed');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              Icon(
                Icons.task_alt,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 16),
              Text(
                'Task Manager',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Login'),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
                child: Text('New user? Register'),
              ),

              // Network Debug Button (uncomment if you created the NetworkDebug utility)
              /*
              SizedBox(height: 24),
              OutlinedButton.icon(
                icon: Icon(Icons.network_check),
                label: Text('Check Network'),
                onPressed: () => NetworkDebug.showNetworkInfo(context),
              ),
              */
            ],
          ),
        ),
      ),
    );
  }
}
