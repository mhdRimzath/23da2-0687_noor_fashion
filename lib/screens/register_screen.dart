import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../widgets/main_navigation.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../providers/cart_provider.dart';
import 'migration_loading_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NOOR FASHION', 
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'JOIN THE ATELIER',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    fontSize: 32,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Create an account to track orders and save your curated selections.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: NoorTheme.primaryNavy.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 40),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLabel('FULL NAME'),
                  TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Rimzath',
                      hintStyle: TextStyle(color: NoorTheme.primaryNavy.withValues(alpha: 0.3)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildLabel('EMAIL ADDRESS'),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email.';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'name@atelier.com',
                      hintStyle: TextStyle(color: NoorTheme.primaryNavy.withValues(alpha: 0.3)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildLabel('PASSWORD'),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please create a password.';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: TextStyle(color: NoorTheme.primaryNavy.withValues(alpha: 0.3)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                final credential = await AuthService().signUp(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                  _nameController.text.trim(),
                                );
                                if (credential.user != null) {
                                  await FirestoreService().createUserDocument(
                                    userId: credential.user!.uid,
                                    name: _nameController.text.trim(),
                                    email: _emailController.text.trim(),
                                  );
                                  if (context.mounted) {
                                    await context.read<CartProvider>().migrateGuestCartToFirestore(credential.user!.uid);
                                  }
                                }
                                if (context.mounted && credential.user != null) {
                                  final redirectIndex = ModalRoute.of(context)
                                          ?.settings
                                          .arguments as int? ??
                                      0;
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MigrationLoadingScreen(
                                        uid: credential.user!.uid,
                                        nextScreen: MainNavigation(
                                          isLoggedIn: true,
                                          initialIndex: redirectIndex,
                                        ),
                                      ),
                                    ),
                                    (route) => false,
                                  );
                                }
                              } on FirebaseAuthException catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(

                                      content: Text(e.message ??
                                          'An authentication error occurred.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'An unexpected error occurred: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            }
                          },
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('REGISTER'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(child: Divider(color: NoorTheme.primaryNavy.withValues(alpha: 0.1))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'OR CONTINUE WITH',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: NoorTheme.primaryNavy.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                Expanded(child: Divider(color: NoorTheme.primaryNavy.withValues(alpha: 0.1))),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSocialButton('GOOGLE', Icons.g_mobiledata),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildSocialButton('APPLE', Icons.apple),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: TextButton(
                onPressed: () {
                  final redirectIndex = ModalRoute.of(context)?.settings.arguments as int? ?? 0;
                  Navigator.pushReplacementNamed(context, '/login', arguments: redirectIndex);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14,
                        color: NoorTheme.primaryNavy.withValues(alpha: 0.6)
                      ),
                    ),
                    Text(
                      'Log In',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold, 
                        color: NoorTheme.primaryNavy
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward, size: 16, color: NoorTheme.primaryNavy),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          color: NoorTheme.primaryNavy.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String text, IconData icon) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EE),
        border: Border.all(color: const Color(0xFFC6C6CD).withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: NoorTheme.primaryNavy, size: 20),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  color: NoorTheme.primaryNavy,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
