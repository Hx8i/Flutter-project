import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';
import 'add_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  final Expense? initialExpense;
  final Function() onThemeToggle;
  final bool isDarkMode;
  static final List<Expense> allExpenses = [
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
    required this.onThemeToggle,
    required this.isDarkMode,
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
    final previousMonthsTotal = HomeScreen.allExpenses
        .where((e) => 
          e.date.year < selectedMonth.year || 
          (e.date.year == selectedMonth.year && e.date.month < selectedMonth.month)
        )
        .fold<double>(
          0.0,
          (sum, expense) => sum + (expense.isIncome ? expense.amount : -expense.amount)
        );

    final currentMonthTransactions = HomeScreen.allExpenses
        .where((e) => 
          e.date.year == selectedMonth.year && 
          e.date.month == selectedMonth.month
        )
        .fold<double>(
          0.0,
          (sum, expense) => sum + (expense.isIncome ? expense.amount : -expense.amount)
        );

    walletAmount = double.parse(
      (previousMonthsTotal + currentMonthTransactions).toStringAsFixed(2)
    );
  }

  void _toggleEdit() {
    setState(() {
      if (isEditing) {
        final newAmount = double.tryParse(amountController.text);
        if (newAmount != null && newAmount >= 0) {
          walletAmount = double.parse(newAmount.toStringAsFixed(2));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid amount'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final newDays = int.tryParse(daysController.text);
        if (newDays != null && newDays > 0) {
          daysRemaining = newDays;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid number of days'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        _calculateExpensePerDay();
      } else {
        amountController.text = walletAmount.toStringAsFixed(2);
        daysController.text = daysRemaining.toString();
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
    setState(() {});
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AddScreen(
            currentWalletAmount: walletAmount,
            onThemeToggle: widget.onThemeToggle,
            isDarkMode: widget.isDarkMode,
          ),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StatsScreen(
            onThemeToggle: widget.onThemeToggle,
            isDarkMode: widget.isDarkMode,
          ),
        ),
      );
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
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Backup & Restore'),
                onTap: () {},
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

  void _deleteExpense(Expense expense) {
    setState(() {
      HomeScreen.allExpenses.remove(expense);
      _calculateWalletAmount();
      _calculateExpensePerDay();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
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
                          color: theme.colorScheme.primary,
                          onPressed: _showSettingsDialog,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                          color: theme.colorScheme.primary,
                          onPressed: widget.onThemeToggle,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.filter_list),
                          color: selectedCategory != null ? theme.colorScheme.primary : Colors.grey,
                          onPressed: _showFilterDialog,
                        ),
                      ],
                    ),
                    if (!isEditing)
                      Text(
                        '${walletAmount.toStringAsFixed(2)}\$ on $daysRemaining days',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
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
                        decoration: InputDecoration(
                          labelText: 'Wallet Amount',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.account_balance_wallet, color: theme.colorScheme.primary),
                          prefixText: '\$',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: daysController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Days Remaining',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Available Balance',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onBackground.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${walletAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'for $daysRemaining days',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onBackground.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.primary),
                      ),
                      child: TextButton.icon(
                        onPressed: _toggleEdit,
                        icon: Icon(
                          isEditing ? Icons.save : Icons.edit,
                          color: theme.colorScheme.primary,
                        ),
                        label: Text(
                          isEditing ? 'Save' : 'Edit',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onBackground.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wallet, 
                            color: theme.colorScheme.onBackground.withOpacity(0.7)
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${ExpensePerDay.toStringAsFixed(2)} per Day',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildMonthSelector(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildExpenseList(),
                  ],
                ),
              ),
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

  Widget _buildMonthSelector() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.onBackground.withOpacity(0.1),
            width: 0.5,
          ),
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
                onPressed: () {
                  setState(() {
                    selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
                  });
                },
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryCard('EXPENSE', totalExpenses, theme.colorScheme.error),
              _buildSummaryCard('INCOME', totalIncome, theme.colorScheme.primary),
              _buildSummaryCard('TOTAL', total, total >= 0 ? theme.colorScheme.primary : theme.colorScheme.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
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

  Widget _buildExpenseList() {
    final theme = Theme.of(context);
    var filteredExpenses = HomeScreen.allExpenses.where((e) => 
      e.date.year == selectedMonth.year && 
      e.date.month == selectedMonth.month
    ).toList();

    if (selectedCategory != null) {
      filteredExpenses = filteredExpenses.where((e) => e.category == selectedCategory).toList();
    }

    filteredExpenses.sort((a, b) {
      int dateComparison = b.date.compareTo(a.date);
      if (!isAscending) {
        dateComparison = -dateComparison;
      }
      
      if (dateComparison == 0) {
        return isAscending 
            ? a.time.compareTo(b.time)
            : b.time.compareTo(a.time);
      }
      return dateComparison;
    });

    Map<DateTime, List<Expense>> groupedExpenses = {};
    for (var expense in filteredExpenses) {
      final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
      if (!groupedExpenses.containsKey(date)) {
        groupedExpenses[date] = [];
      }
      groupedExpenses[date]!.add(expense);
    }

    if (groupedExpenses.isEmpty) {
      return Center(
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
      );
    }

    final dates = groupedExpenses.keys.toList()
      ..sort((a, b) => isAscending 
          ? a.compareTo(b)
          : b.compareTo(a));

    return Column(
      children: dates.map((date) {
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  Text(
                    '${totalForDay.toStringAsFixed(0)}\$',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: totalForDay >= 0 ? theme.colorScheme.primary : theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
            ...dayExpenses.map((expense) => Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.onBackground.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (expense.isIncome ? theme.colorScheme.primary : theme.colorScheme.error).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    expense.category.icon,
                    color: expense.isIncome ? theme.colorScheme.primary : theme.colorScheme.error,
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      expense.category.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    Text(
                      '${expense.isIncome ? '+' : '-'}${expense.amount.toStringAsFixed(0)}\$',
                      style: TextStyle(
                        color: expense.isIncome ? theme.colorScheme.primary : theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.time,
                      style: TextStyle(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    if (expense.note != null && expense.note!.isNotEmpty)
                      Text(
                        expense.note!,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
                trailing: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    onPressed: () => _deleteExpense(expense),
                  ),
                ),
              ),
            )),
            Divider(color: theme.colorScheme.onBackground.withOpacity(0.1)),
          ],
        );
      }).toList(),
    );
  }
} 