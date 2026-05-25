import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
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
    return Scaffold(
      backgroundColor: NoorTheme.backgroundChalk,
      body: Center(
        child: Consumer<ProfileProvider>(
          builder: (context, provider, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: NoorTheme.primaryNavy),
                const SizedBox(height: 24),
                const Text(
                  'SYNCING PROFILE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: NoorTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getStatusText(provider.profile?.migrationStatus ?? 'pending'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF45464D),
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
                    style: ElevatedButton.styleFrom(backgroundColor: NoorTheme.primaryNavy),
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
