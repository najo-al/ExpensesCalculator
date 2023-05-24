class Expense {
  final int? id;
  final String title;
  final double amount;
  final String description;
  final DateTime date;

  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.description,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json["id"],
        title: json["title"],
        amount: json["amount"],
        description: json["description"],
        date: DateTime.parse(json["date"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "amount": amount,
        "description": description,
        "date": date.toIso8601String(),
      };
}
