import 'package:flutter/material.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/modern_nav_bar.dart';
import 'dashboard/dashboard_screen.dart';
import 'transaction/transaction_screen.dart';
import 'manage/manage_screen.dart';
import 'bill/bill_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionScreen(),
    ManageScreen(),
    BillScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: ModernNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
