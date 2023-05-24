import 'package:flutter/material.dart';
import 'package:gradproject/components/expense_input.dart';
import 'package:gradproject/models/expenses_model.dart';
import 'package:gradproject/services/database_helper.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ExpenseScreen extends StatefulWidget {
  final Expense? expense;
  const ExpenseScreen({Key? key, this.expense}) : super(key: key);

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();

  Future<List<Map<String, dynamic>>> getExpense() async {
    return await _ExpenseScreenState()._readData();
  }
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<Map<String, dynamic>> _expenses = [];

  final _myDb = Hive.box('expenses');

  void _writeData(Map<String, dynamic> data) async {
    await _myDb.add(data);
    // _readData();
  }

  Future<List<Map<String, dynamic>>> _readData() async {
    final data = _myDb.keys.map((key) {
      final item = _myDb.get(key);
      return {
        "key": key,
        "title": item['title'],
        "description": item['description'],
        "amount": item['amount'],
        "date": item['date']
      };
    }).toList();

    _expenses = data.reversed.toList();

    return _expenses;
  }

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add an expense' : 'Edit expense'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ExpenseInputComponent(
              controller: _titleController,
              hintText: 'Title',
              labelText: 'Expense title',
              keyboardType: TextInputType.text,
              maxLines: '1',
            ),
            ExpenseInputComponent(
              controller: _descriptionController,
              hintText: 'Type here the expense',
              labelText: 'Expense description',
              keyboardType: TextInputType.multiline,
              maxLines: '5',
            ),
            ExpenseInputComponent(
              controller: _amountController,
              hintText: 'Amount',
              labelText: 'Expense amount',
              keyboardType: TextInputType.number,
              // maxLines: '1',
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: SizedBox(
                height: 45,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () async {
                    final title = _titleController.value.text;
                    final description = _descriptionController.value.text;
                    final amount = _amountController.value.text;

                    if (title.isEmpty ||
                        description.isEmpty ||
                        amount.isEmpty) {
                      return;
                    }

                    _writeData({
                      'title': _titleController.value.text,
                      'description': _descriptionController.value.text,
                      'amount': _amountController.value.text,
                      'date': DateTime.now(),
                    });

                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      const RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.white,
                          width: 0.75,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  child: Text(
                    widget.expense == null ? 'Save' : 'Edit',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
