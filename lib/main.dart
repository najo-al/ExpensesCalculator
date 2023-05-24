import 'package:flutter/material.dart';
import 'package:gradproject/screens/expenses_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
      title: 'Flutter Local Database demo app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.grey.shade900,
          secondary: Color.fromARGB(255, 230, 169, 197),
          tertiary: Colors.grey.shade800,
          background: Color.fromARGB(255, 17, 17, 17),
        ),
      ),
      home: const ExpensesScreen(),
    );
  }
}
