import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../../domain/repositories/data_repository.dart';

abstract class ExpensesEvent extends Equatable {
  const ExpensesEvent();
  @override
  List<Object> get props => [];
}

class LoadExpenses extends ExpensesEvent {}

class AddExpense extends ExpensesEvent {
  final TransactionEntity transaction;
  const AddExpense(this.transaction);
}

class ExpensesState extends Equatable {
  final List<TransactionEntity> transactions;
  final bool loading;

  const ExpensesState({this.transactions = const [], this.loading = false});

  @override
  List<Object> get props => [transactions, loading];
}

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final DataRepository _repo;

  ExpensesBloc(this._repo) : super(const ExpensesState()) {
    on<LoadExpenses>((event, emit) async {
      emit(const ExpensesState(loading: true));
      final txns = await _repo.getTransactions();
      emit(ExpensesState(transactions: txns, loading: false));
    });

    on<AddExpense>((event, emit) async {
      await _repo.addTransaction(event.transaction);
      add(LoadExpenses());
    });
  }
}
