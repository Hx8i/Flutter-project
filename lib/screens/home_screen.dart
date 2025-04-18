import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'add_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double walletAmount = 250.0;
  int daysRemaining = 13;
  bool isEditing = false;
  double ExpensePerDay = 19.23;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController daysController = TextEditingController();
  int _selectedIndex = 0;

  // Sample expense data
  final List<Expense> expenses = [
    Expense(
      date: DateTime.now(),
      time: '18:40',
      category: ExpenseCategory.work,
      amount: 250,
      isIncome: true,
    ),
    Expense(
      date: DateTime.now(),
      time: '18:40',
      category: ExpenseCategory.gym,
      amount: 25,
    ),
    Expense(
      date: DateTime.now(),
      time: '18:40',
      category: ExpenseCategory.shopping,
      amount: 55,
    ),
    Expense(
      date: DateTime.now(),
      time: '18:39',
      category: ExpenseCategory.food,
      amount: 15,
    ),
    Expense(
      date: DateTime.now(),
      time: '12:15',
      category: ExpenseCategory.work,
      amount: 50,
      isIncome: true,
    ),
    Expense(
      date: DateTime.now().subtract(const Duration(days: 1)),
      time: '15:01',
      category: ExpenseCategory.products,
      amount: 25,
    ),
    Expense(
      date: DateTime.now().subtract(const Duration(days: 1)),
      time: '13:53',
      category: ExpenseCategory.other,
      amount: 25,
    ),
    Expense(
      date: DateTime.now().subtract(const Duration(days: 2)),
      time: '09:13',
      category: ExpenseCategory.gym,
      amount: 40,
    ),
    Expense(
      date: DateTime.now().subtract(const Duration(days: 2)),
      time: '10:20',
      category: ExpenseCategory.food,
      amount: 7.5,
    ),
    Expense(
      date: DateTime.now().subtract(const Duration(days: 2)),
      time: '04:56',
      category: ExpenseCategory.products,
      amount: 85,
    ),
    Expense(
      date: DateTime.now().subtract(const Duration(days: 3)),
      time: '05:30',
      category: ExpenseCategory.medicine,
      amount: 15,
    ),

  ];

  @override
  void initState() {
    super.initState();
    amountController.text = walletAmount.toString();
    daysController.text = daysRemaining.toString();
  }

  @override
  void dispose() {
    amountController.dispose();
    daysController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      if (isEditing) {
        walletAmount = double.parse((double.tryParse(amountController.text) ?? walletAmount).toStringAsFixed(2));
        daysRemaining = int.tryParse(daysController.text) ?? daysRemaining;
        ExpensePerDay = double.parse((walletAmount / daysRemaining).toStringAsFixed(2));
      }
      isEditing = !isEditing;
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final inputDate = DateTime(date.year, date.month, date.day);

    if (inputDate == today) {
      return 'Today';
    } else if (inputDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day} ${_getMonth(date.month)} ${date.year}';
    }
  }

  String _getMonth(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Widget _buildExpenseList() {
    // Group expenses by date
    Map<DateTime, List<Expense>> groupedExpenses = {};
    for (var expense in expenses) {
      final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
      if (!groupedExpenses.containsKey(date)) {
        groupedExpenses[date] = [];
      }
      groupedExpenses[date]!.add(expense);
    }

    return Expanded(
      child: ListView.builder(
        itemCount: groupedExpenses.length,
        itemBuilder: (context, index) {
          final date = groupedExpenses.keys.elementAt(index);
          final dayExpenses = groupedExpenses[date]!;
          final totalForDay = dayExpenses.fold<double>(
            0,
            (sum, expense) => sum + (expense.isIncome ? expense.amount : -expense.amount),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(date),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${totalForDay.toStringAsFixed(0)}\$',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ...dayExpenses.map((expense) => ListTile(
                leading: Icon(expense.category.icon),
                title: Text(expense.category.name),
                trailing: Text(
                  '${expense.isIncome ? '+' : '-'}${expense.amount.toStringAsFixed(0)}\$',
                  style: TextStyle(
                    color: expense.isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(expense.time),
              )),
              const Divider(),
            ],
          );
        },
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddScreen(
              onExpenseAdded: (expense) {
                setState(() {
                  expenses.insert(0, expense);
                  if (expense.isIncome) {
                    walletAmount += expense.amount;
                  } else {
                    walletAmount -= expense.amount;
                  }
                  ExpensePerDay = double.parse((walletAmount / daysRemaining).toStringAsFixed(2));
                });
              },
              currentWalletAmount: walletAmount,
            ),
          ),
        ).then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green),
                      SizedBox(width: 8),
                      Icon(Icons.trending_up, color: Colors.green),
                      SizedBox(width: 8),
                    ],
                  ),
                  Text(
                    '${walletAmount.toStringAsFixed(2)} on $daysRemaining days',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (isEditing) ...[
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Wallet Amount',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: daysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Days Remaining',
                    border: OutlineInputBorder(),
                  ),
                ),
              ] else ...[
                Text(
                  walletAmount.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              TextButton(
                onPressed: _toggleEdit,
                child: Text(isEditing ? 'Save' : 'Edit'),
              ),
              const Divider(),
              Text(
                '$ExpensePerDay per Day',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildExpenseList(),
            ],
          ),
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
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
} 