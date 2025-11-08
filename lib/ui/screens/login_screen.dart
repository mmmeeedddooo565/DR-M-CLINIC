import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _remember = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final ok =
        await AuthService.loginUser(_phone.text.trim(), _pass.text.trim());
    final isAr = context.read<LanguageService>().isArabic;
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr ? 'بيانات غير صحيحة' : 'Invalid credentials'),
        ),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (_remember) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_phone', _phone.text.trim());
      await prefs.setString('saved_pass', _pass.text.trim());
    } else {
      await prefs.remove('remember_me');
      await prefs.remove('saved_phone');
      await prefs.remove('saved_pass');
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home',
        arguments: _phone.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LanguageService>().isArabic;
    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(isAr ? 'الدخول' : 'Login')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: isAr ? 'رقم الموبايل' : 'Mobile number',
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty)
                          ? (isAr ? 'أدخل رقم الموبايل' : 'Enter phone')
                          : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pass,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: isAr ? 'كلمة المرور' : 'Password',
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty)
                          ? (isAr ? 'أدخل كلمة المرور' : 'Enter password')
                          : null,
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _remember,
                  onChanged: (v) => setState(() => _remember = v ?? false),
                  title: Text(
                    isAr
                        ? 'تذكّرني (دخول تلقائي)'
                        : 'Remember me (auto login)',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _login,
                    child: Text(isAr ? 'الدخول' : 'Login'),
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
