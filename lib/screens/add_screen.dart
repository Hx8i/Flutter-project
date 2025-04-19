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

  void _addExpense() {
    if (amountController.text.isEmpty) return;

    final now = DateTime.now();
    final expense = Expense(
      date: selectedDate,
      time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      category: selectedCategory,
      amount: double.parse(amountController.text),
      isIncome: isIncome,
      note: noteController.text.isEmpty ? null : noteController.text,
    );

    HomeScreen.allExpenses.add(expense);

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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: theme.colorScheme.onBackground),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: theme.colorScheme.onBackground),
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                  prefixStyle: TextStyle(color: theme.colorScheme.onBackground),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('Type: ', style: TextStyle(color: theme.colorScheme.onBackground)),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: Text('Expense', style: TextStyle(color: !isIncome ? Colors.white : theme.colorScheme.onBackground)),
                    selected: !isIncome,
                    onSelected: (selected) {
                      setState(() {
                        isIncome = !selected;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: Text('Income', style: TextStyle(color: isIncome ? Colors.white : theme.colorScheme.onBackground)),
                    selected: isIncome,
                    onSelected: (selected) {
                      setState(() {
                        isIncome = selected;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
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
              const Spacer(),
              ElevatedButton(
                onPressed: _addExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Add Transaction',
                  style: TextStyle(
                    fontSize: 18,
                    color: theme.colorScheme.onPrimary,
                  ),
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
} 