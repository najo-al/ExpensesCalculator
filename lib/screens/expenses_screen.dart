import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gradproject/components/expense.dart';
import 'package:gradproject/models/budget_model.dart';
import 'package:gradproject/screens/expense_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/expenses_model.dart';
import '../services/database_helper.dart';
import '../widgets/expense_widget.dart';
import 'budget_screen.dart';
import 'expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _myDb = Hive.box('expenses');

  Future<double> getExpensesCost() async {
    final expenses = await const ExpenseScreen().getExpense();
    double total = 0;
    for (var expense in expenses) {
      total += double.parse(expense['amount'].toString());
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // extendBody: true,
        bottomNavigationBar: Container(
          color: Colors.grey.shade900,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: GNav(
              selectedIndex: 0,
              // backgroundColor: Colors.grey.shade900,
              color: Colors.white,
              activeColor: Colors.white,
              tabBackgroundColor: Colors.grey.shade800,
              onTabChange: (index) {
                if (index == 1) {
                  // Hive.box('budget').clear();
                  // Hive.box('expenses').clear();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BudgetScreen()));
                }
              },
              padding: const EdgeInsets.all(16),
              tabs: [
                const GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                const GButton(
                  icon: Icons.settings,
                  text: 'Settings',
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 17, 17, 17),
        appBar: AppBar(
          title: const Text('Expenses'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ExpenseScreen()));
            // setState(() {});
          },
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.18,
              width: MediaQuery.of(context).size.width,
              child: FutureBuilder(
                future: const BudgetScreen().getBudget(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    final budget = snapshot.data;
                    if (budget != null) {
                      return FutureBuilder(
                        future: getExpensesCost(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            final expensesCost = snapshot.data;
                            return Container(
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.all(10),
                                height: 600,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0, 2),
                                      blurRadius: 6.0,
                                    )
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      'Budget: ${budget.toStringAsFixed(1)}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Remainder: ${(budget - expensesCost!).toStringAsFixed(1)}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ));
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      );
                    } else {
                      return const Text('Please add a budget first!');
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
            Flexible(
              child: FutureBuilder(
                future: const ExpenseScreen().getExpense(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    final expenses = snapshot.data;
                    if (expenses != null) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final currentExpense = expenses[index];
                          return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 32, 32, 32),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 2),
                                    blurRadius: 6.0,
                                  )
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ExpenseComponent(
                                      title: 'Title: ',
                                      value: currentExpense['title']),
                                  ExpenseComponent(
                                      title: 'Description: ',
                                      value: currentExpense['description']),
                                  ExpenseComponent(
                                      title: 'Amount: ',
                                      value:
                                          currentExpense['amount'].toString()),
                                  ExpenseComponent(
                                    title: 'Date: ',
                                    value: DateFormat('dd/MM/yy kk:mm')
                                        .format(currentExpense['date'])
                                        .toString(),
                                  ),
                                ],
                              ));
                        },
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ));
  }
}
