import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulate login delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isLoading = false);
        // Show success or navigate
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login functionality coming soon!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine language from context or assume passed.
    // Usually we read it from SettingsBloc or context.
    // For simplicity, let's just use a hardcoded 'en' or try to read Localizations.
    // Given the previous file used context.select for lang, I'll assume I might need it.
    // But this widget is pushed, so I can just default to 'en' or access bloc if I wrap it.
    // Let's assume passed in arguments or just handle UI for now.
    // I'll assume 'en' default but check directionality.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final lang = isRtl ? 'ar' : 'en';

    return Scaffold(
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            right: -100,
            top: -100,
            child: Opacity(
              opacity: 0.3,
              child: Container(
                width: 400,
                height: 400,
                decoration: ShapeDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.5,
                    colors: [
                      Theme.of(context).colorScheme.tertiary,
                      Theme.of(context).colorScheme.tertiary.withOpacity(0),
                    ],
                  ),
                  shape: const OvalBorder(),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      lang == 'ar' ? 'مرحباً بعودتك!' : 'Welcome Back!',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ).animate().fade().slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      lang == 'ar'
                          ? 'سجّل دخولك للمتابعة.'
                          : 'Login to continue managing your finances.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ).animate().fade(delay: 100.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 40),

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: InputDecoration(
                        labelText: lang == 'ar' ? 'البريد الإلكتروني' : 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) => v == null || !v.contains('@')
                          ? (lang == 'ar' ? 'بريد غير صالح' : 'Invalid email')
                          : null,
                    ).animate().fade(delay: 200.ms).slideX(),

                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: lang == 'ar' ? 'كلمة المرور' : 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? (lang == 'ar' ? 'مطلوب' : 'Required')
                          : null,
                    ).animate().fade(delay: 300.ms).slideX(),

                    const SizedBox(height: 12),

                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          lang == 'ar'
                              ? 'نسيت كلمة المرور؟'
                              : 'Forgot Password?',
                        ),
                      ),
                    ).animate().fade(delay: 400.ms),

                    const SizedBox(height: 32),

                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      FilledButton(
                            onPressed: _login,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              lang == 'ar' ? 'تسجيل الدخول' : 'Login',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                          .animate()
                          .fade(delay: 500.ms)
                          .slideY(begin: 0.2, end: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
