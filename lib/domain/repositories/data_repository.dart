import '../entities/goal.dart';
import '../entities/transaction.dart';
import '../entities/user_profile.dart';
import '../entities/user.dart';
import '../../data/models/onboarding_models.dart';

abstract class DataRepository {
  Future<UserProfile> getUserProfile();
  Future<void> saveUserProfile(UserProfile profile);

  Future<List<TransactionEntity>> getTransactions();
  Future<void> addTransaction(TransactionEntity transaction);

  Future<Goal?> getGoal();
  Future<void> saveGoal(Goal goal);

  // For budget/categories (simplified as map in profile or separate?)
  // The original code passed 'budgets' map.
  Future<Map<String, double>> getBudgets();

  Future<void> signUp({
    required User user,
    required UserProfile profile,
    required Goal goal,
    required TransactionEntity firstTxn,
  });

  Future<String> askCoach(String query, String lang);

  Future<OnboardingResponse> submitOnboarding(OnboardingRequest request);
}
