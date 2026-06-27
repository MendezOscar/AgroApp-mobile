class MonthlyCostEntity {
  final int year;
  final int month;
  final double fertilizationCost;
  final double laborCost;
  final double totalCost;

  const MonthlyCostEntity({
    required this.year,
    required this.month,
    required this.fertilizationCost,
    required this.laborCost,
    required this.totalCost,
  });
}
