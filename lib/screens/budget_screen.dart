import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gradproject/components/expense_input.dart';
import 'package:gradproject/models/budget_model.dart';
import 'package:gradproject/screens/expenses_screen.dart';
import 'package:gradproject/services/database_helper.dart';
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
  final _myDb = Hive.box('budget');

  void _writeData(double budget) async {
    await _myDb.put(0, budget);
    print(_myDb.get(0));
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
      budgetController.text = _myDb.get(0).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                //push replacement
                if (index == 0) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ExpensesScreen()));
                }
              },
              padding: EdgeInsets.all(16),
              tabs: [
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
          title: const Text('Budget'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Column(children: [
            const SizedBox(height: 20),
            ExpenseInputComponent(
              controller: budgetController,
              hintText: 'Enter your budget',
              labelText: 'Budget',
              keyboardType: TextInputType.number,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: SizedBox(
                height: 45,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () async {
                    // databaseFactory.deleteDatabase('budget.db');
                    final budget = budgetController.value.text;

                    if (budget.isEmpty) {
                      return;
                    }

                    _writeData(double.parse(budget));

                    FocusScope.of(context).unfocus();
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
                  child: Text(
                    'Save',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ]),
        ));
  }
}
