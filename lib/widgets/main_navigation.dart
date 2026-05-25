import 'dart:ui';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/profile_screen.dart';
import '../core/theme.dart';

class MainNavigation extends StatefulWidget {
  final bool? isLoggedIn;
  final int initialIndex;

  const MainNavigation({
    super.key, 
    this.isLoggedIn = false,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  List<Widget> get _screens => [
    HomeScreen(isLoggedIn: widget.isLoggedIn ?? false),
    CartScreen(isLoggedIn: widget.isLoggedIn ?? false),
    ProfileScreen(isLoggedIn: widget.isLoggedIn ?? false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final dark = NoorTheme.isDark(context);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: dark
                ? NoorTheme.surfaceDark.withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(
                color: dark ? NoorTheme.onSurfaceLight.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 24, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: _navItem(context, 0, Icons.home_outlined, Icons.home, 'HOME')),
                  Expanded(child: _navItem(context, 1, Icons.shopping_cart_outlined, Icons.shopping_cart, 'CART')),
                  Expanded(child: _navItem(context, 2, Icons.person_outline, Icons.person, 'PROFILE')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index, IconData outlinedIcon, IconData filledIcon, String label) {
    final isSelected = _selectedIndex == index;
    final dark = NoorTheme.isDark(context);
    final activeColor = dark ? NoorTheme.onSurfaceLight : NoorTheme.primaryNavy;
    final inactiveColor = dark ? NoorTheme.onSurfaceLight.withValues(alpha: 0.4) : const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (dark ? NoorTheme.onSurfaceLight.withValues(alpha: 0.08) : const Color(0xFFF8FAFC))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
