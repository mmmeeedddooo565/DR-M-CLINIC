import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  DateTime? _pressStart;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();
    final theme = context.watch<ThemeService>();
    final isAr = lang.isArabic;

    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: theme.toggle,
                      icon: Icon(theme.isDark ? Icons.dark_mode : Icons.light_mode),
                    ),
                    const Text(
                      'Dr Mohamed clinic',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    IconButton(
                      onPressed: lang.toggle,
                      icon: const Icon(Icons.language),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onLongPressStart: (_) => _pressStart = DateTime.now(),
                onLongPressEnd: (_) {
                  if (_pressStart != null &&
                      DateTime.now().difference(_pressStart!).inSeconds >= 15) {
                    Navigator.pushNamed(context, '/adminLogin');
                  }
                  _pressStart = null;
                },
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', height: 140),
                    const SizedBox(height: 16),
                    Text(
                      isAr
                          ? 'مرحبًا بك في تطبيق عيادة دكتور محمد إسماعيل'
                          : 'Welcome to Dr Mohamed Esmail Clinic',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text(isAr ? 'الدخول' : 'Login'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
