import '../../domain/entities/goal.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/data_repository.dart';
import '../datasources/fake_local_data_source.dart';

class DataRepositoryImpl implements DataRepository {
  final FakeLocalDataSource _dataSource;

  DataRepositoryImpl(this._dataSource);

  @override
  Future<void> addTransaction(TransactionEntity transaction) =>
      _dataSource.addTransaction(transaction);

  @override
  Future<Goal?> getGoal() => _dataSource.getGoal();

  @override
  Future<List<TransactionEntity>> getTransactions() =>
      _dataSource.getTransactions();

  @override
  Future<UserProfile> getUserProfile() => _dataSource.getUserProfile();

  @override
  Future<void> saveGoal(Goal goal) => _dataSource.saveGoal(goal);

  @override
  Future<void> saveUserProfile(UserProfile profile) =>
      _dataSource.saveUserProfile(profile);

  @override
  Future<Map<String, double>> getBudgets() => _dataSource.getBudgets();
}
