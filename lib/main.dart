import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Expenses Tracker',
    debugShowCheckedModeBanner: false,
    themeMode: _themeMode,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: Colors.green,
        secondary: Colors.green.shade700,
        error: Colors.red,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    darkTheme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: Colors.green,
        secondary: Colors.green.shade700,
        error: Colors.red,
        background: const Color(0xFF1A1A1A),
        surface: const Color(0xFF2C2C2C),
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF2C2C2C),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    home: HomeScreen(onThemeToggle: toggleTheme, isDarkMode: _themeMode == ThemeMode.dark),
  );
}