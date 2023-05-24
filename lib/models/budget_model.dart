class Budget {
  final int? id;
  final double budget;

  const Budget({
    this.id,
    required this.budget,
  });

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        id: json["id"],
        budget: json["budget"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "budget": budget,
      };
}
