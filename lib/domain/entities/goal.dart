import 'package:equatable/equatable.dart';

class Goal extends Equatable {
  final String id;
  final String name;
  final String type; // car, travel, etc.
  final double targetAmount;
  final double savedAmount;
  final int deadlineMonths;

  const Goal({
    required this.id,
    required this.name,
    required this.type,
    required this.targetAmount,
    required this.savedAmount,
    required this.deadlineMonths,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    targetAmount,
    savedAmount,
    deadlineMonths,
  ];

  Goal copyWith({
    String? id,
    String? name,
    String? type,
    double? targetAmount,
    double? savedAmount,
    int? deadlineMonths,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      deadlineMonths: deadlineMonths ?? this.deadlineMonths,
    );
  }
}
