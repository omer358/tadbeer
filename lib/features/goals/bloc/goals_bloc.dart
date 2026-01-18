import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/goal.dart';
import '../../../../domain/entities/user_profile.dart'; // needed?
import '../../../../domain/repositories/data_repository.dart';

abstract class GoalsEvent extends Equatable {
  const GoalsEvent();
  @override
  List<Object> get props => [];
}

class LoadGoals extends GoalsEvent {}

class AddGoal extends GoalsEvent {
  final Goal goal;
  const AddGoal(this.goal);
}

class GoalsState extends Equatable {
  final Goal? goal; // Deprecated, use goals.firstOrNull
  final List<Goal> goals;
  final UserProfile? profile;
  final bool loading;

  const GoalsState({
    this.goal,
    this.goals = const [],
    this.profile,
    this.loading = false,
  });

  @override
  List<Object?> get props => [goal, goals, profile, loading];
}

class GoalsBloc extends Bloc<GoalsEvent, GoalsState> {
  final DataRepository _repo;

  GoalsBloc(this._repo) : super(const GoalsState()) {
    on<LoadGoals>((event, emit) async {
      emit(const GoalsState(loading: true));
      final goals = await _repo.getGoals();
      final p = await _repo.getUserProfile();
      emit(
        GoalsState(
          goal: goals.isNotEmpty ? goals.first : null,
          goals: goals,
          profile: p,
          loading: false,
        ),
      );
    });

    on<AddGoal>((event, emit) async {
      await _repo.addGoal(event.goal);
      add(LoadGoals());
    });
  }
}
