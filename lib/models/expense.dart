import 'package:flutter/material.dart';

class ExpenseCategory {
  final String name;
  final IconData icon;
  final bool isCustom;

  const ExpenseCategory._(this.name, this.icon, {this.isCustom = false});

  static const gym = ExpenseCategory._('Gym', Icons.fitness_center);
  static const shopping = ExpenseCategory._('Shopping', Icons.shopping_bag);
  static const food = ExpenseCategory._('Food', Icons.fastfood);
  static const products = ExpenseCategory._('Products', Icons.shopping_cart);
  static const other = ExpenseCategory._('Other', Icons.more_horiz);
  static const medicine = ExpenseCategory._('Medicine', Icons.medical_services);
  static const work = ExpenseCategory._('Work', Icons.work);
  static const supplements = ExpenseCategory._('Supplements', Icons.medication);
  static const cafe = ExpenseCategory._('Cafe', Icons.coffee);

  static List<ExpenseCategory> get defaultCategories => [
    gym,
    shopping,
    food,
    products,
    other,
    medicine,
    work,
    supplements,
    cafe,
  ];

  static ExpenseCategory custom(String name, IconData icon) {
    return ExpenseCategory._(name, icon, isCustom: true);
  }

  @override
  String toString() => name;
}

class Expense {
  final DateTime date;
  final String time;
  final ExpenseCategory category;
  final double amount;
  final bool isIncome;
  final String? note;

  Expense({
    required this.date,
    required this.time,
    required this.category,
    required this.amount,
    this.isIncome = false,
    this.note,
  });
} 