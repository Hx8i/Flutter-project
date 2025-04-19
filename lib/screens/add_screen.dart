import 'package:flutter/material.dart';
import '../models/expense.dart';

class AddScreen extends StatefulWidget {
  final Function(Expense) onExpenseAdded;
  final double currentWalletAmount;

  const AddScreen({
    super.key,
    required this.onExpenseAdded,
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
  final List<ExpenseCategory> customCategories = [];
  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
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

    final expense = Expense(
      date: selectedDate,
      time: '${DateTime.now().hour}:${DateTime.now().minute}',
      category: selectedCategory,
      amount: double.parse(amountController.text),
      isIncome: isIncome,
      note: noteController.text,
    );

    widget.onExpenseAdded(expense);
    Navigator.pop(context);
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
            ElevatedButton(
              onPressed: () {
                if (categoryNameController.text.isNotEmpty) {
                  final newCategory = ExpenseCategory.custom(
                    categoryNameController.text,
                    selectedIcon,
                  );
                  setState(() {
                    customCategories.add(newCategory);
                    selectedCategory = newCategory;
                  });
                  Navigator.pop(context);
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
    final allCategories = [...ExpenseCategory.defaultCategories, ...customCategories];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Transaction'),
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
                      items: allCategories.map((category) {
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
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.green),
                    ],
                  ),
                ),
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
    );
  }
} 