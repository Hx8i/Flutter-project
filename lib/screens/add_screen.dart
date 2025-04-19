import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'home_screen.dart';
import 'stats_screen.dart';

class AddScreen extends StatefulWidget {
  final double currentWalletAmount;
  final Function() onThemeToggle;
  final bool isDarkMode;

  const AddScreen({
    super.key,
    required this.currentWalletAmount,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController amountController = TextEditingController();
  ExpenseCategory selectedCategory = ExpenseCategory.food;
  bool isIncome = false;
  final TextEditingController noteController = TextEditingController();
  int _selectedIndex = 1;
  DateTime selectedDate = DateTime.now();
  bool isRecurring = false;
  String recurrenceType = 'Weekly'; // Weekly, Monthly, Yearly
  int recurrenceCount = 1;

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(
          onThemeToggle: widget.onThemeToggle,
          isDarkMode: widget.isDarkMode,
        )),
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
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget _buildRecurrenceOptions() {
    if (!isRecurring) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Recurrence',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: recurrenceType,
                decoration: InputDecoration(
                  labelText: 'Frequency',
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                  border: OutlineInputBorder(),
                ),
                items: ['Weekly', 'Monthly', 'Yearly'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      recurrenceType = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Repeat for',
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                  border: OutlineInputBorder(),
                  suffixText: 'times',
                ),
                onChanged: (value) {
                  setState(() {
                    recurrenceCount = int.tryParse(value) ?? 1;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _addExpense() {
    if (amountController.text.isEmpty) return;

    final now = DateTime.now();
    final baseExpense = Expense(
      date: selectedDate,
      time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      category: selectedCategory,
      amount: double.parse(amountController.text),
      isIncome: isIncome,
      note: noteController.text.isEmpty ? null : noteController.text,
    );

    if (isRecurring) {
      final List<Expense> recurringExpenses = [];
      for (int i = 0; i < recurrenceCount; i++) {
        final newDate = _getNextRecurrenceDate(selectedDate, i);
        recurringExpenses.add(Expense(
          date: newDate,
          time: baseExpense.time,
          category: baseExpense.category,
          amount: baseExpense.amount,
          isIncome: baseExpense.isIncome,
          note: baseExpense.note,
        ));
      }
      HomeScreen.allExpenses.addAll(recurringExpenses);
    } else {
      HomeScreen.allExpenses.add(baseExpense);
    }

    HomeScreen.allExpenses.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);
      if (dateComparison == 0) {
        return b.time.compareTo(a.time);
      }
      return dateComparison;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          onThemeToggle: widget.onThemeToggle,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
  }

  DateTime _getNextRecurrenceDate(DateTime startDate, int index) {
    switch (recurrenceType) {
      case 'Weekly':
        return startDate.add(Duration(days: 7 * index));
      case 'Monthly':
        return DateTime(startDate.year, startDate.month + index, startDate.day);
      case 'Yearly':
        return DateTime(startDate.year + index, startDate.month, startDate.day);
      default:
        return startDate;
    }
  }

  void _showAddCategoryDialog() {
    final TextEditingController categoryNameController = TextEditingController();
    IconData selectedIcon = Icons.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryNameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select Icon:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Icons.shopping_cart,
                  Icons.restaurant,
                  Icons.local_hospital,
                  Icons.sports,
                  Icons.work,
                  Icons.shopping_bag,
                  Icons.coffee,
                  Icons.more_horiz,
                  Icons.fitness_center,
                  Icons.movie,
                  Icons.music_note,
                  Icons.pets,
                  Icons.school,
                  Icons.car_rental,
                  Icons.house,
                  Icons.phone_android,
                ].map((icon) => InkWell(
                  onTap: () {
                    setState(() {
                      selectedIcon = icon;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedIcon == icon ? Colors.green : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (categoryNameController.text.isNotEmpty) {
                  final newCategory = ExpenseCategory.custom(
                    categoryNameController.text,
                    selectedIcon,
                  );
                  setState(() {
                    selectedCategory = newCategory;
                  });
                  Navigator.pop(context);
                  this.setState(() {});
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isIncome ? 'Add Income' : 'Add Expense'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.1),
                        theme.colorScheme.primary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          labelStyle: TextStyle(color: theme.colorScheme.onBackground),
                          border: OutlineInputBorder(),
                          prefixText: '\$',
                          prefixStyle: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: Text('Expense', 
                              style: TextStyle(
                                color: !isIncome ? Colors.white : theme.colorScheme.onBackground,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            selected: !isIncome,
                            onSelected: (selected) {
                              setState(() {
                                isIncome = !selected;
                              });
                            },
                          ),
                          const SizedBox(width: 16),
                          ChoiceChip(
                            label: Text('Income',
                              style: TextStyle(
                                color: isIncome ? Colors.white : theme.colorScheme.onBackground,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            selected: isIncome,
                            onSelected: (selected) {
                              setState(() {
                                isIncome = selected;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<ExpenseCategory>(
                        value: selectedCategory,
                        style: TextStyle(color: theme.colorScheme.onBackground),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: TextStyle(color: theme.colorScheme.onBackground),
                          border: OutlineInputBorder(),
                        ),
                        items: ExpenseCategory.allCategories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Icon(category.icon, color: theme.colorScheme.onBackground),
                                const SizedBox(width: 8),
                                Text(category.name, style: TextStyle(color: theme.colorScheme.onBackground)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _showAddCategoryDialog,
                      icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      labelStyle: TextStyle(color: theme.colorScheme.onBackground),
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: TextStyle(fontSize: 16, color: theme.colorScheme.onBackground),
                        ),
                        Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(
                    'Recurring Transaction',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  subtitle: Text(
                    'Set up a regular transaction',
                    style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.7)),
                  ),
                  value: isRecurring,
                  onChanged: (value) {
                    setState(() {
                      isRecurring = value;
                    });
                  },
                  activeColor: theme.colorScheme.primary,
                ),
                _buildRecurrenceOptions(),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  style: TextStyle(color: theme.colorScheme.onBackground),
                  decoration: InputDecoration(
                    labelText: 'Note (Optional)',
                    labelStyle: TextStyle(color: theme.colorScheme.onBackground),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _addExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Add Transaction',
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
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
} 