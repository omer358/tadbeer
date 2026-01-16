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

  const DashboardState({
    this.profile = UserProfile.empty,
    this.recentTransactions = const [],
    this.goal,
    this.budgets = const {},
    this.loading = true,
  });

  // Computed getters for UI convenience could be here or in UI
  double get totalSpent => recentTransactions
      .where((t) => t.direction == 'debit')
      .fold(0, (sum, t) => sum + t.amount);

  @override
  List<Object?> get props => [
    profile,
    recentTransactions,
    goal,
    budgets,
    loading,
  ];
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DataRepository _repo;

  DashboardBloc(this._repo) : super(const DashboardState()) {
    on<LoadDashboard>((event, emit) async {
      emit(const DashboardState(loading: true));
      try {
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
          ),
        );
      } catch (e) {
        // handle error
        emit(const DashboardState(loading: false));
      }
    });
  }
}
