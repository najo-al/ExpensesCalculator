import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gradproject/components/expense.dart';
import 'package:gradproject/components/budget_widget.dart';
import 'package:gradproject/screens/expense_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/expenses_model.dart';
import 'settings_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

  Future<void> deleteItem(String id) async {
    List newList = _myDb.values.toList().reversed.toList();

    newList.removeWhere((element) => element['id'] == id);

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
        const ExpenseScreen().getExpense(startDate: today, endDate: now);
    label = 'Today';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: Container(
          color: Colors.grey.shade900,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: GNav(
              selectedIndex: 0,
              color: Colors.white,
              activeColor: Colors.white,
              tabBackgroundColor: Colors.grey.shade800,
              onTabChange: (index) {
                if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      transitionDuration:
                          Duration.zero,
                      pageBuilder: (_, __, ___) => const BudgetScreen(),
                    ),
                  );
                }
              },
              padding: const EdgeInsets.all(16),
              tabs: const [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.settings,
                  text: 'Settings',
                ),
              ],
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 17, 17, 17),
        appBar: AppBar(
          title: Icon(
            Icons.payments_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.secondary,
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ExpenseScreen()));
          },
          child: const Icon(
            Icons.add,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.20,
                width: MediaQuery.of(context).size.width,
                child: BudgetWidget(
                  getExpensesCost: getExpensesCost,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // TODAY
                  ElevatedButton(
                    onPressed: () {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      setState(() {
                        _expensesFuture = const ExpenseScreen()
                            .getExpense(startDate: today, endDate: now);
                      });
                      label = 'Today';
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor:
                            label == 'Today' ? Colors.grey.shade700 : null),
                    child: const Text('Today'),
                  ),
                  // LAST WEEK
                  ElevatedButton(
                    onPressed: () {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final lastWeek = today.subtract(const Duration(days: 7));
                      setState(() {
                        _expensesFuture = const ExpenseScreen()
                            .getExpense(startDate: lastWeek, endDate: now);
                      });
                      label = 'Last Week';
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor:
                            label == 'Last Week' ? Colors.grey.shade700 : null),
                    child: const Text('Last Week'),
                  ),
                  // LAST MONTH
                  ElevatedButton(
                    onPressed: () {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final lastMonth =
                          today.subtract(const Duration(days: 30));
                      setState(() {
                        _expensesFuture = const ExpenseScreen()
                            .getExpense(startDate: lastMonth, endDate: now);
                      });
                      label = 'Last Month';
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: label == 'Last Month'
                            ? Colors.grey.shade700
                            : null),
                    child: const Text('Last Month'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final dateRange = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(DateTime.now().year - 5),
                        lastDate: DateTime.now(),
                      );
                      if (dateRange != null) {
                        setState(() {
                          _expensesFuture = const ExpenseScreen().getExpense(
                              startDate: dateRange.start,
                              endDate: dateRange.end);
                        });
                        label = 'Custom Range';
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor:
                          label == 'Custom Range' ? Colors.grey.shade700 : null,
                    ),
                    child: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    )
                  ],
                ),
                height: 350,
                width: double.infinity,
                child: FutureBuilder(
                  future: _expensesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.done) {
                      final expenses = snapshot.data;
                      if (expenses != null) {
                        if (expenses.isEmpty) {
                          return const Center(
                              child: Text(
                            'No expenses found in selected period!',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ));
                        }
                        return Scrollbar(
                          child: ListView.builder(
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
                                    color:
                                        const Color.fromARGB(255, 32, 32, 32),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 230,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ExpenseComponent(
                                                title: 'Title: ',
                                                value: currentExpense['title']),
                                            ExpenseComponent(
                                                title: 'Description: ',
                                                value: currentExpense[
                                                            'description'] ==
                                                        ''
                                                    ? 'No description'
                                                    : currentExpense[
                                                        'description']),
                                            ExpenseComponent(
                                                title: 'Amount: ',
                                                value: currentExpense['amount']
                                                    .toString()),
                                            ExpenseComponent(
                                              title: 'Date: ',
                                              value: DateFormat(
                                                      'dd/MM/yy kk:mm')
                                                  .format(
                                                      currentExpense['date'])
                                                  .toString(),
                                            ),
                                          ],
                                        ),
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
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ExpenseScreen(
                                                              expense: Expense(
                                                            id: currentExpense[
                                                                'id'],
                                                            title:
                                                                currentExpense[
                                                                    'title'],
                                                            description:
                                                                currentExpense[
                                                                    'description'],
                                                            amount: double.parse(
                                                                currentExpense[
                                                                    'amount']),
                                                            date:
                                                                currentExpense[
                                                                    'date'],
                                                          ))));
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
                                              await showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Are you sure you want to delete this expense?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          await deleteItem(
                                                              currentExpense[
                                                                      'id']
                                                                  .toString());
                                                          final now =
                                                              DateTime.now();
                                                          final today =
                                                              DateTime(
                                                                  now.year,
                                                                  now.month,
                                                                  now.day);
                                                          if (label ==
                                                              'Today') {
                                                            _expensesFuture =
                                                                const ExpenseScreen()
                                                                    .getExpense(
                                                                        startDate:
                                                                            today,
                                                                        endDate:
                                                                            now);
                                                          }
                                                          if (label ==
                                                              'Last Week') {
                                                            _expensesFuture = const ExpenseScreen().getExpense(
                                                                startDate: today
                                                                    .subtract(
                                                                        const Duration(
                                                                            days:
                                                                                7)),
                                                                endDate: now);
                                                          }
                                                          if (label ==
                                                              'Last Month') {
                                                            _expensesFuture = const ExpenseScreen().getExpense(
                                                                startDate: today
                                                                    .subtract(
                                                                        const Duration(
                                                                            days:
                                                                                30)),
                                                                endDate: now);
                                                          }
                                                          setState(() {});
                                                          Navigator.pop(
                                                              context);
                                                          const snackBar =
                                                              SnackBar(
                                                            content: Text(
                                                                'Expense deleted!'),
                                                          );
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .hideCurrentSnackBar();
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  snackBar);
                                                        },
                                                        child:
                                                            const Text('Yes'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: const Icon(Icons.delete),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ));
                            },
                          ),
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
          ),
        ));
  }
}
