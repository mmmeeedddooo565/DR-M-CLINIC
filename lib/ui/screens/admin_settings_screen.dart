import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/appointment_service.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _slotsCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cfg = await AppointmentService.getConfig();
    _slotsCtrl.text = (cfg['slots'] as List)
        .map((e) => e.toString())
        .join(',');
    _capacityCtrl.text = cfg['capacity'].toString();
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    final isAr = context.read<LanguageService>().isArabic;
    final slots = _slotsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final cap = int.tryParse(_capacityCtrl.text.trim()) ?? 2;
    if (slots.isEmpty || cap <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr
              ? 'أدخل مواعيد وسعة صالحة'
              : 'Enter valid slots & capacity'),
        ),
      );
      return;
    }
    await AppointmentService.saveConfig(slots: slots, capacity: cap);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(isAr ? 'تم حفظ الإعدادات' : 'Settings saved'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LanguageService>().isArabic;
    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAr
              ? 'إعدادات المواعيد'
              : 'Appointment settings'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _slotsCtrl,
                decoration: InputDecoration(
                  labelText: isAr
                      ? 'مواعيد (مثال: 16:30,17:30,18:30)'
                      : 'Slots (e.g. 16:30,17:30,18:30)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _capacityCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isAr
                      ? 'عدد الحجوزات لكل ميعاد'
                      : 'Capacity per slot',
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
            ],
          ),
        ),
      ),
    );
  }
}
