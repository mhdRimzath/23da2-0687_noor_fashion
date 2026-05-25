import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return Drawer(
      backgroundColor: NoorTheme.background(context),
      child: settingsProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: NoorTheme.textColor(context)))
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                    child: Row(
                      children: [
                        Text(
                          'SETTINGS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: NoorTheme.textColor(context),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: NoorTheme.textColor(context)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      children: [
                        _buildSectionHeader(context, 'PREFERENCES'),
                const SizedBox(height: 15),
                _buildSettingTile(
                  context: context,
                  title: 'Push Notifications',
                  subtitle: 'Receive updates on new arrivals and offers',
                  icon: Icons.notifications_none,
                  value: settingsProvider.pushNotifications,
                  onChanged: (val) => settingsProvider.updateSetting('pushNotifications', val),
                ),
                const SizedBox(height: 12),
                _buildSettingTile(
                  context: context,
                  title: 'Email Notifications',
                  subtitle: 'Receive newsletters and promotions',
                  icon: Icons.email_outlined,
                  value: settingsProvider.emailNotifications,
                  onChanged: (val) => settingsProvider.updateSetting('emailNotifications', val),
                ),
                const SizedBox(height: 40),
                _buildSectionHeader(context, 'SECURITY & DISPLAY'),
                const SizedBox(height: 15),
                _buildSettingTile(
                  context: context,
                  title: 'Biometric Authentication',
                  subtitle: 'Login faster using Face ID or Touch ID',
                  icon: Icons.fingerprint,
                  value: settingsProvider.biometricAuth,
                  onChanged: (val) => settingsProvider.updateSetting('biometricAuth', val),
                ),
                const SizedBox(height: 12),
                _buildSettingTile(
                  context: context,
                  title: 'Dark Mode',
                  subtitle: 'Switch application to dark theme',
                  icon: Icons.dark_mode_outlined,
                  value: settingsProvider.darkMode,
                  onChanged: (val) => settingsProvider.updateSetting('darkMode', val),
                ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
        color: NoorTheme.textMuted(context),
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: NoorTheme.cardColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: NoorTheme.iconBg(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: NoorTheme.textColor(context), size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: NoorTheme.textColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: NoorTheme.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: NoorTheme.isDark(context) ? NoorTheme.accentGold : NoorTheme.primaryNavy,
          ),
        ],
      ),
    );
  }
}
