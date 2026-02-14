import 'package:flutter/material.dart';
import 'package:mobile_dashboard/screens/home_screen.dart';
import 'package:mobile_dashboard/screens/analytics_screen.dart';
import 'package:mobile_dashboard/screens/settings_screen.dart';
import 'package:mobile_dashboard/widgets/offline_blocker.dart';
import 'package:mobile_dashboard/providers/order_provider.dart';
import 'package:mobile_dashboard/utils/constants.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);

    if (provider.isOffline) {
      return OfflineBlocker(
        onRetry: () => provider.fetchOrders(),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Constants.backgroundColor,
          selectedItemColor: Constants.primaryColor,
          unselectedItemColor: Constants.textMutedColor,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(LucideIcons.layoutDashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(LucideIcons.barChart2), label: 'Analytics'),
            BottomNavigationBarItem(icon: Icon(LucideIcons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
