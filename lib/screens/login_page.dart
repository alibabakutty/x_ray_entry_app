import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:x_ray_entry_app/authentication/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? errorMessage = '';
  bool isLogin = true; // toggle between login and register
  bool isLoading = false;

  Future<void> signInOrRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      if (isLogin) {
        // login
        await Auth().signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        // Employee Register
        await Auth().createUserAccount(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/gateway');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occured';

      switch (e.code) {
        case 'invalid e-mail':
          message = 'Please enter a valid email address';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        case 'user-not-found':
          message = 'No account found for this email';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for this email';
          break;
        case 'weak-password':
          message = 'Password should be at least 6 characters';
          break;
        default:
          message = e.message ?? 'Authentication failed';
      }
      setState(() {
        errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occured';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Login' : 'Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be atleast 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (errorMessage!.isNotEmpty)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : signInOrRegister,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Text(isLogin ? 'Login' : 'Register'),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        setState(() {
                          isLogin = !isLogin;
                          errorMessage = '';
                        });
                      },
                child: Text(isLogin
                    ? 'Need an Account? Register'
                    : 'Already have an account? Login'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
