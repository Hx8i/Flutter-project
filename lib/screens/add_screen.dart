import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'home_screen.dart';

class AddScreen extends StatefulWidget {
  final double currentWalletAmount;

  const AddScreen({
    super.key,
    required this.currentWalletAmount,
  });

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController amountController = TextEditingController();
  ExpenseCategory selectedCategory = ExpenseCategory.food;
  bool isIncome = false;
  final TextEditingController noteController = TextEditingController();
  int _selectedIndex = 1; // Start with Add tab selected

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      // Navigate to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _addExpense() {
    if (amountController.text.isEmpty) return;

    final now = DateTime.now();
    final expense = Expense(
      date: now,
      time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      category: selectedCategory,
      amount: double.parse(amountController.text),
      isIncome: isIncome,
      note: noteController.text.isEmpty ? null : noteController.text,
    );

    // Add the expense to the static list
    HomeScreen.allExpenses.add(expense);

    // Navigate back to HomeScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
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
                  // Set the new category as selected
                  setState(() {
                    selectedCategory = newCategory;
                  });
                  Navigator.pop(context);
                  // Rebuild the main screen to show the new category
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isIncome ? 'Add Income' : 'Add Expense'),
        backgroundColor: Colors.white,
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
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Type: '),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Expense'),
                    selected: !isIncome,
                    onSelected: (selected) {
                      setState(() {
                        isIncome = !selected;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Income'),
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
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: ExpenseCategory.allCategories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(category.icon),
                              const SizedBox(width: 8),
                              Text(category.name),
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
                    icon: const Icon(Icons.add_circle_outline),
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _addExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Add Transaction',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
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
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
} 