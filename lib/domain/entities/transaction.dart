import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final double amount;
  final String description;
  final String category;
  final DateTime date;
  final bool isBnpl;
  final String direction; // 'debit' or 'credit'

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    this.isBnpl = false,
    this.direction = 'debit',
  });

  @override
  List<Object?> get props => [
    id,
    amount,
    description,
    category,
    date,
    isBnpl,
    direction,
  ];

  TransactionEntity copyWith({
    String? id,
    double? amount,
    String? description,
    String? category,
    DateTime? date,
    bool? isBnpl,
    String? direction,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      isBnpl: isBnpl ?? this.isBnpl,
      direction: direction ?? this.direction,
    );
  }
}
