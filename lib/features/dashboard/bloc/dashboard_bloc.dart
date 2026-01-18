import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/goal.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../../domain/entities/user_profile.dart';
import '../../../../domain/repositories/data_repository.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object> get props => [];
}

class LoadDashboard extends DashboardEvent {}

class DashboardState extends Equatable {
  final UserProfile profile;
  final List<TransactionEntity> recentTransactions;
  final Goal? goal;
  final Map<String, double> budgets;
  final bool loading;
  final double income;
  final double expenses;
  final double balance;

  const DashboardState({
    this.profile = UserProfile.empty,
    this.recentTransactions = const [],
    this.goal,
    this.budgets = const {},
    this.loading = true,
    this.income = 0.0,
    this.expenses = 0.0,
    this.balance = 0.0,
  });

  @override
  List<Object?> get props => [
    profile,
    recentTransactions,
    goal,
    budgets,
    loading,
    income,
    expenses,
    balance,
  ];
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DataRepository _repo;

  DashboardBloc(this._repo) : super(const DashboardState()) {
    on<LoadDashboard>((event, emit) async {
      emit(const DashboardState(loading: true));
      try {
        final data = await _repo.fetchDashboardData();

        final p = await _repo.getUserProfile();
        final txns = await _repo.getTransactions();
        final g = await _repo.getGoal();
        final b = await _repo.getBudgets();

        emit(
          DashboardState(
            profile: p,
            recentTransactions: txns,
            goal: g,
            budgets: b,
            loading: false,
            income: data.totalIncome,
            expenses: data.totalExpenses,
            balance: data.availableBalance,
          ),
        );
      } catch (e) {
        // handle error
        emit(const DashboardState(loading: false));
      }
    });
  }
}
