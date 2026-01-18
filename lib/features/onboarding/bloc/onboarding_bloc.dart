import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadbeer/domain/entities/user_profile.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/exceptions.dart';

// ... (existing imports, but this goes at top of file, I will use multi_replace or ensure top is handled)

// Actually replace_file_content replaces a block. I need to add import at top and change catch block at bottom.
// I will use multi_replace_file_content.
import '../../../../domain/repositories/data_repository.dart';
import '../../../../data/models/onboarding_models.dart';

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

class UpdateAuthData extends OnboardingEvent {
  final String? email;
  final String? password;
  final String? name;
  const UpdateAuthData({this.email, this.password, this.name});
}

class SignUp extends OnboardingEvent {}

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

  final String email;
  final String password;
  final String name;
  final String? errorMessage;

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
    required this.firstTxnDate,
    this.email = '',
    this.password = '',
    this.name = '',
    this.errorMessage,
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
    String? email,
    String? password,
    String? name,
    String? errorMessage,
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
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      errorMessage: errorMessage ?? this.errorMessage,
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
    email,
    password,
    name,
    errorMessage,
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

    on<UpdateAuthData>((event, emit) {
      emit(
        state.copyWith(
          email: event.email,
          password: event.password,
          name: event.name,
        ),
      );
    });

    on<SignUp>((event, emit) async {
      // Reset error message and set status to submitting
      emit(
        state.copyWith(status: OnboardingStatus.submitting, errorMessage: null),
      );

      try {
        final userReq = UserReq(
          name: state.name,
          email: state.email,
          monthlyIncome: state.incomeAmount,
          currency: 'SAR',
          age: 30, // Default as not collected
          employmentStatus: state.incomeSource,
        );

        final goalReq = GoalReq(
          name: state.goalName,
          targetAmount: state.goalAmount,
          monthlySavings:
              state.goalAmount /
              (state.goalDeadline > 0 ? state.goalDeadline : 1),
          deadline: DateTime.now()
              .add(Duration(days: state.goalDeadline * 30))
              .toIso8601String()
              .split('T')[0],
          type: state.goalType,
        );

        final fixedExpensesReq = state.fixedExpenses
            .map((e) => FixedExpenseReq(item: e.name, amount: e.amount))
            .toList();

        final spendingEstimationsReq = state.spendingScale.entries
            .map((e) => SpendingEstimationReq(category: e.key, scale: e.value))
            .toList();

        final latestExpenseReq = LatestExpenseReq(
          id: const Uuid().v4(),
          userId:
              '', // Server will assign or we generate? Server response returns userId.
          amount: state.firstTxnAmount,
          description: state.firstTxnDesc,
          category: state.firstTxnCategory,
          date: state.firstTxnDate.toIso8601String().split('T')[0],
          type: 'expense',
          lang: 'en', // Default, maybe pass from UI if needed
        );

        final request = OnboardingRequest(
          user: userReq,
          goals: [goalReq],
          salary: state.incomeAmount,
          sourceOfIncome: state.incomeSource,
          payday: state.payday,
          fixedExpenses: fixedExpensesReq,
          spendingEstimations: spendingEstimationsReq,
          bnplUsage: state.qBnpl,
          latestExpense: latestExpenseReq,
          lang: 'en',
        );

        await _repo.submitOnboarding(request);

        emit(state.copyWith(status: OnboardingStatus.success));
      } on ConnectionTimeoutException {
        emit(
          state.copyWith(
            status: OnboardingStatus.failure,
            errorMessage: 'error.timeout',
          ),
        );
      } on NetworkException {
        emit(
          state.copyWith(
            status: OnboardingStatus.failure,
            errorMessage: 'error.noInternet',
          ),
        );
      } on ServerException catch (e) {
        emit(
          state.copyWith(
            status: OnboardingStatus.failure,
            errorMessage:
                'error.server', // Or use e.message if key not desired, but user asked for localization
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            status: OnboardingStatus.failure,
            errorMessage: 'error.unknown',
          ),
        );
      }
    });
  }
}
