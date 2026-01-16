import 'package:get_it/get_it.dart';
import '../data/datasources/fake_local_data_source.dart';
import '../data/repositories/data_repository_impl.dart';
import '../domain/repositories/data_repository.dart';
import '../features/dashboard/bloc/dashboard_bloc.dart';
import '../features/expenses/bloc/expenses_bloc.dart';
import '../features/goals/bloc/goals_bloc.dart';
import '../features/onboarding/bloc/onboarding_bloc.dart';
import '../features/settings/bloc/settings_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Data Source
  sl.registerLazySingleton(() => FakeLocalDataSource());

  // Repository
  sl.registerLazySingleton<DataRepository>(() => DataRepositoryImpl(sl()));

  // BLoCs
  // We will register these as factories so they get created fresh when needed,
  // or singletons if we want global state.
  // For this app structure (Tabs in one shell), Singletons might be easier for shared state updates
  // (e.g. adding expense updates dashboard).
  // Alternatively, use Streams or re-fetching. Let's start with Factory and good events.
  // Actually, Dashboard relies on Expenses.
  // Let's use LazySingleton for the main app feature BLoCs to keep state alive during tab switches.

  sl.registerLazySingleton(() => SettingsBloc());
  sl.registerFactory(
    () => OnboardingBloc(sl()),
  ); // Factory because it's a flow used once usually

  sl.registerLazySingleton(() => DashboardBloc(sl()));
  sl.registerLazySingleton(() => ExpensesBloc(sl()));
  sl.registerLazySingleton(() => GoalsBloc(sl()));
}
