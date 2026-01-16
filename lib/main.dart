import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme.dart';
import 'core/locator.dart' as di;
import 'features/onboarding/onboarding_flow.dart';
import 'app_shell.dart';
import 'features/settings/bloc/settings_bloc.dart';
import 'features/dashboard/bloc/dashboard_bloc.dart';
import 'features/expenses/bloc/expenses_bloc.dart';
import 'features/goals/bloc/goals_bloc.dart';
import 'domain/repositories/data_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const SmartSpendApp());
}

class SmartSpendApp extends StatelessWidget {
  const SmartSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<SettingsBloc>()),
        // We provide feature blocs here so they are available globally
        // or lazily created when AppShell needs them.
        // Dashboard, Expenses, Goals are needed inside AppShell.
        BlocProvider(create: (_) => di.sl<DashboardBloc>()),
        BlocProvider(create: (_) => di.sl<ExpensesBloc>()),
        BlocProvider(create: (_) => di.sl<GoalsBloc>()),
      ],
      child: const SmartSpendAppView(),
    );
  }
}

class SmartSpendAppView extends StatelessWidget {
  const SmartSpendAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final dir = state.locale.languageCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: state.themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          locale: state.locale,
          builder: (context, child) {
            return Directionality(
              textDirection: dir,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const AuthGate(),
        );
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool? hasProfile;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final repo = di.sl<DataRepository>();
    final p = await repo.getUserProfile();
    // Simple check: income > 0 means initialized for this fake app
    setState(() {
      hasProfile = p.incomeAmount > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (hasProfile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!hasProfile!) {
      return const OnboardingFlow();
    }

    return const AppShell();
  }
}
