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
  late Future<List<Map<String, dynamic>>> _expensesFuture;
  String label = 'Today';

  Future<double> getExpensesCost() async {
    final expenses = await const ExpenseScreen().getExpense();
    double total = 0;
    for (var expense in expenses) {
      total += double.parse(expense['amount'].toString());
    }
    return total;
  }

  Future<void> deleteItem(int index) async {
    List newList = _myDb.values.toList().reversed.toList();

    newList.removeAt(index);

    await _myDb.clear();
    if (newList.isNotEmpty) {
      for (int i = 0; i < newList.length; i++) {
        await _myDb.add(newList[i]);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _expensesFuture =
        ExpenseScreen().getExpense(startDate: today, endDate: now);
    label = 'Today';
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
            // print(_myDb.values.toList());
            // Hive.box('expenses').clear();
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
                                  color:
                                      Theme.of(context).colorScheme.secondary,
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
                                      'Budget: \$${budget == budget.toInt().toDouble() ? budget.toInt() : budget.toStringAsFixed(1)}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Remainder: \$${(budget - expensesCost!) == (budget - expensesCost!).toInt().toDouble() ? (budget - expensesCost).toInt() : (budget - expensesCost!).toStringAsFixed(1)}',
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
            // select date range (today, last week, last month)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    setState(() {
                      _expensesFuture =
                          ExpenseScreen().getExpense(startDate: today);
                    });
                    label = 'Today';
                  },
                  child: const Text('Today'),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor:
                          label == 'Today' ? Colors.grey.shade800 : null),
                ),
                ElevatedButton(
                  onPressed: () {
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final lastWeek = today.subtract(const Duration(days: 7));
                    setState(() {
                      _expensesFuture = ExpenseScreen()
                          .getExpense(startDate: lastWeek, endDate: now);
                    });
                    label = 'Last Week';
                  },
                  child: const Text('Last Week'),
                  // button color
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor:
                          label == 'Last Week' ? Colors.grey.shade800 : null),
                ),
                ElevatedButton(
                  onPressed: () {
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final lastMonth = today.subtract(const Duration(days: 30));
                    setState(() {
                      _expensesFuture = ExpenseScreen()
                          .getExpense(startDate: lastMonth, endDate: now);
                    });
                    label = 'Last Month';
                  },
                  child: const Text('Last Month'),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor:
                          label == 'Last Month' ? Colors.grey.shade800 : null),
                ),
              ],
            ),
            Flexible(
              child: FutureBuilder(
                future: _expensesFuture,
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
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ExpenseComponent(
                                          title: 'Title: ',
                                          value: currentExpense['title']),
                                      ExpenseComponent(
                                          title: 'Description: ',
                                          value: currentExpense['description']),
                                      ExpenseComponent(
                                          title: 'Amount: ',
                                          value: currentExpense['amount']
                                              .toString()),
                                      ExpenseComponent(
                                        title: 'Date: ',
                                        value: DateFormat('dd/MM/yy kk:mm')
                                            .format(currentExpense['date'])
                                            .toString(),
                                      ),
                                      // button
                                    ],
                                  ),
                                  const Spacer(),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                        ),
                                        onPressed: () async {
                                          // print(index);
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ExpenseScreen(
                                                          expense: Expense(
                                                        id: currentExpense[
                                                            'id'],
                                                        title: currentExpense[
                                                            'title'],
                                                        description:
                                                            currentExpense[
                                                                'description'],
                                                        amount: double.parse(
                                                            currentExpense[
                                                                'amount']),
                                                        date: currentExpense[
                                                            'date'],
                                                      ))));
                                          // setState(() {});
                                        },
                                        child: const Icon(Icons.edit),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                        ),
                                        onPressed: () async {
                                          // pop up window
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Are you sure you want to delete this expense?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      // print(
                                                      //     'ere ${_myDb.values.toList()}');
                                                      await deleteItem(index);
                                                      // print(
                                                      //     'ereee ${_myDb.values.toList()}');
                                                      // await _myDb.compact();
                                                      setState(() {});
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Yes'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          // await _myDb.deleteAt(index);
                                          // setState(() {});
                                        },
                                        child: const Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                              //
                              );
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
