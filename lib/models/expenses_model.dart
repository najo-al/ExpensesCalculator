class Expense {
  final String id;
  final String title;
  final double amount;
  final String description;
  final DateTime date;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.description,
    required this.date,
  });
}
