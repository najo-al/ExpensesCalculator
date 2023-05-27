import 'package:flutter/material.dart';
import 'package:gradproject/components/expense_input.dart';
import 'package:gradproject/models/expenses_model.dart';
import 'package:gradproject/screens/expenses_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class ExpenseScreen extends StatefulWidget {
  final Expense? expense;
  const ExpenseScreen({Key? key, this.expense}) : super(key: key);

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();

  Future<List<Map<String, dynamic>>> getExpense(
      {DateTime? startDate, DateTime? endDate}) async {
    final _myDb = Hive.box('expenses');

    if (startDate != null && endDate != null) {
      final data = _myDb.keys.map((key) {
        final item = _myDb.get(key);
        return {
          "id": item['id'],
          "title": item['title'],
          "description": item['description'],
          "amount": item['amount'],
          "date": item['date']
        };
      }).toList();

      final filteredData = data.reversed.toList().where((element) {
        final date = element['date'];
        return date.isAfter(startDate) && date.isBefore(endDate);
      }).toList();

      return filteredData;
    }

    return await _ExpenseScreenState()._readData();
  }
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<Map<String, dynamic>> _expenses = [];

  final _myDb = Hive.box('expenses');

  void _writeData(Map<String, dynamic> data, [id]) async {
    List _temp = [];
    var tempVal;
    if (widget.expense != null) {
      await _readData().then((value) {
        tempVal = value.reversed.toList();
        return;
      });

      for (int i = 0; i < tempVal.length; i++) {
        if (tempVal[i]['id'] == id) {
          _myDb.putAt(i, data);
        }
      }

      return;
    }
    await _myDb.add(data);
    // _readData();
  }

  Future<List<Map<String, dynamic>>> _readData() async {
    final data = _myDb.keys.map((key) {
      final item = _myDb.get(key);
      return {
        "id": item['id'],
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
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _descriptionController.text = widget.expense!.description;
      _amountController.text =
          widget.expense!.amount == widget.expense!.amount.toInt().toDouble()
              ? widget.expense!.amount.toInt().toString()
              : widget.expense!.amount.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              labelText: 'Expense description (optional)',
              keyboardType: TextInputType.multiline,
              maxLines: '5',
            ),
            ExpenseInputComponent(
              controller: _amountController,
              hintText: 'Amount',
              labelText: 'Expense cost (\$)',
              keyboardType: TextInputType.number,
              // maxLines: '1',
            ),
            // DATE SELECTOR FOR DEBUGGING PURPOSES
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              width: MediaQuery.of(context).size.width * 0.9,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              child: TextButton(
                onPressed: () async {
                  FocusScope.of(context).unfocus();

                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2015, 8),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null)
                    setState(() {
                      _date = picked;
                    });
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "$_date".split(' ')[0],
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
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

                    if (title.isEmpty || amount.isEmpty) {
                      FocusScope.of(context).unfocus();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please fill all the required fields')),
                      );
                      return;
                    }
                    if (_date.day == DateTime.now().day) {
                      _date = DateTime.now();
                    }

                    if (widget.expense != null) {
                      _writeData({
                        'id': widget.expense!.id,
                        'title': _titleController.value.text,
                        'description': _descriptionController.value.text,
                        'amount': _amountController.value.text,
                        'date': _date,
                        // 'date': DateTime.now(),
                      }, widget.expense!.id);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ExpensesScreen()),
                        (route) => false,
                      );

                      return;
                    }

                    _writeData({
                      'id': const Uuid().v4(),
                      'title': _titleController.value.text,
                      'description': _descriptionController.value.text,
                      'amount': _amountController.value.text,
                      'date': _date,
                      // 'date': DateTime.now(),
                    });

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ExpensesScreen()),
                      (route) => false,
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
                  child: Text(
                    widget.expense == null ? 'Add' : 'Save',
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
