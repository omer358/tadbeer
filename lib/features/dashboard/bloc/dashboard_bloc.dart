import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/goal.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../../domain/entities/user_profile.dart';
import '../../../../domain/repositories/data_repository.dart';

import '../../../../domain/entities/suggestion.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object> get props => [];
}

class LoadDashboard extends DashboardEvent {
  final String lang;
  const LoadDashboard(this.lang);
  @override
  List<Object> get props => [lang];
}

class DashboardState extends Equatable {
  final UserProfile profile;
  final List<TransactionEntity> recentTransactions;
  final Goal? goal;
  final Map<String, double> budgets;
  final bool loading;
  final double income;
  final double expenses;
  final double balance;
  final List<Suggestion> dashboardSuggestions;
  final List<Suggestion> coachingSuggestions;
  final List<Suggestion> goalSuggestions;

  const DashboardState({
    this.profile = UserProfile.empty,
    this.recentTransactions = const [],
    this.goal,
    this.budgets = const {},
    this.loading = true,
    this.income = 0.0,
    this.expenses = 0.0,
    this.balance = 0.0,
    this.dashboardSuggestions = const [],
    this.coachingSuggestions = const [],
    this.goalSuggestions = const [],
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
    dashboardSuggestions,
    coachingSuggestions,
    goalSuggestions,
  ];
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DataRepository _repo;

  DashboardBloc(this._repo) : super(const DashboardState()) {
    on<LoadDashboard>((event, emit) async {
      emit(const DashboardState(loading: true));
      try {
        final data = await _repo.fetchDashboardData(event.lang);

        final p = await _repo.getUserProfile();
        final txns = await _repo.getTransactions();
        final goals = await _repo.getGoals();
        final g = goals.isNotEmpty ? goals.first : null;
        final b = await _repo.getBudgets();

        final dashboardSug = data.suggestions.dashboard
            .map(
              (e) => Suggestion(
                title: e.title,
                description: e.description,
                type: e.type,
              ),
            )
            .toList();

        final coachingSug = data.suggestions.coaching
            .map(
              (e) => Suggestion(
                title: e.title,
                description: e.description,
                type: e.type,
              ),
            )
            .toList();

        final goalSug = data.suggestions.goals
            .map(
              (e) => Suggestion(
                title: e.title,
                description: e.description,
                type: e.type,
              ),
            )
            .toList();

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
            dashboardSuggestions: dashboardSug,
            coachingSuggestions: coachingSug,
            goalSuggestions: goalSug,
          ),
        );
      } catch (e) {
        // handle error
        emit(const DashboardState(loading: false));
      }
    });
  }
}
