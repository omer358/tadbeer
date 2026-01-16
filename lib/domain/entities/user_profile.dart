import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final double incomeAmount;
  final String incomeSource;
  final int payday;
  final List<FixedExpense> fixedExpenses;
  final Map<String, int> spendingScale;
  final Map<String, dynamic> questionnaire;
  final String currency; // 'SAR'

  const UserProfile({
    required this.incomeAmount,
    required this.incomeSource,
    required this.payday,
    required this.fixedExpenses,
    required this.spendingScale,
    required this.questionnaire,
    this.currency = 'SAR',
  });

  UserProfile copyWith({
    double? incomeAmount,
    String? incomeSource,
    int? payday,
    List<FixedExpense>? fixedExpenses,
    Map<String, int>? spendingScale,
    Map<String, dynamic>? questionnaire,
  }) {
    return UserProfile(
      incomeAmount: incomeAmount ?? this.incomeAmount,
      incomeSource: incomeSource ?? this.incomeSource,
      payday: payday ?? this.payday,
      fixedExpenses: fixedExpenses ?? this.fixedExpenses,
      spendingScale: spendingScale ?? this.spendingScale,
      questionnaire: questionnaire ?? this.questionnaire,
    );
  }

  /// Estimated safe-to-spend calculation
  double get totalFixed => fixedExpenses.fold(0, (sum, e) => sum + e.amount);
  double get freeIncome => incomeAmount - totalFixed;

  static const empty = UserProfile(
    incomeAmount: 0,
    incomeSource: 'salary',
    payday: 27,
    fixedExpenses: [],
    spendingScale: {},
    questionnaire: {},
  );

  @override
  List<Object?> get props => [
    incomeAmount,
    incomeSource,
    payday,
    fixedExpenses,
    spendingScale,
    questionnaire,
  ];
}

class FixedExpense extends Equatable {
  final String name;
  final double amount;

  const FixedExpense({required this.name, required this.amount});

  @override
  List<Object?> get props => [name, amount];
}
