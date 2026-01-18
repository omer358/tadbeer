import 'package:dio/dio.dart';
import 'dart:math' as math;
import 'package:uuid/uuid.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/onboarding_models.dart';

abstract class RemoteDataSource {
  Future<void> signUp(
    User user,
    UserProfile profile,
    Goal goal,
    TransactionEntity firstTxn,
  );

  Future<UserProfile> getUserProfile();
  Future<void> saveUserProfile(UserProfile profile);

  Future<List<TransactionEntity>> getTransactions(String userId);
  Future<void> addTransaction(String userId, TransactionEntity transaction);

  Future<List<Goal>> fetchGoals(String userId);
  Future<Goal> createGoal(String userId, Goal goal);

  Future<String> askCoach(String query, String lang);

  Future<OnboardingResponse> submitOnboarding(OnboardingRequest request);

  Future<DashboardData> getDashboard(String userId, String lang);

  Future<String> uploadStatement(String userId, String filePath);

  Future<String> chatWithVoice(String userId, String filePath, String lang);

  Future<List<TransactionEntity>> addExpenseByVoice(
    String userId,
    String filePath,
    String lang,
  );
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final Dio _dio;

  RemoteDataSourceImpl(this._dio);

  @override
  Future<void> signUp(
    User user,
    UserProfile profile,
    Goal goal,
    TransactionEntity firstTxn,
  ) async {
    // Determine endpoints. Assuming a composite /signup endpoint or multiple calls.
    // Usually signup takes everything.
    await _dio.post(
      '/auth/signup',
      data: {
        'user': {
          'email': user.email,
          'password': user.password,
          'name': user.name,
        },
        'profile': _profileToJson(profile),
        'goal': _goalToDto(goal),
        'first_txn': _txnToJson(firstTxn),
      },
    );
  }

  @override
  Future<UserProfile> getUserProfile() async {
    final response = await _dio.get('/user/profile');
    return _profileFromJson(response.data);
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    await _dio.put('/user/profile', data: _profileToJson(profile));
  }

  @override
  Future<List<TransactionEntity>> getTransactions(String userId) async {
    final response = await _dio.get(
      '/expenses',
      options: Options(headers: {'X-User-Id': userId}),
    );
    final data = response.data;
    if (data is Map) {
      final allTxns = <TransactionEntity>[];
      for (final list in data.values) {
        if (list is List) {
          allTxns.addAll(list.map((e) => _txnFromJson(e)));
        }
      }
      return allTxns;
    } else if (data is List) {
      return data.map((e) => _txnFromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<void> addTransaction(
    String userId,
    TransactionEntity transaction,
  ) async {
    // Backend expects 'type' (EXPENSE/INCOME), 'date' (YYYY-MM-DD), etc.
    // _txnToJson needs to be robust.
    await _dio.post(
      '/expenses',
      options: Options(headers: {'X-User-Id': userId}),
      data: _txnToJson(transaction),
    );
  }

  @override
  Future<List<Goal>> fetchGoals(String userId) async {
    try {
      final response = await _dio.get(
        '/goals',
        options: Options(headers: {'X-User-Id': userId}),
      );
      if (response.data is List) {
        return (response.data as List).map((e) => _goalFromDto(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Goal> createGoal(String userId, Goal goal) async {
    final response = await _dio.post(
      '/goals',
      options: Options(headers: {'X-User-Id': userId}),
      data: _goalToDto(goal),
    );
    return _goalFromDto(response.data);
  }

  @override
  Future<String> askCoach(String query, String lang) async {
    final response = await _dio.post(
      '/coaching/chat',
      data: {'userId': 'user-123', 'query': query, 'lang': lang},
    );
    // Assuming response is text or JSON with a field. The user didn't specify response format.
    // "response from the server using this request is the other bubble"
    // Usually it returns JSON. Let's assume it returns a JSON with 'response' or just the text.
    // If it returns plain text:
    // return response.data.toString();
    // If it returns { "response": "..." }:
    // return response.data['response'];

    // User curl request says "-H 'accept: */*'".
    // Let's assume the response body is the answer directly or a JSON.
    // I'll check if data is Map.
    if (response.data is Map) {
      return response.data['response'] ??
          response.data['message'] ??
          response.data.toString();
    }
    return response.data.toString();
  }

  @override
  Future<OnboardingResponse> submitOnboarding(OnboardingRequest request) async {
    final response = await _dio.post('/onboarding', data: request.toJson());
    return OnboardingResponse.fromJson(response.data);
  }

  @override
  Future<DashboardData> getDashboard(String userId, String lang) async {
    final response = await _dio.get(
      '/dashboard',
      options: Options(headers: {'X-User-Id': userId, 'X-Lang-Pref': lang}),
    );
    return DashboardData.fromJson(response.data);
  }

  @override
  Future<String> uploadStatement(String userId, String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });

    final response = await _dio.post(
      '/expenses/upload-statement',
      queryParameters: {'userId': userId},
      data: formData,
    );
    return response.data.toString();
  }

  @override
  Future<String> chatWithVoice(
    String userId,
    String filePath,
    String lang,
  ) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });

    final response = await _dio.post(
      '/chat/voice',
      options: Options(headers: {'X-User-Id': userId, 'X-Lang-Pref': lang}),
      data: formData,
    );
    return response.data.toString();
  }

  @override
  Future<List<TransactionEntity>> addExpenseByVoice(
    String userId,
    String filePath,
    String lang,
  ) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });

    final response = await _dio.post(
      '/expenses/voice',
      options: Options(headers: {'X-User-Id': userId, 'X-Lang-Pref': lang}),
      data: formData,
    );
    final data = response.data;
    if (data is List) {
      return data.map((e) => _txnFromJson(e)).toList();
    }
    return [];
  }

  // --- Helpers (Manual Json until we add json_serializable) ---

  Map<String, dynamic> _profileToJson(UserProfile p) => {
    'incomeAmount': p.incomeAmount,
    'incomeSource': p.incomeSource,
    'payday': p.payday,
    'fixedExpenses': p.fixedExpenses
        .map((e) => {'name': e.name, 'amount': e.amount})
        .toList(),
    'spendingScale': p.spendingScale,
    'questionnaire': p.questionnaire,
  };

  UserProfile _profileFromJson(Map<String, dynamic> json) => UserProfile(
    incomeAmount: (json['incomeAmount'] as num).toDouble(),
    incomeSource: json['incomeSource'],
    payday: json['payday'],
    fixedExpenses: (json['fixedExpenses'] as List)
        .map(
          (e) => FixedExpense(
            name: e['name'],
            amount: (e['amount'] as num).toDouble(),
          ),
        )
        .toList(),
    spendingScale: Map<String, int>.from(json['spendingScale']),
    questionnaire: Map<String, dynamic>.from(json['questionnaire']),
  );

  Map<String, dynamic> _goalToDto(Goal g) {
    // Calculate deadline string from months
    final now = DateTime.now();
    final d = DateTime(now.year, now.month + g.deadlineMonths, now.day);
    final deadlineStr =
        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    return {
      'name': g.name,
      'type': g.type,
      'targetAmount': g.targetAmount,
      'monthlySavings':
          (g.targetAmount - g.savedAmount) /
          math.max(1, g.deadlineMonths), // Estimated? or required?
      'deadline': deadlineStr, // YYYY-MM-DD
    };
  }

  Goal _goalFromDto(Map<String, dynamic> json) {
    int deadlineMonths = 12;
    if (json['deadline'] != null) {
      try {
        final d = DateTime.parse(json['deadline']);
        final now = DateTime.now();
        deadlineMonths = ((d.year - now.year) * 12 + d.month - now.month).clamp(
          1,
          120,
        );
      } catch (_) {}
    }

    return Goal(
      id: const Uuid().v4(), // DTO doesn't have ID? Use random if missing.
      name: json['name'] ?? '',
      type: json['type'] ?? 'other',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      savedAmount: 0, // Not in DTO?
      deadlineMonths: deadlineMonths,
    );
  }

  Map<String, dynamic> _txnToJson(TransactionEntity t) => {
    'id': t.id,
    'amount': t.amount,
    'description': t.description,
    'category': t.category,
    'date': t.date.toIso8601String().substring(0, 10),
    'type': t.direction == 'debit' ? 'EXPENSE' : 'INCOME',
    'isBnpl': t.isBnpl,
  };

  TransactionEntity _txnFromJson(Map<String, dynamic> json) =>
      TransactionEntity(
        id: json['id'],
        amount: (json['amount'] as num).toDouble(),
        description: json['description'],
        category: _mapCategory(json['category']),
        date: DateTime.parse(json['date']),
        isBnpl: json['isBnpl'] ?? false,
      );

  String _mapCategory(String? backendCategory) {
    if (backendCategory == null) return 'other';
    // Normalize to lowercase for matching
    final key = backendCategory.toLowerCase();

    // Direct mappings for known backend keys
    if (key == 'food') return 'restaurants';
    if (key == 'transportation') return 'transport';
    if (key == 'retail') return 'shopping';
    if (key == 'telecommunications') return 'bills';

    // Allowed frontend keys
    const allowed = {
      'restaurants',
      'delivery',
      'transport',
      'shopping',
      'bnpl',
      'bills',
      'other',
    };

    if (allowed.contains(key)) return key;
    return 'other';
  }
}
