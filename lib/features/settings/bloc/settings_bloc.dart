import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object> get props => [];
}

class ToggleTheme extends SettingsEvent {}

class ToggleLanguage extends SettingsEvent {}

// State
class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;

  const SettingsState({required this.themeMode, required this.locale});

  SettingsState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object> get props => [themeMode, locale];
}

// BLoC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc()
    : super(
        const SettingsState(themeMode: ThemeMode.light, locale: Locale('ar')),
      ) {
    on<ToggleTheme>((event, emit) {
      final newMode = state.themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
      emit(state.copyWith(themeMode: newMode));
    });

    on<ToggleLanguage>((event, emit) {
      final newLocale = state.locale.languageCode == 'ar'
          ? const Locale('en')
          : const Locale('ar');
      emit(state.copyWith(locale: newLocale));
    });
  }
}
