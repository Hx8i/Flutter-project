import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';
import 'add_screen.dart';

class HomeScreen extends StatefulWidget {
  final Expense? initialExpense;
  // Static list to maintain expenses across screen instances
  static final List<Expense> allExpenses = [
    // April 2025 (Current month)
    Expense(
      date: DateTime(DateTime.now().subtract(const Duration(days: 0)).year, DateTime.now().subtract(const Duration(days: 0)).month, DateTime.now().subtract(const Duration(days: 0)).day),
      time: '18:40',
      category: ExpenseCategory.work,
      amount: 600,
      isIncome: true,
    ),
    Expense(
      date: DateTime(DateTime.now().subtract(const Duration(days: 1)).year, DateTime.now().subtract(const Duration(days: 1)).month, DateTime.now().subtract(const Duration(days: 1)).day),
      time: '18:40',
      category: ExpenseCategory.gym,
      amount: 25,
    ),
    Expense(
      date: DateTime(DateTime.now().subtract(const Duration(days: 2)).year, DateTime.now().subtract(const Duration(days: 1)).month, DateTime.now().subtract(const Duration(days: 2)).day),
      time: '18:40',
      category: ExpenseCategory.shopping,
      amount: 55,
    ),
    Expense(
      date: DateTime(DateTime.now().subtract(const Duration(days: 2)).year, DateTime.now().subtract(const Duration(days: 2)).month, DateTime.now().subtract(const Duration(days: 2)).day),
      time: '18:39',
      category: ExpenseCategory.food,
      amount: 15,
    ),
    Expense(
      date: DateTime(DateTime.now().subtract(const Duration(days: 3)).year, DateTime.now().subtract(const Duration(days: 3)).month, DateTime.now().subtract(const Duration(days: 3)).day),
      time: '12:15',
      category: ExpenseCategory.products,
      amount: 95,
    ),

    // March 2025 Data
    Expense(
      date: DateTime(2025, 3, 15),
      time: '09:00',
      category: ExpenseCategory.work,
      amount: 600,
      isIncome: true,
    ),
    Expense(
      date: DateTime(2025, 3, 15),
      time: '14:30',
      category: ExpenseCategory.shopping,
      amount: 120,
    ),
    Expense(
      date: DateTime(2025, 3, 16),
      time: '12:00',
      category: ExpenseCategory.food,
      amount: 45,
    ),
    Expense(
      date: DateTime(2025, 3, 20),
      time: '16:45',
      category: ExpenseCategory.medicine,
      amount: 35,
    ),
    Expense(
      date: DateTime(2025, 3, 25),
      time: '08:30',
      category: ExpenseCategory.gym,
      amount: 50,
    ),

    // February 2025 Data
    Expense(
      date: DateTime(2025, 2, 1),
      time: '09:00',
      category: ExpenseCategory.work,
      amount: 600,
      isIncome: true,
    ),
    Expense(
      date: DateTime(2025, 2, 5),
      time: '13:20',
      category: ExpenseCategory.products,
      amount: 85,
    ),
    Expense(
      date: DateTime(2025, 2, 10),
      time: '15:45',
      category: ExpenseCategory.cafe,
      amount: 15,
    ),
    Expense(
      date: DateTime(2025, 2, 15),
      time: '11:30',
      category: ExpenseCategory.supplements,
      amount: 40,
    ),
    Expense(
      date: DateTime(2025, 2, 20),
      time: '17:15',
      category: ExpenseCategory.shopping,
      amount: 95,
    ),
  ];

  const HomeScreen({
    super.key,
    this.initialExpense,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late double walletAmount;
  int daysRemaining = 13;
  bool isEditing = false;
  late double ExpensePerDay;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController daysController = TextEditingController();
  int _selectedIndex = 0;
  ExpenseCategory? selectedCategory;
  bool isAscending = false;
  DateTime selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now();
    _calculateWalletAmount();
    amountController.text = walletAmount.toString();
    daysController.text = daysRemaining.toString();
    _calculateExpensePerDay();
  }

  void _calculateWalletAmount() {
    // Calculate wallet amount based on current month's transactions
    final currentMonthTransactions = HomeScreen.allExpenses.where((e) =>
      e.date.year == selectedMonth.year &&
      e.date.month == selectedMonth.month
    );

    walletAmount = double.parse(
      currentMonthTransactions.fold<double>(
        0.0,
        (sum, expense) => sum + (expense.isIncome ? expense.amount : -expense.amount)
      ).toStringAsFixed(2)
    );
  }

  void _toggleEdit() {
    setState(() {
      if (isEditing) {
        daysRemaining = int.tryParse(daysController.text) ?? daysRemaining;
        _calculateExpensePerDay();
      }
      isEditing = !isEditing;
    });
  }

  void _calculateExpensePerDay() {
    ExpensePerDay = double.parse((walletAmount / daysRemaining).toStringAsFixed(2));
  }

  void _previousMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
      _calculateWalletAmount();
      _calculateExpensePerDay();
    });
  }

  void _nextMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
      _calculateWalletAmount();
      _calculateExpensePerDay();
    });
  }

  // Update the getters for calculations to use the static list
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

  @override
  void dispose() {
    amountController.dispose();
    daysController.dispose();
    super.dispose();
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Expenses'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<ExpenseCategory>(
                    isExpanded: true,
                    value: selectedCategory,
                    hint: const Text('Select Category'),
                    items: ExpenseCategory.allCategories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(category.icon, size: 20),
                            const SizedBox(width: 8),
                            Text(category.name),
                            if (category.isCustom)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  '(Custom)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Sort by Date:'),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            isAscending = !isAscending;
                          });
                        },
                        icon: Icon(
                          isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                          color: Colors.green,
                        ),
                        label: Text(
                          !isAscending ? 'Newest First' : 'Oldest First',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = null;
                    });
                  },
                  child: const Text('Clear'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _applyFilters();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _applyFilters() {
    setState(() {
      // The filtering will be applied in the _buildExpenseList method
    });
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigate to AddScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AddScreen(
            currentWalletAmount: walletAmount,
          ),
        ),
      );
      return;
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Theme'),
                onTap: () {
                  // Theme settings implementation will go here
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                onTap: () {
                  // Notifications settings implementation will go here
                },
              ),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Backup & Restore'),
                onTap: () {
                  // Backup settings implementation will go here
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpenseList() {
    // First filter expenses by selected month
    var filteredExpenses = HomeScreen.allExpenses.where((e) => 
      e.date.year == selectedMonth.year && 
      e.date.month == selectedMonth.month
    ).toList();

    // Then filter by category if selected
    if (selectedCategory != null) {
      filteredExpenses = filteredExpenses.where((e) => e.category == selectedCategory).toList();
    }

    // Sort expenses by date and time
    filteredExpenses.sort((a, b) {
      // Compare dates first
      int dateComparison = b.date.compareTo(a.date); // Default descending (newest first)
      if (!isAscending) {
        dateComparison = -dateComparison; // Flip for ascending order
      }
      
      if (dateComparison == 0) {
        // If same date, sort by time
        return isAscending 
            ? a.time.compareTo(b.time)  // Ascending: earlier times first
            : b.time.compareTo(a.time); // Descending: later times first
      }
      return dateComparison;
    });

    // Group expenses by date
    Map<DateTime, List<Expense>> groupedExpenses = {};
    for (var expense in filteredExpenses) {
      final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
      if (!groupedExpenses.containsKey(date)) {
        groupedExpenses[date] = [];
      }
      groupedExpenses[date]!.add(expense);
    }

    if (groupedExpenses.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.receipt_long,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'No transactions in ${DateFormat('MMMM yyyy').format(selectedMonth)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: groupedExpenses.length,
        itemBuilder: (context, index) {
          final dates = groupedExpenses.keys.toList()
            ..sort((a, b) => isAscending 
                ? a.compareTo(b)  // Ascending: older dates first
                : b.compareTo(a)); // Descending: newer dates first
          final date = dates[index];
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: totalForDay >= 0 ? Colors.green : Colors.red,
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

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
                  });
                },
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
                onPressed: () {
                  setState(() {
                    selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
                  });
                },
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryCard('EXPENSE', totalExpenses, Colors.red),
              _buildSummaryCard('INCOME', totalIncome, Colors.green),
              _buildSummaryCard('TOTAL', total, total >= 0 ? Colors.green : Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
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
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        color: Colors.green,
                        onPressed: _showSettingsDialog,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        color: selectedCategory != null ? Colors.green : Colors.grey,
                        onPressed: _showFilterDialog,
                      ),
                    ],
                  ),
                  if (!isEditing)
                    Text(
                      '${walletAmount.toStringAsFixed(2)}\$ on $daysRemaining days',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
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
                  Text(
                    '$ExpensePerDay per Day',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildMonthSelector(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    
                    _buildExpenseList(),
                  ],
                ),
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
} 