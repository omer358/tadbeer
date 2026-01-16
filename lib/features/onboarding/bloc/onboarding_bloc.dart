import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/entities/goal.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../../domain/entities/user_profile.dart';
import '../../../../domain/repositories/data_repository.dart';

// Events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();
  @override
  List<Object> get props => [];
}

class NextStep extends OnboardingEvent {}

class PreviousStep extends OnboardingEvent {}

class UpdateIncome extends OnboardingEvent {
  final double amount;
  final String source;
  final int payday;
  const UpdateIncome(this.amount, this.source, this.payday);
}

// ... more events for each step's data updates
class AddFixedExpense extends OnboardingEvent {
  final String name;
  final double amount;
  const AddFixedExpense(this.name, this.amount);
}

class RemoveFixedExpense extends OnboardingEvent {
  final int index;
  const RemoveFixedExpense(this.index);
}

class UpdateFixedExpenseName extends OnboardingEvent {
  final int index;
  final String name;
  const UpdateFixedExpenseName(this.index, this.name);
}

class UpdateFixedExpenseAmount extends OnboardingEvent {
  final int index;
  final double amount;
  const UpdateFixedExpenseAmount(this.index, this.amount);
}

class UpdateVariableScale extends OnboardingEvent {
  final String category;
  final int value;
  const UpdateVariableScale(this.category, this.value);
}

class UpdateGoal extends OnboardingEvent {
  final String type;
  final String name;
  final double amount;
  final int deadline;
  const UpdateGoal(this.type, this.name, this.amount, this.deadline);
}

class RunFeasibilityCheck extends OnboardingEvent {}

class UpdateQuestionnaire extends OnboardingEvent {
  final String? bnpl;
  final String? debt;
  final String? autoSave;
  final String? notify;
  const UpdateQuestionnaire({this.bnpl, this.debt, this.autoSave, this.notify});
}

class UpdateFirstFn extends OnboardingEvent {
  final double amount;
  final String description;
  final String category;
  final DateTime date;
  const UpdateFirstFn(this.amount, this.description, this.category, this.date);
}

class CompleteOnboarding extends OnboardingEvent {}

// State
enum OnboardingStatus { initial, submitting, success, failure }

class OnboardingState extends Equatable {
  final int step;
  final OnboardingStatus status;
  // Data fields
  final double incomeAmount;
  final String incomeSource;
  final int payday;
  final List<FixedExpense> fixedExpenses;
  final Map<String, int> spendingScale;
  final String goalType;
  final String goalName;
  final double goalAmount;
  final int goalDeadline;
  final Map<String, dynamic>? feasibility;
  final String qBnpl;
  final String qDebt;
  final String qAutoSave;
  final String qNotify;
  final double firstTxnAmount;
  final String firstTxnDesc;
  final String firstTxnCategory;
  final DateTime firstTxnDate;

  const OnboardingState({
    this.step = 0,
    this.status = OnboardingStatus.initial,
    this.incomeAmount = 12000,
    this.incomeSource = 'salary',
    this.payday = 25,
    this.fixedExpenses = const [
      FixedExpense(name: 'Rent', amount: 3000),
      FixedExpense(name: 'Bills', amount: 700),
    ],
    this.spendingScale = const {
      'restaurants': 3,
      'delivery': 2,
      'transport': 2,
      'shopping': 2,
      'bnpl': 3,
      'bills': 2,
    },
    this.goalType = 'car',
    this.goalName = 'Dream Car',
    this.goalAmount = 25000,
    this.goalDeadline = 12,
    this.feasibility,
    this.qBnpl = 'often',
    this.qDebt = 'yes',
    this.qAutoSave = 'yes',
    this.qNotify = 'weekly',
    this.firstTxnAmount = 58,
    this.firstTxnDesc = 'AlBaik',
    this.firstTxnCategory = 'restaurants',
    required this.firstTxnDate, // Passed in constructor or default
  });

  OnboardingState copyWith({
    int? step,
    OnboardingStatus? status,
    double? incomeAmount,
    String? incomeSource,
    int? payday,
    List<FixedExpense>? fixedExpenses,
    Map<String, int>? spendingScale,
    String? goalType,
    String? goalName,
    double? goalAmount,
    int? goalDeadline,
    Map<String, dynamic>? feasibility,
    String? qBnpl,
    String? qDebt,
    String? qAutoSave,
    String? qNotify,
    double? firstTxnAmount,
    String? firstTxnDesc,
    String? firstTxnCategory,
    DateTime? firstTxnDate,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      status: status ?? this.status,
      incomeAmount: incomeAmount ?? this.incomeAmount,
      incomeSource: incomeSource ?? this.incomeSource,
      payday: payday ?? this.payday,
      fixedExpenses: fixedExpenses ?? this.fixedExpenses,
      spendingScale: spendingScale ?? this.spendingScale,
      goalType: goalType ?? this.goalType,
      goalName: goalName ?? this.goalName,
      goalAmount: goalAmount ?? this.goalAmount,
      goalDeadline: goalDeadline ?? this.goalDeadline,
      feasibility: feasibility ?? this.feasibility,
      qBnpl: qBnpl ?? this.qBnpl,
      qDebt: qDebt ?? this.qDebt,
      qAutoSave: qAutoSave ?? this.qAutoSave,
      qNotify: qNotify ?? this.qNotify,
      firstTxnAmount: firstTxnAmount ?? this.firstTxnAmount,
      firstTxnDesc: firstTxnDesc ?? this.firstTxnDesc,
      firstTxnCategory: firstTxnCategory ?? this.firstTxnCategory,
      firstTxnDate: firstTxnDate ?? this.firstTxnDate,
    );
  }

  @override
  List<Object?> get props => [
    step,
    status,
    incomeAmount,
    incomeSource,
    payday,
    fixedExpenses,
    spendingScale,
    goalType,
    goalName,
    goalAmount,
    goalDeadline,
    feasibility,
    qBnpl,
    qDebt,
    qAutoSave,
    qNotify,
    firstTxnAmount,
    firstTxnDesc,
    firstTxnCategory,
    firstTxnDate,
  ];
}

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final DataRepository _repo;

  OnboardingBloc(this._repo)
    : super(OnboardingState(firstTxnDate: DateTime.now())) {
    on<NextStep>((event, emit) {
      if (state.step < 7) emit(state.copyWith(step: state.step + 1));
    });
    on<PreviousStep>((event, emit) {
      if (state.step > 0) emit(state.copyWith(step: state.step - 1));
    });
    on<UpdateIncome>((event, emit) {
      emit(
        state.copyWith(
          incomeAmount: event.amount,
          incomeSource: event.source,
          payday: event.payday,
        ),
      );
    });
    on<AddFixedExpense>((event, emit) {
      final list = List<FixedExpense>.from(state.fixedExpenses);
      list.add(FixedExpense(name: event.name, amount: event.amount));
      emit(state.copyWith(fixedExpenses: list));
    });
    on<RemoveFixedExpense>((event, emit) {
      final list = List<FixedExpense>.from(state.fixedExpenses);
      if (event.index >= 0 && event.index < list.length) {
        list.removeAt(event.index);
        emit(state.copyWith(fixedExpenses: list));
      }
    });
    on<UpdateFixedExpenseName>((event, emit) {
      final list = List<FixedExpense>.from(state.fixedExpenses);
      if (event.index >= 0 && event.index < list.length) {
        final old = list[event.index];
        list[event.index] = FixedExpense(name: event.name, amount: old.amount);
        emit(state.copyWith(fixedExpenses: list));
      }
    });
    on<UpdateFixedExpenseAmount>((event, emit) {
      final list = List<FixedExpense>.from(state.fixedExpenses);
      if (event.index >= 0 && event.index < list.length) {
        final old = list[event.index];
        list[event.index] = FixedExpense(name: old.name, amount: event.amount);
        emit(state.copyWith(fixedExpenses: list));
      }
    });

    on<UpdateVariableScale>((event, emit) {
      final map = Map<String, int>.from(state.spendingScale);
      map[event.category] = event.value;
      emit(state.copyWith(spendingScale: map));
    });

    on<UpdateGoal>((event, emit) {
      emit(
        state.copyWith(
          goalType: event.type,
          goalName: event.name,
          goalAmount: event.amount,
          goalDeadline: event.deadline,
          // Reset feasibility when goal changes
          feasibility: null,
        ),
      );
    });

    on<RunFeasibilityCheck>((event, emit) {
      // logic from original OnboardingFlow
      final fixed = state.fixedExpenses.fold(0.0, (s, e) => s + e.amount);
      final estVariable =
          state.spendingScale.values.fold(0, (a, b) => a + b) * 250;
      final free = (state.incomeAmount - fixed - estVariable).clamp(
        0,
        double.infinity,
      );
      final months = state.goalDeadline < 1 ? 1 : state.goalDeadline;
      final req = state.goalAmount / months;

      emit(
        state.copyWith(
          feasibility: {
            'feasible': req <= free,
            'monthlyRequired': req.round(),
            'estFree': free.round(),
            'suggestion': '', // View can derive text
          },
        ),
      );
    });

    on<UpdateQuestionnaire>((event, emit) {
      emit(
        state.copyWith(
          qBnpl: event.bnpl ?? state.qBnpl,
          qDebt: event.debt ?? state.qDebt,
          qAutoSave: event.autoSave ?? state.qAutoSave,
          qNotify: event.notify ?? state.qNotify,
        ),
      );
    });

    on<UpdateFirstFn>((event, emit) {
      emit(
        state.copyWith(
          firstTxnAmount: event.amount,
          firstTxnDesc: event.description,
          firstTxnCategory: event.category,
          firstTxnDate: event.date,
        ),
      );
    });

    on<CompleteOnboarding>((event, emit) async {
      emit(state.copyWith(status: OnboardingStatus.submitting));

      final profile = UserProfile(
        incomeAmount: state.incomeAmount,
        incomeSource: state.incomeSource,
        payday: state.payday,
        fixedExpenses: state.fixedExpenses,
        spendingScale: state.spendingScale,
        questionnaire: {
          'qBnpl': state.qBnpl,
          'qDebt': state.qDebt,
          'qAutoSave': state.qAutoSave,
          'qNotify': state.qNotify,
        },
      );

      final goal = Goal(
        id: const Uuid().v4(),
        name: state.goalName,
        type: state.goalType,
        targetAmount: state.goalAmount,
        savedAmount: 0,
        deadlineMonths: state.goalDeadline,
      );

      final txn = TransactionEntity(
        id: const Uuid().v4(),
        amount: state.firstTxnAmount,
        description: state.firstTxnDesc,
        category: state.firstTxnCategory,
        date: state.firstTxnDate,
        isBnpl: state.firstTxnCategory == 'bnpl',
      );

      await _repo.saveUserProfile(profile);
      await _repo.saveGoal(goal);
      await _repo.addTransaction(txn);

      emit(state.copyWith(status: OnboardingStatus.success));
    });
  }
}
