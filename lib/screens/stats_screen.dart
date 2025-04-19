import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart';
import 'add_screen.dart';

class StatsScreen extends StatefulWidget {
  final Function() onThemeToggle;
  final bool isDarkMode;

  const StatsScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTime selectedMonth = DateTime.now();
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AddScreen(
            currentWalletAmount: 0.0,
            onThemeToggle: widget.onThemeToggle,
            isDarkMode: widget.isDarkMode,
          ),
        ),
      );
      return;
    } else if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            onThemeToggle: widget.onThemeToggle,
            isDarkMode: widget.isDarkMode,
          ),
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                    color: theme.colorScheme.primary,
                  ),
                  Text(
                    DateFormat('MMMM, yyyy').format(selectedMonth),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextMonth,
                    color: theme.colorScheme.primary,
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
                  _buildSummaryCard('EXPENSE', totalExpenses, theme.colorScheme.error),
                  _buildSummaryCard('INCOME', totalIncome, theme.colorScheme.primary),
                  _buildSummaryCard('TOTAL', total, total >= 0 ? theme.colorScheme.primary : theme.colorScheme.error),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Expenses by Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
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
                                  Icon(entry.key.icon, color: theme.colorScheme.error),
                                  const SizedBox(width: 8),
                                  Text(
                                    entry.key.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onBackground,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '\$${entry.value.toStringAsFixed(2)} ($percentage%)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: entry.value / totalExpenses,
                            backgroundColor: theme.colorScheme.error.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.error),
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
        selectedItemColor: theme.colorScheme.primary,
        backgroundColor: theme.scaffoldBackgroundColor,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    final theme = Theme.of(context);
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