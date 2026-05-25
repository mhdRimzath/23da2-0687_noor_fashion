import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';

void showLoginPrompt(BuildContext context, {String title = 'SIGN IN REQUIRED', String message = 'Please sign in or create an account to continue.'}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: NoorTheme.cardAlt(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: NoorTheme.textColor(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: NoorTheme.textMuted(context),
                fontSize: 12,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: NoorTheme.textColor(context),
                foregroundColor: NoorTheme.isDark(context) ? NoorTheme.surfaceDark : Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('LOGIN', style: TextStyle(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: NoorTheme.textColor(context),
                side: BorderSide(color: NoorTheme.textColor(context)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('REGISTER', style: TextStyle(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
