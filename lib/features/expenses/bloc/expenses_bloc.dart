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

enum UploadStatus { initial, loading, success, failure }

class UploadStatement extends ExpensesEvent {
  final String filePath;
  const UploadStatement(this.filePath);
}

class ExpensesState extends Equatable {
  final List<TransactionEntity> transactions;
  final bool loading;
  final UploadStatus uploadStatus;
  final String? uploadMessage;

  const ExpensesState({
    this.transactions = const [],
    this.loading = false,
    this.uploadStatus = UploadStatus.initial,
    this.uploadMessage,
  });

  ExpensesState copyWith({
    List<TransactionEntity>? transactions,
    bool? loading,
    UploadStatus? uploadStatus,
    String? uploadMessage,
  }) {
    return ExpensesState(
      transactions: transactions ?? this.transactions,
      loading: loading ?? this.loading,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadMessage: uploadMessage ?? this.uploadMessage,
    );
  }

  @override
  List<Object?> get props => [
    transactions,
    loading,
    uploadStatus,
    uploadMessage,
  ];
}

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final DataRepository _repo;

  ExpensesBloc(this._repo) : super(const ExpensesState()) {
    on<LoadExpenses>((event, emit) async {
      emit(state.copyWith(loading: true));
      final txns = await _repo.getTransactions();
      emit(state.copyWith(transactions: txns, loading: false));
    });

    on<AddExpense>((event, emit) async {
      await _repo.addTransaction(event.transaction);
      add(LoadExpenses());
    });

    on<UploadStatement>((event, emit) async {
      emit(state.copyWith(uploadStatus: UploadStatus.loading));
      try {
        final msg = await _repo.uploadStatement(event.filePath);
        emit(
          state.copyWith(
            uploadStatus: UploadStatus.success,
            uploadMessage: msg,
          ),
        );
        // Optionally refresh expenses if the backend parsed them immediately
        add(LoadExpenses());
      } catch (e) {
        emit(
          state.copyWith(
            uploadStatus: UploadStatus.failure,
            uploadMessage: e.toString(),
          ),
        );
      }
    });
  }
}
