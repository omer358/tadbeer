import '../../domain/entities/goal.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user.dart';

class FakeLocalDataSource {
  UserProfile _profile = UserProfile.empty;
  final List<TransactionEntity> _transactions = [];
  Goal? _goal;
  final Map<String, double> _budgets = {
    'restaurants': 800,
    'delivery': 600,
    'transport': 500,
    'shopping': 700,
    'bnpl': 600,
    'bills': 1200,
    'other': 400,
  };

  Future<UserProfile> getUserProfile() async {
    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _profile;
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _profile = profile;
  }

  Future<List<TransactionEntity>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_transactions);
  }

  Future<void> addTransaction(TransactionEntity transaction) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _transactions.insert(0, transaction);
  }

  Future<Goal?> getGoal() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _goal;
  }

  Future<void> saveGoal(Goal goal) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _goal = goal;
  }

  Future<Map<String, double>> getBudgets() async {
    return _budgets;
  }

  Future<void> signUp(
    User user,
    UserProfile profile,
    Goal goal,
    TransactionEntity txn,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _profile = profile;
    _goal = goal;
    _transactions.insert(0, txn);
    // In a real app, we'd save the 'user' auth data too.
  }

  Future<String> askCoach(String query) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return "This is a fake response for '$query'. Please switch to RemoteDataSource for real AI.";
  }
}
