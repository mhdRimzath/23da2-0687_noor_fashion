import 'package:flutter/material.dart';

import '../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoorTheme.primaryNavy,
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo text
                  Text(
                    'NOOR FASHION',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      letterSpacing: -1.6, // tracking-[-0.05em] for 32px is -1.6px
                      fontWeight: FontWeight.w900, // Black
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subtitle with lines
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(height: 1, width: 32, color: NoorTheme.accentGold.withValues(alpha: 0.4)),
                      const SizedBox(width: 16),
                      Text(
                        'THE CURATED ATELIER',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: NoorTheme.accentGold,
                          letterSpacing: 4.0, // tracking-[0.4em]
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(height: 1, width: 32, color: NoorTheme.accentGold.withValues(alpha: 0.4)),
                    ],
                  ),
                  const SizedBox(height: 64),
                  // Loading Indicator
                  const SizedBox(
                    width: 192, // w-48
                    height: 2,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(NoorTheme.accentGold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'INITIALIZING COLLECTION',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white60,
                      fontSize: 10,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'EXCELLENCE IN CRAFTSMANSHIP',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                    letterSpacing: 2.2, // 0.2em
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.diamond_outlined, color: Colors.white.withValues(alpha: 0.2), size: 24),
                    const SizedBox(width: 24),
                    Icon(Icons.architecture, color: Colors.white.withValues(alpha: 0.2), size: 24),
                    const SizedBox(width: 24),
                    Icon(Icons.palette_outlined, color: Colors.white.withValues(alpha: 0.2), size: 24),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
