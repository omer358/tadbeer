class OnboardingRequest {
  final UserReq user;
  final List<GoalReq> goals;
  final double salary;
  final String sourceOfIncome;
  final int payday;
  final List<FixedExpenseReq> fixedExpenses;
  final List<SpendingEstimationReq> spendingEstimations;
  final String bnplUsage;
  final LatestExpenseReq latestExpense;
  final String lang;

  OnboardingRequest({
    required this.user,
    required this.goals,
    required this.salary,
    required this.sourceOfIncome,
    required this.payday,
    required this.fixedExpenses,
    required this.spendingEstimations,
    required this.bnplUsage,
    required this.latestExpense,
    required this.lang,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'goals': goals.map((e) => e.toJson()).toList(),
      'salary': salary,
      'sourceOfIncome': sourceOfIncome,
      'payday': payday,
      'fixedExpenses': fixedExpenses.map((e) => e.toJson()).toList(),
      'spendingEstimations': spendingEstimations
          .map((e) => e.toJson())
          .toList(),
      'bnplUsage': bnplUsage,
      'latestExpense': latestExpense.toJson(),
      'lang': lang,
    };
  }
}

class UserReq {
  final String name;
  final String email;
  final double monthlyIncome;
  final String currency;
  final int age;
  final String employmentStatus;

  UserReq({
    required this.name,
    required this.email,
    required this.monthlyIncome,
    required this.currency,
    required this.age,
    required this.employmentStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'monthlyIncome': monthlyIncome,
      'currency': currency,
      'age': age,
      'employmentStatus': employmentStatus,
    };
  }
}

class GoalReq {
  final String name;
  final double targetAmount;
  final double monthlySavings;
  final String deadline;
  final String type;

  GoalReq({
    required this.name,
    required this.targetAmount,
    required this.monthlySavings,
    required this.deadline,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'monthlySavings': monthlySavings,
      'deadline': deadline,
      'type': type,
    };
  }

  factory GoalReq.fromJson(Map<String, dynamic> json) {
    return GoalReq(
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      monthlySavings: (json['monthlySavings'] as num).toDouble(),
      deadline: json['deadline'] as String,
      type: json['type'] as String,
    );
  }
}

class FixedExpenseReq {
  final String item;
  final double amount;

  FixedExpenseReq({required this.item, required this.amount});

  Map<String, dynamic> toJson() {
    return {'item': item, 'amount': amount};
  }
}

class SpendingEstimationReq {
  final String category;
  final int scale;

  SpendingEstimationReq({required this.category, required this.scale});

  Map<String, dynamic> toJson() {
    return {'category': category, 'scale': scale};
  }
}

class LatestExpenseReq {
  final String id;
  final String userId;
  final double amount;
  final String description;
  final String category;
  final String date;
  final String type;
  final String lang;

  LatestExpenseReq({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    required this.type,
    required this.lang,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'description': description,
      'category': category,
      'date': date,
      'type': type,
      'lang': lang,
    };
  }
}

class OnboardingResponse {
  final String userId;
  final String message;
  final DashboardData dashboard;

  OnboardingResponse({
    required this.userId,
    required this.message,
    required this.dashboard,
  });

  factory OnboardingResponse.fromJson(Map<String, dynamic> json) {
    return OnboardingResponse(
      userId: json['userId'] as String,
      message: json['message'] as String,
      dashboard: DashboardData.fromJson(
        json['dashboard'] as Map<String, dynamic>,
      ),
    );
  }
}

class DashboardData {
  final double totalIncome;
  final double totalExpenses;
  final double availableBalance;
  final String financialInsight;
  final List<GoalReq> goals;
  final List<dynamic> recentTransactions;
  final Gamification gamification;
  final SuggestionsData suggestions;

  DashboardData({
    required this.totalIncome,
    required this.totalExpenses,
    required this.availableBalance,
    required this.financialInsight,
    required this.goals,
    required this.recentTransactions,
    required this.gamification,
    required this.suggestions,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalIncome: (json['totalBudget'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (json['remaining'] as num?)?.toDouble() ?? 0.0,
      financialInsight: json['financialInsight'] as String? ?? '',
      goals:
          (json['goals'] as List<dynamic>?)
              ?.map((e) => GoalReq.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentTransactions: json['recentTransactions'] as List<dynamic>? ?? [],
      gamification: Gamification.fromJson(
        json['gamification'] as Map<String, dynamic>? ?? {},
      ),
      suggestions: SuggestionsData.fromJson(
        json['suggestions'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class Gamification {
  final int score;
  final int streak;
  final List<String> badges;

  Gamification({
    required this.score,
    required this.streak,
    required this.badges,
  });

  factory Gamification.fromJson(Map<String, dynamic> json) {
    return Gamification(
      score: (json['score'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      badges:
          (json['badges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class SuggestionReq {
  final String title;
  final String description;
  final String type;

  SuggestionReq({
    required this.title,
    required this.description,
    required this.type,
  });

  factory SuggestionReq.fromJson(Map<String, dynamic> json) {
    return SuggestionReq(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'INFO',
    );
  }
}

class SuggestionsData {
  final List<SuggestionReq> coaching;
  final List<SuggestionReq> dashboard;
  final List<SuggestionReq> goals;

  SuggestionsData({
    required this.coaching,
    required this.dashboard,
    required this.goals,
  });

  factory SuggestionsData.fromJson(Map<String, dynamic> json) {
    return SuggestionsData(
      coaching:
          (json['coaching'] as List?)
              ?.map((e) => SuggestionReq.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dashboard:
          (json['dashboard'] as List?)
              ?.map((e) => SuggestionReq.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      goals:
          (json['goals'] as List?)
              ?.map((e) => SuggestionReq.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
