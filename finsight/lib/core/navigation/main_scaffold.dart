import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // Static navigation items for better performance
  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
    BottomNavigationBarItem(
      icon: Icon(Icons.account_balance_wallet),
      label: 'Budget',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Predictive'),
    BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'AI Chat'),
    BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Knowledge'),
  ];

  // Static route mappings for better performance
  static const Map<String, int> _routeToIndex = {
    '/dashboard': 0,
    '/budgeting': 1,
    '/predictive': 2,
    '/chatbot': 3,
    '/knowledge': 4,
  };

  static const Map<int, String> _indexToRoute = {
    0: '/dashboard',
    1: '/budgeting',
    2: '/predictive',
    3: '/chatbot',
    4: '/knowledge',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final location = GoRouter.of(
      context,
    ).routeInformationProvider.value.uri.path;
    final index = _routeToIndex[location] ?? 0;
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onTabTapped(int index) {
    if (_selectedIndex != index) {
      final route = _indexToRoute[index];
      if (route != null) {
        // Use pushReplacement for faster navigation without animation lag
        context.pushReplacement(route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if current route should show bottom navigation
    final location = GoRouter.of(
      context,
    ).routeInformationProvider.value.uri.path;
    final showBottomNav = _routeToIndex.containsKey(location);

    return Scaffold(
      body: SafeArea(
        bottom: false, // Let BottomNavigationBar handle its own safe area
        child: widget.child,
      ),
      bottomNavigationBar: showBottomNav
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: _onTabTapped,
              items: _navItems,
              elevation: 8,
              // Use theme colors directly for better performance
              backgroundColor: Theme.of(
                context,
              ).bottomNavigationBarTheme.backgroundColor,
              selectedItemColor: Theme.of(
                context,
              ).bottomNavigationBarTheme.selectedItemColor,
              unselectedItemColor: Theme.of(
                context,
              ).bottomNavigationBarTheme.unselectedItemColor,
              // Disable animations for instant tab switching
              enableFeedback: false,
            )
          : null,
    );
  }
}
