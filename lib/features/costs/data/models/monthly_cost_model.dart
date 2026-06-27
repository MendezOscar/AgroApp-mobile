import '../../domain/entities/monthly_cost_entity.dart';

class MonthlyCostModel extends MonthlyCostEntity {
  const MonthlyCostModel({
    required super.year,
    required super.month,
    required super.fertilizationCost,
    required super.laborCost,
    required super.totalCost,
  });

  factory MonthlyCostModel.fromJson(Map<String, dynamic> json) {
    return MonthlyCostModel(
      year: json['year'] as int,
      month: json['month'] as int,
      fertilizationCost: (json['fertilizationCost'] as num).toDouble(),
      laborCost: (json['laborCost'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
    );
  }
}
