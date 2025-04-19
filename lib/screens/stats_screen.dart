import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart';
import 'add_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTime selectedMonth = DateTime.now();
  int _selectedIndex = 2; // Stats tab is selected

  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigate to AddScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AddScreen(
            currentWalletAmount: 0.0, // You might want to pass the current wallet amount here
          ),
        ),
      );
      return;
    } else if (index == 0) {
      // Navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
      return;
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  void _previousMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    });
  }

  double get totalExpenses {
    return double.parse(HomeScreen.allExpenses
        .where((e) => !e.isIncome && 
            e.date.year == selectedMonth.year && 
            e.date.month == selectedMonth.month)
        .fold(0.0, (sum, expense) => sum + expense.amount)
        .toStringAsFixed(2));
  }

  double get totalIncome {
    return double.parse(HomeScreen.allExpenses
        .where((e) => e.isIncome && 
            e.date.year == selectedMonth.year && 
            e.date.month == selectedMonth.month)
        .fold(0.0, (sum, expense) => sum + expense.amount)
        .toStringAsFixed(2));
  }

  double get total => double.parse((totalIncome - totalExpenses).toStringAsFixed(2));

  Map<ExpenseCategory, double> get categoryExpenses {
    final Map<ExpenseCategory, double> expenses = {};
    for (var category in ExpenseCategory.allCategories) {
      final amount = HomeScreen.allExpenses
          .where((e) => !e.isIncome && 
              e.category == category &&
              e.date.year == selectedMonth.year && 
              e.date.month == selectedMonth.month)
          .fold(0.0, (sum, expense) => sum + expense.amount);
      if (amount > 0) {
        expenses[category] = amount;
      }
    }
    return expenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _previousMonth,
                    color: Colors.green,
                  ),
                  Text(
                    DateFormat('MMMM, yyyy').format(selectedMonth),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextMonth,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryCard('EXPENSE', totalExpenses, Colors.red),
                  _buildSummaryCard('INCOME', totalIncome, Colors.green),
                  _buildSummaryCard('TOTAL', total, total >= 0 ? Colors.green : Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Expenses by Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...categoryExpenses.entries.map((entry) {
                    final percentage = (entry.value / totalExpenses * 100).toStringAsFixed(1);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(entry.key.icon, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Text(
                                    entry.key.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '\$${entry.value.toStringAsFixed(2)} ($percentage%)',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: entry.value / totalExpenses,
                            backgroundColor: Colors.red.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analysis',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
} 