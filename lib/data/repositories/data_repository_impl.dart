import '../../domain/entities/goal.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/data_repository.dart';
import '../../domain/entities/user.dart';
import '../datasources/fake_local_data_source.dart';

import '../datasources/remote_data_source.dart';

class DataRepositoryImpl implements DataRepository {
  final FakeLocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;

  DataRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<void> addTransaction(TransactionEntity transaction) =>
      _localDataSource.addTransaction(transaction);

  @override
  Future<Goal?> getGoal() => _localDataSource.getGoal();

  @override
  Future<List<TransactionEntity>> getTransactions() =>
      _localDataSource.getTransactions();

  @override
  Future<UserProfile> getUserProfile() => _localDataSource.getUserProfile();

  @override
  Future<void> saveGoal(Goal goal) => _localDataSource.saveGoal(goal);

  @override
  Future<void> saveUserProfile(UserProfile profile) =>
      _localDataSource.saveUserProfile(profile);

  @override
  Future<Map<String, double>> getBudgets() => _localDataSource.getBudgets();

  @override
  Future<void> signUp({
    required User user,
    required UserProfile profile,
    required Goal goal,
    required TransactionEntity firstTxn,
  }) => _localDataSource.signUp(user, profile, goal, firstTxn);

  @override
  Future<String> askCoach(String query, String lang) =>
      _remoteDataSource.askCoach(query, lang);
}
