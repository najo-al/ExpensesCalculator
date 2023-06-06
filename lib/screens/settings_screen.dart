import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gradproject/components/expense_input.dart';
import 'package:gradproject/models/budget_model.dart';
import 'package:gradproject/screens/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BudgetScreen extends StatefulWidget {
  final Budget? budget;
  const BudgetScreen({Key? key, this.budget}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();

  Future<double> getBudget() async {
    return await _BudgetScreenState()._readData();
  }
}

class _BudgetScreenState extends State<BudgetScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _myDb = Hive.box('budget');

  void _writeData(double budget) async {
    await _myDb.put(0, budget);
  }

  Future<double> _readData() async {
    final data = _myDb.get(0);
    return data;
  }

  final budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_myDb.get(0) != null) {
      budgetController.text = _myDb.get(0) == _myDb.get(0).toInt()
          ? _myDb.get(0).toInt().toString()
          : _myDb.get(0).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.background,
        bottomNavigationBar: Container(
          color: Colors.grey.shade900,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: GNav(
              selectedIndex: 1,
              backgroundColor: Colors.grey.shade900,
              color: Colors.white,
              activeColor: Colors.white,
              tabBackgroundColor: Colors.grey.shade800,
              onTabChange: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      transitionDuration:
                          Duration.zero,
                      pageBuilder: (_, __, ___) => const ExpensesScreen(),
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
        appBar: AppBar(
          title: Icon(
            Icons.payments_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.secondary,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(children: [
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Set your budget',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ExpenseInputComponent(
              controller: budgetController,
              hintText: 'Enter your budget',
              labelText: 'Budget (₺)',
              keyboardType: TextInputType.number,
            ),
            SizedBox(
              height: 45,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () async {
                  final budget = budgetController.value.text;

                  if (budget.isEmpty) {
                    const snackBar = SnackBar(
                      content: Text('Please enter a budget!'),
                    );
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    return;
                  }

                  _writeData(double.parse(budget));

                  FocusScope.of(context).unfocus();

                  const snackBar = SnackBar(
                    content: Text('Budget updated!'),
                  );

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.secondary,
                  ),
                  shape: MaterialStateProperty.all(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Delete all expenses',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 45,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Delete all expenses'),
                        content: const Text(
                            'Are you sure you want to delete all expenses?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await Hive.box('expenses').clear();
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: Duration
                                      .zero,
                                  pageBuilder: (_, __, ___) =>
                                      const ExpensesScreen(),
                                ),
                              );
                              const snackBar = SnackBar(
                                content: Text('Expenses reset!'),
                              );
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.secondary,
                  ),
                  shape: MaterialStateProperty.all(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ]),
        ));
  }
}
