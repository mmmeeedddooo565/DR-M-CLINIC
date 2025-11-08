import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  final String phone;
  const ProfileScreen({super.key, required this.phone});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await FirestoreService.getUser(widget.phone) ?? {};
    _name.text = (u['name'] ?? '').toString();
    _age.text = (u['age']?.toString() ?? '');
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final isAr = context.read<LanguageService>().isArabic;
    final name = _name.text.trim();
    final age = int.tryParse(_age.text.trim());
    if (name.isEmpty || age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isAr ? 'أدخل الاسم والعمر بشكل صحيح' : 'Enter valid name & age'),
        ),
      );
      return;
    }
    await FirestoreService.upsertUser(
      phone: widget.phone,
      name: name,
      age: age,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(isAr ? 'تم حفظ البيانات' : 'Profile saved'),
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('remember_me');
    await prefs.remove('saved_phone');
    await prefs.remove('saved_pass');
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, '/welcome', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LanguageService>().isArabic;
    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAr ? 'البيانات الشخصية' : 'Profile'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.phone,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _name,
                      decoration: InputDecoration(
                        labelText: isAr ? 'الاسم' : 'Name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _age,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: isAr ? 'العمر' : 'Age',
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _save,
                        child: Text(isAr ? 'حفظ' : 'Save'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _logout,
                        child:
                            Text(isAr ? 'تسجيل الخروج' : 'Logout'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
