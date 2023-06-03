// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:gradproject/screens/expenses_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  await Hive.initFlutter();

  var expensesBox = await Hive.openBox('expenses');
  var budgetBox = await Hive.openBox('budget');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: child!,
        );
      },
      title: 'Flutter Local Database demo app',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.grey.shade900,
          secondary: Color.fromARGB(255, 107, 53, 78),
          tertiary: Colors.grey.shade800,
          background: const Color.fromARGB(255, 17, 17, 17),
        ),
      ),
      home: const ExpensesScreen(),
    );
  }
}
