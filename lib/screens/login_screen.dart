import 'package:flutter/material.dart';
import 'package:jobreport/models/user.dart';
import 'package:jobreport/screens/signup_screen.dart';
import 'package:jobreport/services/auth_service.dart';
import 'package:jobreport/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jobreport/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _databaseService = DatabaseService();
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('remembered_email');
    if (email != null) {
      setState(() {
        _emailController.text = email;
        _rememberMe = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.purple.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Welcome Back!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Sign in to continue', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)),
                        const SizedBox(height: 32),
                        _buildEmailField(),
                        const SizedBox(height: 16),
                        _buildPasswordField(),
                        const SizedBox(height: 16),
                        _buildRememberMeSwitch(),
                        const SizedBox(height: 32),
                        _isLoading ? const CircularProgressIndicator() : _buildLoginButton(),
                        const SizedBox(height: 16),
                        _buildRegisterButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(hintText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your email';
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email';
        return null;
      },
    );
  }

  TextFormField _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(hintText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
      validator: (value) => (value == null || value.isEmpty) ? 'Please enter your password' : null,
    );
  }

  SwitchListTile _buildRememberMeSwitch() {
    return SwitchListTile(
      title: const Text('Remember Me'),
      value: _rememberMe,
      onChanged: (value) => setState(() => _rememberMe = value),
      dense: true,
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      child: const Text('LOGIN'),
      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
    );
  }

  Widget _buildRegisterButton() {
    return TextButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
      child: const Text('Don\'t have an account? Register'),
    );
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('remembered_email', _emailController.text);
    } else {
      await prefs.remove('remembered_email');
    }

    final user = await _databaseService.getUser(_emailController.text);
    setState(() => _isLoading = false);

    if (user != null && user.password == _passwordController.text) {
      await _authService.login(user.id, user.username);
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
    }
  }
}
