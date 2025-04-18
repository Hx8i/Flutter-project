import 'package:flutter/material.dart';

enum ExpenseCategory {
  gym,
  shopping,
  food,
  products,
  other,
  medicine,
  work,
  supplements,
  cafe
}

extension ExpenseCategoryExtension on ExpenseCategory {
  IconData get icon {
    switch (this) {
      case ExpenseCategory.gym:
        return Icons.fitness_center;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.food:
        return Icons.fastfood;
      case ExpenseCategory.products:
        return Icons.shopping_cart;
      case ExpenseCategory.other:
        return Icons.more_horiz;
      case ExpenseCategory.medicine:
        return Icons.medical_services;
      case ExpenseCategory.work:
        return Icons.work;
      case ExpenseCategory.supplements:
        return Icons.medication;
      case ExpenseCategory.cafe:
        return Icons.coffee;
    }
  }
}

class Expense {
  final DateTime date;
  final String time;
  final ExpenseCategory category;
  final double amount;
  final bool isIncome;

  Expense({
    required this.date,
    required this.time,
    required this.category,
    required this.amount,
    this.isIncome = false,
  });
} 