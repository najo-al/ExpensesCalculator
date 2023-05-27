import 'package:flutter/material.dart';

class ExpenseComponent extends StatelessWidget {
  final String title;
  final String value;

  const ExpenseComponent({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: title,
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 18,
        ),
        children: <TextSpan>[
          TextSpan(
            text: value,
            style: const TextStyle(
              overflow: TextOverflow.visible,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
