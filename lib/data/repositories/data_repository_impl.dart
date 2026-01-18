import '../../domain/entities/goal.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/data_repository.dart';
import '../../domain/entities/user.dart';
import 'dart:developer';
import '../datasources/fake_local_data_source.dart';

import 'package:dio/dio.dart';
import '../../core/exceptions.dart';
import '../datasources/remote_data_source.dart';
import '../../data/models/onboarding_models.dart';

class DataRepositoryImpl implements DataRepository {
  final FakeLocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;

  DataRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<void> addTransaction(TransactionEntity transaction) async {
    final userId = await _localDataSource.getUserId();
    if (userId != null) {
      try {
        await _remoteDataSource.addTransaction(userId, transaction);
      } catch (e) {
        log('Error adding transaction remotely: $e', name: 'DataRepository');
        // Continue to add locally so user sees it?
        // Or throw? If "impl get and post", usually implies remote sync.
        // I'll throw to inform user.
        throw ServerException(e.toString());
      }
    }
    await _localDataSource.addTransaction(transaction);
  }

  @override
  Future<Goal?> getGoal() => _localDataSource.getGoal();

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    final userId = await _localDataSource.getUserId();
    if (userId != null) {
      try {
        return await _remoteDataSource.getTransactions(userId);
      } catch (e) {
        log('Error getting transactions remotely: $e', name: 'DataRepository');
        // Fallback?
        return _localDataSource.getTransactions();
      }
    }
    return _localDataSource.getTransactions();
  }

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
  Future<String> askCoach(String query, String lang) async {
    try {
      return await _remoteDataSource.askCoach(query, lang);
    } on DioException catch (e) {
      log(
        'Dio Error in askCoach: ${e.message}',
        name: 'DataRepository',
        error: e,
      );
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ConnectionTimeoutException();
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException();
      } else if (e.type == DioExceptionType.badResponse) {
        throw ServerException(
          e.message ?? 'Server Error',
          e.response?.statusCode,
        );
      } else {
        throw ServerException(e.message ?? 'Unknown Error');
      }
    } catch (e) {
      log('Error in askCoach: $e', name: 'DataRepository', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  @override
  Future<DashboardData> fetchDashboardData() async {
    final userId = await _localDataSource.getUserId();
    if (userId == null) {
      log('No User ID found for dashboard refresh', name: 'DataRepository');
      throw ServerException('User ID not found');
    }

    try {
      final dashboard = await _remoteDataSource.getDashboard(userId);

      // Update Goals
      if (dashboard.goals.isNotEmpty) {
        final goalReq = dashboard.goals.first;
        final goal = Goal(
          id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
          name: goalReq.name,
          type: goalReq.type,
          targetAmount: goalReq.targetAmount,
          savedAmount: 0,
          deadlineMonths: int.tryParse(goalReq.deadline) ?? 12,
        );
        await _localDataSource.saveGoal(goal);
      }

      // Update Transactions
      for (var tRaw in dashboard.recentTransactions) {
        if (tRaw is Map<String, dynamic>) {
          final map = tRaw;
          final txn = TransactionEntity(
            id: map['id'] ?? 'txn_${DateTime.now().millisecondsSinceEpoch}',
            amount: (map['amount'] as num).toDouble(),
            description: map['description'] ?? '',
            category: map['category'] ?? 'General',
            date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
            direction: map['type'] == 'income' ? 'credit' : 'debit',
          );
          await _localDataSource.addTransaction(txn);
        }
      }
      return dashboard;
    } catch (e) {
      log('Error refreshing dashboard: $e', name: 'DataRepository', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<OnboardingResponse> submitOnboarding(OnboardingRequest request) async {
    try {
      final response = await _remoteDataSource.submitOnboarding(request);

      // Save UserID for session
      await _localDataSource.saveUserId(response.userId);

      // Do NOT persist valid dashboard data here, forcing Dashboard screen to fetch it.
      // However, we MUST persist UserProfile because /dashboard doesn't return it!
      // If we don't save Profile here, the app might crash if it tries to read Profile.
      // So I will persist Profile here, but NOT Goals/Transactions.

      final userProfile = UserProfile(
        incomeAmount: request.salary,
        incomeSource: request.sourceOfIncome,
        payday: request.payday,
        fixedExpenses: request.fixedExpenses
            .map((e) => FixedExpense(name: e.item, amount: e.amount))
            .toList(),
        spendingScale: {
          for (var e in request.spendingEstimations) e.category: e.scale,
        },
        questionnaire: {},
        currency: request.user.currency,
      );
      await _localDataSource.saveUserProfile(userProfile);

      return response;
    } on DioException catch (e) {
      log(
        'Dio Error in submitOnboarding: ${e.message}',
        name: 'DataRepository',
        error: e,
      );
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ConnectionTimeoutException();
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException();
      } else if (e.type == DioExceptionType.badResponse) {
        throw ServerException(
          e.message ?? 'Server Error',
          e.response?.statusCode,
        );
      } else {
        throw ServerException(e.message ?? 'Unknown Error');
      }
    } catch (e) {
      log('Error in submitOnboarding: $e', name: 'DataRepository', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadStatement(String filePath) async {
    final userId = await _localDataSource.getUserId();
    if (userId == null) {
      throw ServerException('User ID not found');
    }
    try {
      return await _remoteDataSource.uploadStatement(userId, filePath);
    } catch (e) {
      log('Error uploading statement: $e', name: 'DataRepository', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> chatWithVoice(String filePath, String lang) async {
    final userId = await _localDataSource.getUserId();
    if (userId == null) {
      throw ServerException('User ID not found');
    }
    try {
      return await _remoteDataSource.chatWithVoice(userId, filePath, lang);
    } catch (e) {
      log('Error using voice chat: $e', name: 'DataRepository', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TransactionEntity>> addExpenseByVoice(
    String filePath,
    String lang,
  ) async {
    final userId = await _localDataSource.getUserId();
    if (userId == null) {
      throw ServerException('User ID not found');
    }
    try {
      final txns = await _remoteDataSource.addExpenseByVoice(
        userId,
        filePath,
        lang,
      );
      for (var t in txns) {
        await _localDataSource.addTransaction(t);
      }
      return txns;
    } catch (e) {
      log('Error using voice expense: $e', name: 'DataRepository', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> hasSession() async {
    final uid = await _localDataSource.getUserId();
    return uid != null;
  }
}
