import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'app_shell.dart';

void main() {
  runApp(const SmartSpendPrototypeApp());
}

class SmartSpendPrototypeApp extends StatefulWidget {
  const SmartSpendPrototypeApp({super.key});

  @override
  State<SmartSpendPrototypeApp> createState() => _SmartSpendPrototypeAppState();
}

class _SmartSpendPrototypeAppState extends State<SmartSpendPrototypeApp> {
  String lang = 'ar';
  bool dark = false;
  Map<String, dynamic>? boot;

  @override
  Widget build(BuildContext context) {
    // Force RTL for Arabic, LTR for English
    final dir = lang == 'ar' ? TextDirection.rtl : TextDirection.ltr;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: lightTheme,
      darkTheme: darkTheme,
      builder: (context, child) {
        return Directionality(
          textDirection: dir,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: boot == null
          ? OnboardingFlow(
              lang: lang,
              onToggleLang: () =>
                  setState(() => lang = lang == 'ar' ? 'en' : 'ar'),
              onComplete: (payload) => setState(() => boot = payload),
            )
          : AppShell(
              lang: lang,
              dark: dark,
              onToggleLang: () =>
                  setState(() => lang = lang == 'ar' ? 'en' : 'ar'),
              onToggleDark: (v) => setState(() => dark = v),
              initial: boot!,
            ),
    );
  }
}
