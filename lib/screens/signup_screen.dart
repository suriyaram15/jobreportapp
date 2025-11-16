import 'package:flutter/material.dart';
import 'package:jobreport/models/user.dart';
import 'package:jobreport/services/database_service.dart';
import 'package:uuid/uuid.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _databaseService = DatabaseService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade300, Colors.blue.shade200],
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
                        Text('Create Account', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Get started with a new account', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)),
                        const SizedBox(height: 32),
                        _buildEmailField(),
                        const SizedBox(height: 16),
                        _buildPasswordField(),
                        const SizedBox(height: 32),
                        _isLoading ? const CircularProgressIndicator() : _buildRegisterButton(),
                        const SizedBox(height: 16),
                        _buildLoginButton(),
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
        if (value == null || value.isEmpty) return 'Please enter an email';
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
      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a password' : null,
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _register,
      child: const Text('REGISTER'),
      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
    );
  }

  Widget _buildLoginButton() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Already have an account? Login'),
    );
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text;
    final existingUser = await _databaseService.getUser(email);
    if (existingUser != null) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An account with this email already exists')));
      return;
    }

    final newUser = User(id: const Uuid().v4(), username: email, password: _passwordController.text);
    await _databaseService.saveUser(newUser);
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful! Please log in.')));
      Navigator.pop(context);
    }
  }
}
