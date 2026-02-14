import 'package:flutter/material.dart';
import '../../../core/theme/terminal_theme.dart';
import '../../home/presentation/home_screen.dart';
import '../../discover/presentation/discover_screen.dart';
import '../../terminal/presentation/terminal_screen.dart';
import '../../profile/presentation/profile_screen.dart';

/// Instagram-style bottom navigation shell.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    DiscoverScreen(),
    TerminalScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: TerminalColors.surface,
              width: 0.5,
            ),
          ),
        ),
        child: NavigationBar(
          backgroundColor: TerminalColors.background,
          indicatorColor: TerminalColors.green.withValues(alpha: 0.15),
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 65,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: TerminalColors.grey),
              selectedIcon: Icon(Icons.home, color: TerminalColors.green),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined, color: TerminalColors.grey),
              selectedIcon: Icon(Icons.search, color: TerminalColors.green),
              label: 'Discover',
            ),
            NavigationDestination(
              icon: Icon(Icons.terminal_outlined, color: TerminalColors.grey),
              selectedIcon: Icon(Icons.terminal, color: TerminalColors.green),
              label: 'Terminal',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: TerminalColors.grey),
              selectedIcon: Icon(Icons.person, color: TerminalColors.green),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
