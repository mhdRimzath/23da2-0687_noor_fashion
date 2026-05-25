import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../widgets/main_navigation.dart';
import '../services/auth_service.dart';
import '../providers/cart_provider.dart';
import 'migration_loading_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F4), // background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NoorTheme.primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NOOR FASHION',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
            fontSize: 20,
            color: NoorTheme.primaryNavy,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white.withAlpha(204), // white/80
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448), // max-w-md
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'WELCOME BACK',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    fontSize: 36, // text-4xl
                    color: NoorTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Please enter your credentials to access your curated collections.',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    color: const Color(0xFF45464D), // on-surface-variant
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('EMAIL ADDRESS'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.manrope(color: NoorTheme.primaryNavy),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address.';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'name@atelier.com',
                          hintStyle: GoogleFonts.manrope(
                            color: const Color(0xFFC6C6CD), // outline-variant
                          ),
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0x66C6C6CD)), // outline-variant/40
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: NoorTheme.primaryNavy, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLabel('PASSWORD'),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'FORGOT?',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: NoorTheme.accentGold, // secondary
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: GoogleFonts.manrope(color: NoorTheme.primaryNavy),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password.';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: GoogleFonts.manrope(
                            color: const Color(0xFFC6C6CD),
                          ),
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0x66C6C6CD)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: NoorTheme.primaryNavy, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NoorTheme.primaryNavy,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(56), // h-14
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4), // rounded-md
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  try {
                                    final userCredential = await AuthService().signIn(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    );
                                    if (context.mounted && userCredential.user != null) {
                                      await context.read<CartProvider>().migrateGuestCartToFirestore(userCredential.user!.uid);
                                    }
                                    if (context.mounted) {
                                      final redirectIndex = ModalRoute.of(
                                              context)
                                          ?.settings
                                          .arguments as int? ??
                                          0;
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MigrationLoadingScreen(
                                            uid: userCredential.user!.uid,
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(e.message ??
                                              'An authentication error occurred.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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
                            : Text(
                                'LOG IN',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFE5E2DD))), // surface-container-highest
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR CONTINUE WITH',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: const Color(0xFF76777D), // outline
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFE5E2DD))),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _buildSocialButton('GOOGLE', Icons.g_mobiledata),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSocialButton('APPLE', Icons.apple),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.only(top: 32),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFE5E2DD)),
                    ),
                  ),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        final redirectIndex = ModalRoute.of(context)?.settings.arguments as int? ?? 0;
                        Navigator.pushReplacementNamed(context, '/register', arguments: redirectIndex);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              color: const Color(0xFF45464D), // on-surface-variant
                            ),
                          ),
                          Text(
                            'Create Account',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: NoorTheme.primaryNavy,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward, size: 16, color: NoorTheme.primaryNavy),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: const Color(0xFF45464D),
      ),
    );
  }

  Widget _buildSocialButton(String text, IconData icon) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EE), // surface-container-low
        border: Border.all(color: const Color(0x33C6C6CD)), // outline-variant/20
        borderRadius: BorderRadius.circular(4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: NoorTheme.primaryNavy, size: 20),
              const SizedBox(width: 12),
              Text(
                text,
                style: GoogleFonts.manrope(
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
