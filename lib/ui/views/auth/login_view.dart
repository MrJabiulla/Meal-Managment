import 'package:flutter/material.dart';
import 'package:meal_managment/ui/views/auth/register_view.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../home/home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Consumer<AuthViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: Text(
                            'Meal Management',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            // Add check for common domain mistakes
                            if (value.endsWith('@gmail.co')) {
                              return 'Did you mean @gmail.com?';
                            }
                            if (value.endsWith('@yahoo.co')) {
                              return 'Did you mean @yahoo.com?';
                            }
                            if (value.endsWith('@hotmail.co')) {
                              return 'Did you mean @hotmail.com?';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        if (viewModel.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              viewModel.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ElevatedButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () async {
                            try {
                              if (viewModel.errorMessage != null) {
                                print('Current error message: ${viewModel.errorMessage}');
                              }
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const HomeView(),
                                ),
                              );
                              // if (_formKey.currentState!.validate()) {
                              //   print('Login attempt with email: ${_emailController.text}');
                              //   final success = await viewModel.login(
                              //     _emailController.text.trim(), // Added trim to remove any whitespace
                              //     _passwordController.text,
                              //   );
                              //   print('Login success: $success');
                              //   if (success && mounted) {
                              //     Navigator.of(context).pushReplacement(
                              //       MaterialPageRoute(
                              //         builder: (_) => const HomeView(),
                              //       ),
                              //     );
                              //   } else if (mounted) {
                              //     // Show specific feedback about the login failure
                              //     ScaffoldMessenger.of(context).showSnackBar(
                              //       SnackBar(
                              //         content: Text(viewModel.errorMessage ?? 'Login failed. Please check your email and password.'),
                              //         backgroundColor: Colors.red,
                              //       ),
                              //     );
                              //   }
                              // }
                            } catch (error) {
                              print('Login error occurred: $error');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Login error: $error')),
                              );
                            }
                          }, child: Text(
                            viewModel.isLoading ? 'Logging in...' : 'Login',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterView(),
                              ),
                            );
                          },
                          child: const Text('Don\'t have an account? Register'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}