import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../widgets/main_navigation.dart';
import '../services/auth_service.dart';
import '../providers/cart_provider.dart';
import '../providers/settings_provider.dart';
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
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().darkMode;
    final textPrimary = isDark ? NoorTheme.onSurfaceLight : NoorTheme.textColor(context);
    final textSecondary = isDark
        ? NoorTheme.onSurfaceLight.withValues(alpha: 0.6)
        : NoorTheme.textMuted(context);
    final bgColor = isDark ? NoorTheme.surfaceDark : NoorTheme.background(context);
    final appBarBg = isDark
        ? NoorTheme.appBarBg(context)
        : NoorTheme.appBarBg(context).withAlpha(204);
    final borderColor = isDark ? NoorTheme.onSurfaceLight.withValues(alpha: 0.1) : NoorTheme.border(context);
    final hintColor = isDark
        ? NoorTheme.onSurfaceLight.withValues(alpha: 0.3)
        : const Color(0xFFC6C6CD);
    final underlineColor = isDark
        ? NoorTheme.onSurfaceLight.withValues(alpha: 0.15)
        : const Color(0x66C6C6CD);
    final focusBorderColor = isDark ? NoorTheme.accentGold : NoorTheme.primaryNavy;
    final btnBg = isDark ? NoorTheme.onSurfaceLight : NoorTheme.primaryNavy;
    final btnFg = isDark ? NoorTheme.surfaceDark : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NOOR FASHION',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
            fontSize: 20,
            color: textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: appBarBg,
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
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Please enter your credentials to access your curated collections.',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    color: textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(context, 'EMAIL ADDRESS'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.manrope(color: textPrimary),
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
                          hintStyle: GoogleFonts.manrope(color: hintColor),
                          filled: true,
                          fillColor: NoorTheme.inputBg(context),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: underlineColor),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: focusBorderColor, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLabel(context, 'PASSWORD'),
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
                        obscureText: _obscurePassword,
                        style: GoogleFonts.manrope(color: textPrimary),
                        cursorColor: textPrimary,
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
                          hintStyle: GoogleFonts.manrope(color: hintColor),
                          filled: true,
                          fillColor: NoorTheme.inputBg(context),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: underlineColor),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: focusBorderColor, width: 2),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: hintColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: btnBg,
                          foregroundColor: btnFg,
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
                                  final messenger = ScaffoldMessenger.of(context);
                                  final navigator = Navigator.of(context);
                                  final redirectIndex = ModalRoute.of(context)
                                          ?.settings
                                          .arguments as int? ??
                                      0;
                                  final cartProvider = context.read<CartProvider>();

                                  setState(() {
                                    _isLoading = true;
                                  });
                                  try {
                                    final userCredential = await AuthService().signIn(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    );
                                    final user = userCredential.user;

                                    if (user == null) {
                                      if (mounted) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text('Login failed. Please try again.'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    await cartProvider.migrateGuestCartToFirestore(user.uid);

                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }

                                    if (!mounted) return;
                                    navigator.pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => MigrationLoadingScreen(
                                          uid: user.uid,
                                          nextScreen: MainNavigation(
                                            isLoggedIn: true,
                                            initialIndex: redirectIndex,
                                          ),
                                        ),
                                      ),
                                      (route) => false,
                                    );
                                  } on FirebaseAuthException catch (e) {
                                    if (context.mounted) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(e.message ??
                                              'An authentication error occurred.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      messenger.showSnackBar(
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
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: btnFg,
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
                    Expanded(child: Divider(color: borderColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR CONTINUE WITH',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: textSecondary,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: borderColor)),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _buildSocialButton(context, 'GOOGLE', Icons.g_mobiledata),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSocialButton(context, 'APPLE', Icons.apple),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.only(top: 32),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: borderColor),
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
                              color: textSecondary,
                            ),
                          ),
                          Text(
                            'Create Account',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 16, color: textPrimary),
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

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: NoorTheme.textMuted(context),
      ),
    );
  }

  Widget _buildSocialButton(BuildContext context, String text, IconData icon) {
    final textPrimary = NoorTheme.textColor(context);
    final cardBg = NoorTheme.cardAlt(context);
    final borderColor = NoorTheme.border(context);

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: borderColor),
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
              Icon(icon, color: textPrimary, size: 20),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  text,
                  style: GoogleFonts.manrope(
                    color: textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
