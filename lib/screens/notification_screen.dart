import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [];

    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      appBar: AppBar(
        backgroundColor: NoorTheme.appBarBg(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'NOTIFICATIONS',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: NoorTheme.textColor(context),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: NoorTheme.textColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FirebaseAuth.instance.currentUser == null
          ? _buildLoggedOutState(context)
          : (notifications.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => Divider(
                    color: NoorTheme.border(context),
                    height: 1,
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return Container(
                      color: notif['isUnread']
                          ? NoorTheme.isDark(context)
                              ? const Color(0xFF1E2128)
                              : const Color(0xFFF9F7F4)
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: NoorTheme.isDark(context)
                                  ? const Color(0xFF2C2F36)
                                  : const Color(0xFFF0EDE9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              notif['icon'],
                              color: NoorTheme.textColor(context),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notif['title'],
                                        style: TextStyle(
                                          fontFamily: 'Manrope',
                                          fontSize: 14,
                                          fontWeight: notif['isUnread']
                                              ? FontWeight.w900
                                              : FontWeight.w600,
                                          color: NoorTheme.textColor(context),
                                        ),
                                      ),
                                    ),
                                    if (notif['isUnread'])
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: NoorTheme.accentGold,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  notif['message'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.5,
                                    color: NoorTheme.textMuted(context),
                                    fontWeight: notif['isUnread']
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  notif['time'],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF775A19),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 64, color: NoorTheme.textMuted(context)),
          const SizedBox(height: 16),
          Text(
            'NO NOTIFICATIONS YET',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: NoorTheme.textColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll let you know when there\'s an update.',
            style: TextStyle(
              fontSize: 12,
              color: NoorTheme.textMuted(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedOutState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 80,
              color: NoorTheme.textColor(context).withValues(alpha: 0.1),
            ),
            const SizedBox(height: 24),
            Text(
              'LOGIN TO VIEW NOTIFICATIONS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: NoorTheme.textColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Sign in to see your latest order updates, exclusive offers, and news.',
              style: TextStyle(
                color: NoorTheme.textMuted(context),
                fontSize: 12,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: NoorTheme.textColor(context),
                foregroundColor: NoorTheme.isDark(context) ? NoorTheme.surfaceDark : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('LOGIN', style: TextStyle(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: NoorTheme.textColor(context),
                side: BorderSide(color: NoorTheme.textColor(context)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('REGISTER', style: TextStyle(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
