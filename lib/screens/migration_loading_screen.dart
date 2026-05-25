import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../core/theme.dart';

class MigrationLoadingScreen extends StatefulWidget {
  final String uid;
  final Widget nextScreen;

  const MigrationLoadingScreen({
    super.key,
    required this.uid,
    required this.nextScreen,
  });

  @override
  State<MigrationLoadingScreen> createState() => _MigrationLoadingScreenState();
}

class _MigrationLoadingScreenState extends State<MigrationLoadingScreen> {
  @override
  void initState() {
    super.initState();
    _startMigration();
  }

  Future<void> _startMigration() async {
    final provider = context.read<ProfileProvider>();
    await provider.loadAndMigrateProfile(widget.uid);
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => widget.nextScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().darkMode;
    final bgColor = isDark ? NoorTheme.surfaceDark : NoorTheme.background(context);
    final primaryText = isDark ? NoorTheme.onSurfaceLight : NoorTheme.textColor(context);
    final secondaryText = isDark
        ? NoorTheme.onSurfaceLight.withValues(alpha: 0.6)
        : NoorTheme.textMuted(context);
    final progressColor = isDark ? NoorTheme.onSurfaceLight : NoorTheme.primaryNavy;
    final buttonBg = isDark ? NoorTheme.onSurfaceLight : NoorTheme.primaryNavy;
    final buttonFg = isDark ? NoorTheme.surfaceDark : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Consumer<ProfileProvider>(
          builder: (context, provider, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: progressColor),
                const SizedBox(height: 24),
                Text(
                  'SYNCING PROFILE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getStatusText(provider.profile?.migrationStatus ?? 'pending'),
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryText,
                  ),
                ),
                if (provider.error.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    provider.error,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _startMigration(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBg,
                      foregroundColor: buttonFg,
                    ),
                    child: const Text('RETRY'),
                  )
                ]
              ],
            );
          },
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'syncing': return 'Uploading data to cloud...';
      case 'completed': return 'Sync complete!';
      case 'failed': return 'Sync failed, retrying...';
      default: return 'Preparing data...';
    }
  }
}
