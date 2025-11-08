import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import 'admin_home_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _pass = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final role = await AuthService.loginAdmin(_pass.text.trim());
    final isAr = context.read<LanguageService>().isArabic;
    if (role == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr
              ? 'كلمة مرور غير صحيحة'
              : 'Invalid admin password'),
        ),
      );
      return;
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdminHomeScreen(role: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LanguageService>().isArabic;
    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar:
            AppBar(title: Text(isAr ? 'دخول الأدمن' : 'Admin Login')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _pass,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: isAr ? 'كلمة المرور' : 'Password',
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty)
                          ? (isAr
                              ? 'أدخل كلمة المرور'
                              : 'Enter password')
                          : null,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _login,
                    child: Text(isAr ? 'دخول' : 'Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
