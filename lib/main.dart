import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'services/auth_service.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/welcome_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/admin_login_screen.dart';
import 'ui/screens/admin_home_screen.dart';

class LanguageService extends ChangeNotifier {
  bool _isArabic = true;
  bool get isArabic => _isArabic;
  void toggle() {
    _isArabic = !_isArabic;
    notifyListeners();
  }
}

class ThemeService extends ChangeNotifier {
  bool _dark = false;
  bool get isDark => _dark;
  ThemeMode get themeMode => _dark ? ThemeMode.dark : ThemeMode.light;
  void toggle() {
    _dark = !_dark;
    notifyListeners();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // إذا لم يتم إعداد Firebase بشكل صحيح، التطبيق سيستمر في العمل
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();
    final theme = context.watch<ThemeService>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dr Mohamed clinic',
      themeMode: theme.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      locale: lang.isArabic ? const Locale('ar') : const Locale('en'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        '/': (_) => const SplashScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (ctx) {
          final phone =
              ModalRoute.of(ctx)!.settings.arguments as String? ?? '';
          return HomeScreen(phone: phone);
        },
        '/adminLogin': (_) => const AdminLoginScreen(),
        '/adminHome': (ctx) {
          final role =
              ModalRoute.of(ctx)!.settings.arguments as AdminRole?;
          return AdminHomeScreen(role: role);
        },
      },
    );
  }
}
