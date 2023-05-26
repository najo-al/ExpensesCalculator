import 'package:flutter/material.dart';

class ExpenseInputComponent extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final String? maxLines;
  final TextInputType keyboardType;

  const ExpenseInputComponent({super.key, 
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.maxLines,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        controller: controller,
        maxLines: maxLines == null ? 1 : int.parse(maxLines!),
        decoration: InputDecoration(
          fillColor: Colors.grey.shade800,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            // borderSide: BorderSide(color: Colors.white, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary, width: 2.0),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            // borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            // borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
        ),
        keyboardType: keyboardType,
      ),
    );
  }
}
