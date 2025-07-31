import 'package:flutter/material.dart';

class SimpleTestApp extends StatelessWidget {
  const SimpleTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinSight Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FinSight - Test Mode'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              children: [
                const Text('Welcome to FinSight!'),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: const Center(
                    child: Text(
                      'Dashboard Content Area\n\nNo Overflow! ✅',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('This tests that the layout doesn\'t overflow with bottom navigation'),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Budget'),
            BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Predict'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'AI Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Knowledge'),
          ],
        ),
      ),
    );
  }
}
