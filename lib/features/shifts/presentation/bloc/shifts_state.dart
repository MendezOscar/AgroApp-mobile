import 'package:equatable/equatable.dart';
import '../../domain/entities/task_occurrence_entity.dart';
import '../../domain/entities/task_template_entity.dart';

class ShiftsState extends Equatable {
  final List<TaskTemplateEntity> templates;
  final List<TaskOccurrenceEntity> occurrences;
  final DateTime selectedDate;
  final bool isLoading;
  final bool isOffline; // ← nuevo
  final String? error;
  final String? success;

  const ShiftsState({
    this.templates = const [],
    this.occurrences = const [],
    required this.selectedDate,
    this.isLoading = false,
    this.isOffline = false, // ← nuevo
    this.error,
    this.success,
  });

  ShiftsState copyWith({
    List<TaskTemplateEntity>? templates,
    List<TaskOccurrenceEntity>? occurrences,
    DateTime? selectedDate,
    bool? isLoading,
    bool? isOffline, // ← nuevo
    String? error,
    String? success,
  }) =>
      ShiftsState(
        templates: templates ?? this.templates,
        occurrences: occurrences ?? this.occurrences,
        selectedDate: selectedDate ?? this.selectedDate,
        isLoading: isLoading ?? this.isLoading,
        isOffline: isOffline ?? this.isOffline, // ← nuevo
        error: error,
        success: success,
      );

  List<TaskOccurrenceEntity> get dayShift =>
      occurrences.where((o) => o.shift == 'Day').toList();
  List<TaskOccurrenceEntity> get nightShift =>
      occurrences.where((o) => o.shift == 'Night').toList();
  int get unassignedCount => occurrences.where((o) => o.isUnassigned).length;

  @override
  List<Object?> get props => [
        templates,
        occurrences,
        selectedDate,
        isLoading,
        isOffline,
        error,
        success
      ];
}
